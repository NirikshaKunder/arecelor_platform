package com.example.custrec;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.Test;

class CopybookParserTest {

    private static List<String> sampleLines() throws IOException {
        return Files.readAllLines(Path.of("../data/customers.dat"));
    }

    @Test
    void everySampleRecordIsExactly450Bytes() throws IOException {
        for (String line : sampleLines()) {
            assertEquals(CopybookParser.RECORD_LENGTH, line.length());
        }
    }

    @Test
    void parsesParentFields() throws IOException {
        CustomerRecord r = CopybookParser.parse(sampleLines().get(0));
        assertEquals("DKP-2026-538916-0", r.applicationNumber);
        assertEquals("Pending Payment", r.status);
        assertEquals(LocalDate.of(2026, 10, 19), r.applicationDate);
        assertEquals("Arjun Venkatesh Iyer", r.fullName);
        assertEquals("784-1985-4182937-2", r.emiratesId);
        assertEquals(new BigDecimal("3340.00"), r.amountDue);
    }

    @Test
    void parsesChildrenAndSkipsEmptySlots() throws IOException {
        CustomerRecord threeKids = CopybookParser.parse(sampleLines().get(0));
        assertEquals(3, threeKids.children.size());
        assertEquals("Meera", threeKids.children.get(2).firstName);
        assertEquals(new BigDecimal("55750.00"), threeKids.totalTuition());

        CustomerRecord oneKid = CopybookParser.parse(sampleLines().get(1));
        assertEquals(1, oneKid.children.size());
        assertEquals(new BigDecimal("21000.00"), oneKid.totalTuition());
    }

    @Test
    void masksEmiratesIdKeepingPrefixAndCheckDigit() throws IOException {
        CustomerRecord r = CopybookParser.parse(sampleLines().get(0));
        assertEquals("784-****-*******-2", r.maskedEmiratesId());
        assertEquals(r.emiratesId.substring(0, 3), r.maskedEmiratesId().substring(0, 3));
    }

    @Test
    void sqlQueriesUseDb2Functions() {
        assertTrue(CustomerSql.SELECT_SUMMARY.contains("SUBSTRING("));
        assertTrue(CustomerSql.SELECT_SUMMARY.contains("CHAR("));
    }

    @Test
    void rejectsOversizedRecord() {
        assertThrows(IllegalArgumentException.class,
                () -> CopybookParser.parse("X".repeat(451)));
    }
}
