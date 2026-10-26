package com.example.custrec;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Parses one 450-byte fixed-width line laid out by the CUSTREC copybook.
 * Field offsets and lengths mirror the PIC clauses exactly.
 */
public final class CopybookParser {

    public static final int RECORD_LENGTH = 450;
    private static final int MAX_CHILDREN = 3;
    private static final int CHILD_LENGTH = 20 + 8 + 10 + 9;   // 47 bytes
    private static final DateTimeFormatter YYYYMMDD = DateTimeFormatter.BASIC_ISO_DATE;

    private final String line;
    private int pos = 0;

    private CopybookParser(String line) {
        this.line = line;
    }

    public static CustomerRecord parse(String rawLine) {
        // Line-sequential files may drop trailing spaces; pad back to full length.
        String line = String.format("%-" + RECORD_LENGTH + "s", rawLine);
        if (line.length() != RECORD_LENGTH) {
            throw new IllegalArgumentException(
                "Expected " + RECORD_LENGTH + " bytes, got " + rawLine.length());
        }
        return new CopybookParser(line).read();
    }

    private CustomerRecord read() {
        CustomerRecord r = new CustomerRecord();
        r.applicationNumber = alpha(17);   // CUST-APP-NUMBER    PIC X(17)
        r.status            = alpha(15);   // CUST-STATUS        PIC X(15)
        r.applicationDate   = date();      // CUST-APP-DATE      PIC 9(08)
        r.fullName          = alpha(40);   // CUST-FULL-NAME     PIC X(40)
        r.firstName         = alpha(20);   // CUST-FIRST-NAME    PIC X(20)
        r.lastName          = alpha(20);   // CUST-LAST-NAME     PIC X(20)
        r.gender            = alpha(1);    // CUST-GENDER        PIC X(01)
        r.emiratesId        = alpha(18);   // CUST-EMIRATES-ID   PIC X(18)
        r.dateOfBirth       = date();      // CUST-DOB           PIC 9(08)
        r.nationality       = alpha(15);   // CUST-NATIONALITY   PIC X(15)
        r.phone             = alpha(15);   // CUST-PHONE         PIC X(15)
        r.email             = alpha(40);   // CUST-EMAIL         PIC X(40)
        r.address           = alpha(60);   // CUST-ADDRESS       PIC X(60)
        r.city              = alpha(20);   // CUST-CITY          PIC X(20)
        r.amountDue         = money();     // CUST-AMOUNT-DUE    PIC 9(07)V99
        int childCount      = number(1);   // CUST-CHILD-COUNT   PIC 9(01)

        if (childCount > MAX_CHILDREN) {
            throw new IllegalArgumentException("Child count " + childCount + " exceeds " + MAX_CHILDREN);
        }
        for (int i = 0; i < MAX_CHILDREN; i++) {
            if (i < childCount) {
                CustomerRecord.Child c = new CustomerRecord.Child();
                c.firstName    = alpha(20);   // CHILD-FIRST-NAME     PIC X(20)
                c.dateOfBirth  = date();      // CHILD-DOB            PIC 9(08)
                c.currentGrade = alpha(10);   // CHILD-CURRENT-GRADE  PIC X(10)
                c.tuitionFee   = money();     // CHILD-TUITION-FEE    PIC 9(07)V99
                r.children.add(c);
            } else {
                pos += CHILD_LENGTH;          // unused OCCURS slot
            }
        }
        pos += 2;                             // FILLER PIC X(02)
        return r;
    }

    private String take(int len) {
        String s = line.substring(pos, pos + len);
        pos += len;
        return s;
    }

    private String alpha(int len) {
        return take(len).trim();
    }

    private int number(int len) {
        return Integer.parseInt(take(len));
    }

    private LocalDate date() {
        return LocalDate.parse(take(8), YYYYMMDD);
    }

    /** PIC 9(07)V99: nine digits with an implied decimal point before the last two. */
    private BigDecimal money() {
        return new BigDecimal(take(9)).movePointLeft(2);
    }
}
