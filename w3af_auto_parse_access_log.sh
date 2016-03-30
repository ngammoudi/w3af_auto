#!/bin/bash

if [ "${DEBUG}" == "true" ]; then
   set -xv
fi

TESTSUITE_DIR="/java/exo-working/w3af_auto/"
ACCESS_LOG_DIR="/java/exo-working/TC/current/logs/"
ACCESS_LOG=`cd ${ACCESS_LOG_DIR}; ls localhost_access_log* | tail -n1`

W3AF_TEST_TARGET_DIR="${TESTSUITE_DIR}/output"; mkdir -p ${W3AF_TEST_TARGET_DIR}
W3AF_TEST_TARGET="${W3AF_TEST_TARGET_DIR}/w3af_test_targets_$(date +"%Y-%m-%d").txt"
EXLCUDE_PATTERNS="${TESTSUITE_DIR}/test_exclude_patterns.txt"
PLF_HOST=${PLF_HOST:-"http://localhost:8080"}

cd ${TESTSUITE_DIR}
echo "==== WAITING FOR THE FILTERING PROCESS FINISHED ===="
bash w3af_auto_format_access_log_file.sh -i ${ACCESS_LOG_DIR}/${ACCESS_LOG} -o ${W3AF_TEST_TARGET} -h "${PLF_HOST}"
echo "==== Filter URLs ===="
while read pattern
do
  if [[ ! "x$pattern" == "x" && ! -z $pattern ]]; then
    pattern=`echo $pattern | sed 's|/|\\\/|g;s|?|\\\?|g;s|=|\\\=|g'`
    echo "... ++ processing with pattern: $pattern"
    # keep the first matched line
    sed -i -r "0,/$pattern/s/($pattern)/ \1/" $W3AF_TEST_TARGET

    # remove all of remaining lines
    sed -i -r "/$pattern/d" $W3AF_TEST_TARGET
    echo "... -- processing with pattern: $pattern"
  fi
done <$EXLCUDE_PATTERNS


#Move URLs without parameters to the end of file so that when scanning, those URLs will be scanned first
grep "?" $W3AF_TEST_TARGET | sort > /tmp/URL_param
echo "++URL with parameters = "$(wc -l /tmp/URL_param | awk '{ print $1}')	

sed '/?/d' $W3AF_TEST_TARGET | sort > /tmp/URL_no_param
echo "++URL without parameters = "$(wc -l /tmp/URL_no_param | awk '{ print $1}')

cat /tmp/URL_param /tmp/URL_no_param > $W3AF_TEST_TARGET

rm /tmp/URL_param
rm /tmp/URL_no_param