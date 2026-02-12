echo "Valid tests"
for f in tests/valid/*.txt; do
    echo "Running $f"
    ./limbaj "$f"
    echo
done

echo "Invalid tests"
for f in tests/invalid/*.txt; do
    echo "Running $f"
    ./limbaj "$f"
    echo
done