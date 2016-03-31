#!/bin/bash 
if [ "${DEBUG}" == "true" ]; then
   set -xv
fi

cd output/
JENKIN_LOG_JOB="${JOB_NAME}_${BUILD_NUMBER}_Console_Jenkins_$(date +"%Y.%m.%d").txt"
chmod 777 $JENKIN_LOG_JOB
TEST_PATTERN="/java/exo-working/w3af_auto/test_pattern_results.txt"
grep "was found at" $JENKIN_LOG_JOB> defect_list_$(date +"%Y.%m.%d").txt
DEFECT_LIST="defect_list_$(date +"%Y.%m.%d").txt"
chmod 777 $DEFECT_LIST
sed -i -r 's/This vul[^.]+[.]/ /g' $DEFECT_LIST
sort $DEFECT_LIST|uniq >report_$(date +"%Y.%m.%d").txt
REPORT="report_$(date +"%Y.%m.%d").txt"
chmod 777 $REPORT

echo "======== ======== Processing for investigated defects ======== ======== "

while read j
do   
    if [[ ! "x$j" == "x" && ! -z $j ]]; then
      j=`echo $j | sed 's|/|\\\/|g'`
      echo "... pattern: $j"
      sed -i -r "0,/$j/s/($j)/+\1/" $REPORT
      sed -i -r "/$j/d" $REPORT  
    fi
done <$TEST_PATTERN
echo "----------------------------------------------------------------------------------------------------------------"
echo "|                                                                                                               |"
echo "|                                               AUTOMATION TEST REPORT                                          |"
echo "|                                                                                                               |"
echo "----------------------------------------------------------------------------------------------------------------" 

echo " *****Total defect is `wc -l $REPORT`*****"

echo "----------------------------------------------------------------------------------------------------------------"
echo "|                                          LIST OF DEFECT                                                       "
while read j
do   
    if [[ ! "x$j" == "x" && ! -z $j ]]; then
	echo "| $j                                                                                                                                     "
echo "------------------------------------------------------------------------------------------------------" 
    fi
done<$REPORT



