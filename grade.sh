CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

rm -rf student-submission
git clone $1 student-submission
echo 'Finished cloning'

# Check if student code has the correct file submitted
if [[ -f student-submission/ListExamples.java ]]
then
    echo "ListExamples found"
else
    echo "Need file ListExamples.java"
    exit 1
fi

# Copy the test file and library into same directory as student's code
cd student-submission
cp ../TestListExamples.java ./
cp -R ../lib ./

# Compile
javac -cp $CPATH *.java 2> log.txt
if [[ $? -eq 0 ]]
then
    echo "Compile successful"
else
    echo "Could not compile ListExamples.java"
    echo `cat log.txt`
    exit 1
fi

# Run the tests
java -cp $CPATH org.junit.runner.JUnitCore TestListExamples > log.txt
grep -q "OK" log.txt
if [[ $? -eq 0 ]]
then
    echo "Score: 100 / 100"
else 
    # Parse results for number
    RESULT=`grep "Tests run:" log.txt`
    TESTS=${RESULT:11:1}  # or cut -b 12-
    FAILS=${RESULT:25:1} # or cut -b 26-
    SCORE=$((($TESTS - $FAILS) * 100 / $TESTS))
    echo "Score: $SCORE / 100"
fi