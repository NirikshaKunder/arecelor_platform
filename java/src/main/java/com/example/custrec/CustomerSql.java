package com.example.custrec;

/**
 * DB2 SQL for the CUSTOMER table declared in cobol/copybooks/DCLCUST.cpy.
 * Use these with JDBC (PreparedStatement) when the data lives in DB2
 * instead of the fixed-width file.
 */
public final class CustomerSql {

    private CustomerSql() {
    }

    /** One row per customer: ISO dates as text and the Emirates ID prefix. */
    public static final String SELECT_SUMMARY =
        "SELECT CUST_APP_NUMBER, "
      + "       CHAR(CUST_APP_DATE, ISO)                   AS APP_DATE, "
      + "       SUBSTRING(CUST_EMIRATES_ID, 1, 3, OCTETS)   AS ID_PREFIX, "
      + "       CHAR(CUST_AMOUNT_DUE)                      AS AMOUNT_DUE_TEXT "
      + "  FROM CUSTOMER "
      + " WHERE CUST_STATUS = ?";

    /** Applications by year, using the year embedded in the application number. */
    public static final String COUNT_BY_YEAR =
        "SELECT SUBSTRING(CUST_APP_NUMBER, 5, 4, OCTETS) AS APP_YEAR, "
      + "       COUNT(*)                                 AS APPLICATIONS "
      + "  FROM CUSTOMER "
      + " GROUP BY SUBSTRING(CUST_APP_NUMBER, 5, 4, OCTETS) "
      + " ORDER BY APP_YEAR";

    /** Finds a customer by the last four characters of the phone number. */
    public static final String FIND_BY_PHONE_SUFFIX =
        "SELECT CUST_APP_NUMBER, CUST_FULL_NAME "
      + "  FROM CUSTOMER "
      + " WHERE SUBSTRING(CHAR(CUST_PHONE), 10, 4, OCTETS) = ?";
}
