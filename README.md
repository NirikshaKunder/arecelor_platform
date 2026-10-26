# COBOL + Java Customer Record Demo

One fixed-width record layout, defined once in a COBOL copybook and read by both a COBOL batch program and a Java parser. It shows the classic mainframe-modernization pattern: the copybook is the contract, and Java reads the same files COBOL produces.

All sample data is fictional.

## Repository layout

```
cobol-java-customer-demo/
├── cobol/
│   ├── copybooks/CUSTREC.cpy      # 450-byte record layout (the contract)
│   └── programs/CUSTRPT.cbl       # COBOL batch report using COPY CUSTREC
├── data/
│   └── customers.dat              # 3 sample fixed-width records
├── java/
│   ├── pom.xml
│   └── src/
│       ├── main/java/com/example/custrec/
│       │   ├── CustomerRecord.java   # Java model of CUSTOMER-RECORD
│       │   ├── CopybookParser.java   # offsets mirror the PIC clauses
│       │   └── Main.java             # prints records as JSON + totals
│       └── test/java/com/example/custrec/
│           └── CopybookParserTest.java
├── build.sh                       # builds and runs both sides
└── .github/workflows/ci.yml       # GitHub Actions: COBOL + Java on every push
```

## Record layout (CUSTREC, 450 bytes)

| Field | PIC | Offset | Length |
| --- | --- | --- | --- |
| CUST-APP-NUMBER | X(17) | 0 | 17 |
| CUST-STATUS | X(15) | 17 | 15 |
| CUST-APP-DATE (YYYYMMDD) | 9(08) | 32 | 8 |
| CUST-FULL-NAME | X(40) | 40 | 40 |
| CUST-FIRST-NAME | X(20) | 80 | 20 |
| CUST-LAST-NAME | X(20) | 100 | 20 |
| CUST-GENDER (M/F) | X(01) | 120 | 1 |
| CUST-EMIRATES-ID | X(18) | 121 | 18 |
| CUST-DOB (YYYYMMDD) | 9(08) | 139 | 8 |
| CUST-NATIONALITY | X(15) | 147 | 15 |
| CUST-PHONE | X(15) | 162 | 15 |
| CUST-EMAIL | X(40) | 177 | 40 |
| CUST-ADDRESS | X(60) | 217 | 60 |
| CUST-CITY | X(20) | 277 | 20 |
| CUST-AMOUNT-DUE | 9(07)V99 | 297 | 9 |
| CUST-CHILD-COUNT | 9(01) | 306 | 1 |
| CUST-CHILD OCCURS 3 (47 bytes each) | | 307 | 141 |
| FILLER | X(02) | 448 | 2 |

Each child: first name X(20), DOB 9(08), current grade X(10), tuition fee 9(07)V99.
`V99` is an implied decimal point, so `000261600` means 2,616.00.

## Run it

Requirements: [GnuCOBOL](https://gnucobol.sourceforge.io/) 3.x, Java 17+, Maven 3.8+.

```bash
./build.sh
```

Or each side on its own:

```bash
# COBOL (run from the repo root so data/customers.dat resolves)
cobc -x -I cobol/copybooks -o build/custrpt cobol/programs/CUSTRPT.cbl
./build/custrpt

# Java
cd java
mvn package
java -jar target/custrec.jar ../data/customers.dat
```

Install GnuCOBOL with `sudo apt install gnucobol` (Ubuntu/Debian) or `brew install gnucobol` (macOS).

## Expected output

Both programs report the same totals:

```
Customers: 3 | Children: 6 | Pending: 2 | Tuition: 119,250.00 AED | Due: 5,990.00 AED
```
