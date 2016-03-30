#!/bin/bash

nohup /usr/bin/Xvfb :99 -ac -noreset &amp;
export DISPLAY=:99;

W3AF_SUITE="/java/exo-working/w3af_auto"
W3AF_FOLDER="${W3AF_SUITE}/tools/w3af"
W3AF_SCRIPT_FILE_PATH="${W3AF_SUITE}/"

W3AF_CONFIG_FILE_NAME="testscript.w3af"
W3AF_CONFIG_FILE_PATH="${W3AF_SUITE}/${W3AF_CONFIG_FILE_NAME}"
W3AF_TEST_TARGET_DIR="${W3AF_SUITE}/output/"
W3AF_TEST_CONFIG_DIR="${W3AF_SUITE}/temp"
W3AF_TEST_TARGET=`cd ${W3AF_TEST_TARGET_DIR}; ls w3af_test_targets_* -ABrt1 | tail -n1`
W3AF_TEST_RESULT="output-w3af.txt"

PLF_AUTHEN_URL="${PLF_HOST}/portal/login?initialURI=/portal/default\&username=root\&password=gtngtn"

SERVER_ACCESS_LOG_FILE=${SERVER_ACCESS_LOG}/localhost_access_log.$(date +"%Y-%m-%d").txt
PARSER_DIR="${W3AF_SUITE}/"
TEST_PATTERN="${PARSER_DIR}/test_pattern.txt"
W3AF_BLACKLIST_INPUT_DIR="${W3AF_SUITE}/blacklist/input"
mkdir -p ${W3AF_BLACKLIST_INPUT_DIR}
W3AF_BLACKLIST_INPUT_FILE=`cd ${W3AF_BLACKLIST_INPUT_DIR}; ls -ABrt1 --group-directories-first | tail -n1`
W3AF_BLACKLIST_OUTPUT_DIR="${W3AF_SUITE}/blacklist/output"
W3AF_BLACKLIST_OUTPUT_FILE=$W3AF_BLACKLIST_OUTPUT_DIR/"w3af_blacklist.txt"

cd ${W3AF_SCRIPT_FILE_PATH}
echo "==== WAITING FOR W3AF FINISHING ITS TASK ===="
bash w3af_start_script.sh -i ${W3AF_TEST_TARGET_DIR}${W3AF_TEST_TARGET} -d ${W3AF_FOLDER} -f ${W3AF_CONFIG_FILE_NAME} -p ${W3AF_CONFIG_FILE_PATH} -a ${PLF_AUTHEN_URL}|tee $W3AF_TEST_TARGET_DIR${JOB_NAME}_${BUILD_NUMBER}_Console_Jenkins_$(date +"%Y.%m.%d").txt

cd $W3AF_SCRIPT_FILE_PATH
bash w3af_auto_reporting.sh


WEEKLY_REPORT="${W3AF_SUITE}/weekly_report"
PLF_LOG="${W3AF_SUITE}/plf_log"
mkdir -p $WEEKLY_REPORT || true
cd $WEEKLY_REPORT
if [ -d "$(date +"%Y-%m-%d")" ]
then
        rm -R $(date +"%Y-%m-%d")
       mkdir $(date +"%Y-%m-%d")
else
	mkdir $(date +"%Y-%m-%d")
fi

chmod 777 $(date +"%Y-%m-%d")
cd $(date +"%Y-%m-%d")
cp ${W3AF_TEST_TARGET_DIR}/W3af_TestTarget*.txt .
cp $W3AF_FOLDER/output-w3af.* .
cp $PLF_LOG/localhost_access_log*.txt .
cp $W3AF_TEST_TARGET_DIR${JOB_NAME}_${BUILD_NUMBER}_Console_Jenkins_$(date +"%Y.%m.%d").txt .
cp ${W3AF_TEST_TARGET_DIR}report_$(date +"%Y.%m.%d").txt .