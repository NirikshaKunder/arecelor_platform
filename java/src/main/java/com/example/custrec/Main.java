package com.example.custrec;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

/**
 * Reads the same fixed-width file as the COBOL program CUSTRPT and
 * prints every record as JSON, followed by the same totals.
 *
 * Usage: java -jar custrec.jar [path/to/customers.dat]
 */
public class Main {

    public static void main(String[] args) throws IOException {
        Path input = Path.of(args.length > 0 ? args[0] : "../data/customers.dat");
        List<CustomerRecord> records = new ArrayList<>();

        for (String line : Files.readAllLines(input, StandardCharsets.UTF_8)) {
            if (!line.isBlank()) {
                records.add(CopybookParser.parse(line));
            }
        }

        StringBuilder json = new StringBuilder("[\n");
        for (int i = 0; i < records.size(); i++) {
            json.append(records.get(i).toJson().indent(2).stripTrailing());
            json.append(i < records.size() - 1 ? ",\n" : "\n");
        }
        json.append("]");
        System.out.println(json);

        BigDecimal tuition = records.stream().map(CustomerRecord::totalTuition)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal due = records.stream().map(r -> r.amountDue)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        long pending = records.stream().filter(r -> "Pending Payment".equals(r.status)).count();
        int children = records.stream().mapToInt(r -> r.children.size()).sum();

        System.err.printf("Customers: %d | Children: %d | Pending: %d | Tuition: %,.2f AED | Due: %,.2f AED%n",
                records.size(), children, pending, tuition, due);
    }
}
