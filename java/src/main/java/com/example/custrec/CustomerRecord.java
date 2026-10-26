package com.example.custrec;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/** Java model of the CUSTREC copybook (01 CUSTOMER-RECORD). */
public class CustomerRecord {

    /** Model of one CUST-CHILD OCCURS entry. */
    public static class Child {
        public String firstName;
        public LocalDate dateOfBirth;
        public String currentGrade;
        public BigDecimal tuitionFee;
    }

    public String applicationNumber;
    public String status;
    public LocalDate applicationDate;
    public String fullName;
    public String firstName;
    public String lastName;
    public String gender;
    public String emiratesId;
    public LocalDate dateOfBirth;
    public String nationality;
    public String phone;
    public String email;
    public String address;
    public String city;
    public BigDecimal amountDue;
    public final List<Child> children = new ArrayList<>();

    public BigDecimal totalTuition() {
        return children.stream()
                .map(c -> c.tuitionFee)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public String toJson() {
        StringBuilder sb = new StringBuilder();
        sb.append("{\n");
        field(sb, "applicationNumber", applicationNumber, 1);
        field(sb, "status", status, 1);
        field(sb, "applicationDate", applicationDate.toString(), 1);
        sb.append("  \"parent\": {\n");
        field(sb, "fullName", fullName, 2);
        field(sb, "firstName", firstName, 2);
        field(sb, "lastName", lastName, 2);
        field(sb, "gender", "M".equals(gender) ? "Male" : "Female", 2);
        field(sb, "emiratesId", emiratesId, 2);
        field(sb, "dateOfBirth", dateOfBirth.toString(), 2);
        field(sb, "nationality", nationality, 2);
        field(sb, "phone", phone, 2);
        field(sb, "email", email, 2);
        field(sb, "address", address, 2);
        sb.append("    \"city\": \"").append(esc(city)).append("\"\n");
        sb.append("  },\n");
        sb.append("  \"children\": [");
        for (int i = 0; i < children.size(); i++) {
            Child c = children.get(i);
            sb.append(i == 0 ? "\n" : ",\n");
            sb.append("    {\n");
            field(sb, "firstName", c.firstName, 3);
            field(sb, "lastName", lastName, 3);
            field(sb, "dateOfBirth", c.dateOfBirth.toString(), 3);
            field(sb, "currentGrade", c.currentGrade, 3);
            sb.append("      \"tuitionFee\": { \"amount\": ")
              .append(c.tuitionFee.toPlainString())
              .append(", \"currency\": \"AED\" }\n");
            sb.append("    }");
        }
        sb.append(children.isEmpty() ? "],\n" : "\n  ],\n");
        sb.append("  \"amountDue\": { \"amount\": ")
          .append(amountDue.toPlainString())
          .append(", \"currency\": \"AED\" }\n");
        sb.append("}");
        return sb.toString();
    }

    private static void field(StringBuilder sb, String key, String value, int depth) {
        sb.append("  ".repeat(depth))
          .append('"').append(key).append("\": \"")
          .append(esc(value)).append("\",\n");
    }

    private static String esc(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
