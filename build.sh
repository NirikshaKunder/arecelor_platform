#!/usr/bin/env bash
# Builds and runs the COBOL report and the Java parser against the same data file.
set -euo pipefail
cd "$(dirname "$0")"

echo "== COBOL =="
mkdir -p build
cobc -x -I cobol/copybooks -o build/custrpt cobol/programs/CUSTRPT.cbl
./build/custrpt

echo
echo "== Java =="
(cd java && mvn -q -B package && java -jar target/custrec.jar ../data/customers.dat)
