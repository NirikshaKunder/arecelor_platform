      ******************************************************************
      * DCLGEN TABLE( CUSTOMER)
           EXEC SQL DECLARE CUSTOMER  TABLE
           (
             CUST_APP_NUMBER
                     CHAR(0017)    NOT NULL WITH DEFAULT,
             CUST_STATUS
                     CHAR(0015)    NOT NULL WITH DEFAULT,
            CUST_APP_DATE
                    DATE               NOT NULL  WITH  DEFAULT,
             CUST_FULL_NAME
                     VARCHAR(0040) NOT NULL WITH DEFAULT,
             CUST_FIRST_NAME
                     CHAR(0020)    NOT NULL WITH DEFAULT,
             CUST_LAST_NAME
                     CHAR(0020)    NOT NULL WITH DEFAULT,
             CUST_GENDER
                     CHAR(0001)    NOT NULL WITH DEFAULT,
             CUST_EMIRATES_ID
                     CHAR(0018)    NOT NULL WITH DEFAULT,
            CUST_DOB
                    DATE               NOT NULL  WITH  DEFAULT,
             CUST_NATIONALITY
                     CHAR(0015),
             CUST_PHONE
                     CHAR(0015),
             CUST_EMAIL
                     VARCHAR(0040),
             CUST_CITY
                     CHAR(0020),
             CUST_AMOUNT_DUE
                     DECIMAL(9, 2) NOT NULL WITH DEFAULT
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE CUSTOMER
      ******************************************************************
       01  DCLCUSTOMER.
           02  CUSTOMER-APP-NUMBER
               PIC X(0017).
           02  CUSTOMER-STATUS
               PIC X(0015).
           02  CUSTOMER-APP-DATE
               PIC X(10).
           02  CUSTOMER-FULL-NAME.
               49  CUSTOMER-FULL-NAME-LEN
                   PIC S9(4) COMP.
               49  CUSTOMER-FULL-NAME-TEXT
                   PIC X(0040).
           02  CUSTOMER-FIRST-NAME
               PIC X(0020).
           02  CUSTOMER-LAST-NAME
               PIC X(0020).
           02  CUSTOMER-GENDER
               PIC X(0001).
           02  CUSTOMER-EMIRATES-ID
               PIC X(0018).
           02  CUSTOMER-DOB
               PIC X(10).
           02  CUSTOMER-NATIONALITY
               PIC X(0015).
           02  CUSTOMER-PHONE
               PIC X(0015).
           02  CUSTOMER-EMAIL.
               49  CUSTOMER-EMAIL-LEN
                   PIC S9(4) COMP.
               49  CUSTOMER-EMAIL-TEXT
                   PIC X(0040).
           02  CUSTOMER-CITY
               PIC X(0020).
           02  CUSTOMER-AMOUNT-DUE
               PIC S9(7)V9(2) COMP-3.
      ******************************************************************
      * NULL INDICATORS FOR TABLE CUSTOMER
      ******************************************************************
       01  DCLCUSTOMER-FLAGS.
           02  CUSTOMER-NATIONALITY-F
               PIC S9(4) COMP.
           02  CUSTOMER-PHONE-F
               PIC S9(4) COMP.
           02  CUSTOMER-EMAIL-F
               PIC S9(4) COMP.
           02  CUSTOMER-CITY-F
               PIC S9(4) COMP.
