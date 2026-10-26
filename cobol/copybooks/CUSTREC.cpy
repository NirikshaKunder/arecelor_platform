      *================================================================*
      * COPYBOOK : CUSTREC                                             *
      * PURPOSE  : School-fee customer (parent) record with up to      *
      *            three enrolled children.                            *
      * LENGTH   : 450 bytes, fixed width, DISPLAY (text) fields only  *
      * USED BY  : CUSTRPT.cbl (COBOL), CopybookParser.java (Java)     *
      *================================================================*
       01  CUSTOMER-RECORD.
           05  CUST-APP-NUMBER          PIC X(17).
           05  CUST-STATUS              PIC X(15).
           05  CUST-APP-DATE            PIC 9(08).
      *        YYYYMMDD
           05  CUST-FULL-NAME           PIC X(40).
           05  CUST-FIRST-NAME          PIC X(20).
           05  CUST-LAST-NAME           PIC X(20).
           05  CUST-GENDER              PIC X(01).
               88  CUST-MALE                VALUE 'M'.
               88  CUST-FEMALE              VALUE 'F'.
           05  CUST-EMIRATES-ID         PIC X(18).
           05  CUST-DOB                 PIC 9(08).
           05  CUST-NATIONALITY         PIC X(15).
           05  CUST-PHONE               PIC X(15).
           05  CUST-EMAIL               PIC X(40).
           05  CUST-ADDRESS             PIC X(60).
           05  CUST-CITY                PIC X(20).
           05  CUST-AMOUNT-DUE          PIC 9(07)V99.
      *        Implied decimal: 000261600 = 2,616.00 AED
           05  CUST-CHILD-COUNT         PIC 9(01).
           05  CUST-CHILD OCCURS 3 TIMES.
               10  CHILD-FIRST-NAME     PIC X(20).
               10  CHILD-DOB            PIC 9(08).
               10  CHILD-CURRENT-GRADE  PIC X(10).
               10  CHILD-TUITION-FEE    PIC 9(07)V99.
           05  FILLER                   PIC X(02).
