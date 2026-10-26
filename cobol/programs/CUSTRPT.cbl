      *================================================================*
      * PROGRAM  : CUSTRPT                                             *
      * PURPOSE  : Read the fixed-width customer file described by the *
      *            CUSTREC copybook and print a fee summary report.    *
      * INPUT    : data/customers.dat  (450-byte records)              *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTRPT.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTOMER-FILE ASSIGN TO 'data/customers.dat'
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  CUSTOMER-FILE.
           COPY CUSTREC.

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS           PIC X(02).
       01  WS-EOF-FLAG              PIC X(01) VALUE 'N'.
           88  WS-EOF                   VALUE 'Y'.
       01  WS-IDX                   PIC 9(01).
       01  WS-COUNTERS.
           05  WS-RECORD-COUNT      PIC 9(05) VALUE ZERO.
           05  WS-CHILD-TOTAL       PIC 9(05) VALUE ZERO.
           05  WS-PENDING-COUNT     PIC 9(05) VALUE ZERO.
       01  WS-FAMILY-TUITION        PIC 9(09)V99 VALUE ZERO.
       01  WS-GRAND-TUITION         PIC 9(11)V99 VALUE ZERO.
       01  WS-GRAND-DUE             PIC 9(11)V99 VALUE ZERO.
       01  WS-DISPLAY-AMT           PIC ZZZ,ZZZ,ZZ9.99.
       01  WS-DISPLAY-CNT           PIC ZZ,ZZ9.
       01  WS-SEP-CHAR              PIC X(01).
       01  WS-DIVIDER               PIC X(48) VALUE SPACES.
       01  WS-ID-PREFIX             PIC X(03).
      *
      * DB2 version of the same read (needs the DB2 precompiler and
      * DCLCUST.cpy, so it is kept here as documentation):
      *    EXEC SQL
      *        SELECT CHAR(CUST_APP_DATE, ISO),
      *               SUBSTRING(CUST_EMIRATES_ID, 1, 3, OCTETS)
      *          INTO :CUSTOMER-APP-DATE, :WS-ID-PREFIX
      *          FROM CUSTOMER
      *         WHERE CUST_APP_NUMBER = :CUSTOMER-APP-NUMBER
      *    END-EXEC

       PROCEDURE DIVISION.
       MAIN-PARA.
      *    FUNCTION CHAR(n) returns the character at ordinal n.
      *    Ordinals start at 1, so CHAR(62) is '=' (ASCII 61).
           MOVE FUNCTION CHAR(62) TO WS-SEP-CHAR
           INSPECT WS-DIVIDER REPLACING ALL SPACE BY WS-SEP-CHAR

           OPEN INPUT CUSTOMER-FILE
           IF WS-FILE-STATUS NOT = '00'
               DISPLAY 'ERROR OPENING CUSTOMER FILE, STATUS: '
                       WS-FILE-STATUS
               STOP RUN
           END-IF

           DISPLAY WS-DIVIDER
           DISPLAY ' CUSTOMER FEE REPORT'
           DISPLAY WS-DIVIDER

           PERFORM READ-CUSTOMER
           PERFORM PROCESS-CUSTOMER UNTIL WS-EOF

           CLOSE CUSTOMER-FILE
           PERFORM PRINT-TOTALS
           STOP RUN.

       READ-CUSTOMER.
           READ CUSTOMER-FILE
               AT END SET WS-EOF TO TRUE
           END-READ.

       PROCESS-CUSTOMER.
           ADD 1 TO WS-RECORD-COUNT
           ADD CUST-CHILD-COUNT TO WS-CHILD-TOTAL
           IF CUST-STATUS = 'Pending Payment'
               ADD 1 TO WS-PENDING-COUNT
           END-IF

           MOVE ZERO TO WS-FAMILY-TUITION
           PERFORM VARYING WS-IDX FROM 1 BY 1
                   UNTIL WS-IDX > CUST-CHILD-COUNT
               ADD CHILD-TUITION-FEE (WS-IDX) TO WS-FAMILY-TUITION
           END-PERFORM
           ADD WS-FAMILY-TUITION TO WS-GRAND-TUITION
           ADD CUST-AMOUNT-DUE   TO WS-GRAND-DUE

           DISPLAY CUST-APP-NUMBER ' ' CUST-FULL-NAME
      *    Reference modification (start:length) is COBOL's
      *    equivalent of SUBSTRING(CUST-EMIRATES-ID, 1, 3).
           MOVE CUST-EMIRATES-ID(1:3) TO WS-ID-PREFIX
           DISPLAY '   ID prefix: ' WS-ID-PREFIX
           DISPLAY '   Status   : ' CUST-STATUS
           DISPLAY '   Children : ' CUST-CHILD-COUNT
           MOVE WS-FAMILY-TUITION TO WS-DISPLAY-AMT
           DISPLAY '   Tuition  : ' WS-DISPLAY-AMT ' AED'
           MOVE CUST-AMOUNT-DUE TO WS-DISPLAY-AMT
           DISPLAY '   Due now  : ' WS-DISPLAY-AMT ' AED'

           PERFORM READ-CUSTOMER.

       PRINT-TOTALS.
           DISPLAY WS-DIVIDER
           MOVE WS-RECORD-COUNT TO WS-DISPLAY-CNT
           DISPLAY ' Customers      : ' WS-DISPLAY-CNT
           MOVE WS-CHILD-TOTAL TO WS-DISPLAY-CNT
           DISPLAY ' Children       : ' WS-DISPLAY-CNT
           MOVE WS-PENDING-COUNT TO WS-DISPLAY-CNT
           DISPLAY ' Pending payment: ' WS-DISPLAY-CNT
           MOVE WS-GRAND-TUITION TO WS-DISPLAY-AMT
           DISPLAY ' Total tuition  : ' WS-DISPLAY-AMT ' AED'
           MOVE WS-GRAND-DUE TO WS-DISPLAY-AMT
           DISPLAY ' Total due now  : ' WS-DISPLAY-AMT ' AED'
           DISPLAY '================================================'.
