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

       PROCEDURE DIVISION.
       MAIN-PARA.
           OPEN INPUT CUSTOMER-FILE
           IF WS-FILE-STATUS NOT = '00'
               DISPLAY 'ERROR OPENING CUSTOMER FILE, STATUS: '
                       WS-FILE-STATUS
               STOP RUN
           END-IF

           DISPLAY '================================================'
           DISPLAY ' CUSTOMER FEE REPORT'
           DISPLAY '================================================'

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
           DISPLAY '   Status   : ' CUST-STATUS
           DISPLAY '   Children : ' CUST-CHILD-COUNT
           MOVE WS-FAMILY-TUITION TO WS-DISPLAY-AMT
           DISPLAY '   Tuition  : ' WS-DISPLAY-AMT ' AED'
           MOVE CUST-AMOUNT-DUE TO WS-DISPLAY-AMT
           DISPLAY '   Due now  : ' WS-DISPLAY-AMT ' AED'

           PERFORM READ-CUSTOMER.

       PRINT-TOTALS.
           DISPLAY '================================================'
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
