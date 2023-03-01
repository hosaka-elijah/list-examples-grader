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

grep -q "static List<String> filter(List<String> list, StringChecker sc) {" ListExamples.java
if [[ $? -ne 0 ]]
then 
    echo "Missing filter method signature"
    exit 1
fi

grep -q "static List<String> merge(List<String> list1, List<String> list2) {" ListExamples.java
if [[ $? -ne 0 ]]
then
    echo "Missing merge method signature"
    exit 1
fi

# Compile
javac -cp $CPATH *.java 2> compile.log
if [[ $? -eq 0 ]]
then
    echo "Compile successful"
else
    echo "Could not compile ListExamples.java"
    echo `cat compile.txt`
    exit 1
fi

# Run the tests
java -cp $CPATH org.junit.runner.JUnitCore TestListExamples > tester.log
grep -q "OK" tester.log
if [[ $? -eq 0 ]]
then
    echo "Score: 100 / 100"
else 
    # Parse results for number
    RESULT=`grep "Tests run:" tester.log`
    TESTS=${RESULT:11:1}  # or cut -b 12-
    FAILS=${RESULT:25:1} # or cut -b 26-
    SCORE=$((($TESTS - $FAILS) * 100 / $TESTS))
    echo "Score: $SCORE / 100"
    echo "test failed: testMergeRightEnd()"
fi