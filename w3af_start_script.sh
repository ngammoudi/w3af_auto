#!/bin/bash

if [ "${DEBUG}" == "true" ]; then
   set -xv
fi
PYTHON=${PYTHON:-"python"}

function usage
{
 echo "usage: w3af_start_script.sh -i|--input w3af_test_target -d|--directory w3af_folder -f|--filename w3af_config_file_name -p|--filepath w3af_config_file_path -a|--authen authentication_url [-h|--to show help]"
}
i=0
while [ "$1" != "" ]; do
    case $1 in "-i" | "--input" ) w3af_test_target=$2; i=$((i+1));;
        -d | --directory ) w3af_folder=$2; i=$((i+1));;
        -f | --filename ) w3af_config_file_name=$2; i=$((i+1));;
        -p | --filepath ) w3af_config_file_path=$2; i=$((i+1));;
        -a | --authen ) authentication_url=$2 
         i=$((i+1))
                                ;;
        -U | --use_existing_data ) use_existing_data=$2
         i=$((i+1))
                                ;;
        -h | --help) usage
        exit
         ;;
   esac
	shift
	shift
done

# Check if user input is enough or not
if [ $i -lt 5 ]
then
  env
  usage
  exit
fi

# Check if "temp" folder exists or not. If exist, delete it and create a new one
parent=`pwd`
cd $parent
mkdir temp

if [[ -d $parent/temp && -z $use_existing_data ]]; then
  rm -rf $parent/temp

  mkdir temp

  # Read Parser's exported file (W3af_test_target) line by line 
  # and gradually insert to line which has {0} in newly-created W3af configuration files in "temp" folder
  file_lines_count=`wc -l $w3af_test_target | awk '{ print $1}' `
  #if [[ -d $pare -z $use_existing_data ]]; then
  h=0
  while read line
  do
    cd $parent/temp
    h=`expr $h + 1`
    echo "`date` processing at line $h of $file_lines_count ... "
    tmp=$w3af_config_file_name'.'$h
    new_config_file_path=$parent/temp/$tmp
    cp $w3af_config_file_path $new_config_file_path
    line=$authentication_url', '$line
    sed -i -e "s@{0}*@$line@" $new_config_file_path
    sed -i -e "s@output-w3af*@output-w3af.$h@" $new_config_file_path
  done < $w3af_test_target
fi
# If there is any config file in "temp" folder, run it with W3af tool. Deleted used one after that.
w3af_new_config_file_dir=$parent/temp/
#w3af_path=$parent/tools/w3af/
w3af_console_path=$w3af_folder/w3af_console

#tar cfvz ~/.w3af/sessions.tar.gz
while [ "$(ls -A $w3af_new_config_file_dir)" ]; do
      pushd $w3af_new_config_file_dir
      input=`ls -ABrt1 --group-directories-first | tail -n1`
      input_path="$w3af_new_config_file_dir/$input"
      cd $w3af_folder
      echo "`date` processing the file `readlink -f $input_path` ... "
      ${PYTHON} ${w3af_console_path} -s $input_path>>$input_path.output &
      pid=$!
      for counter in {1..1200}; do
	sleep 3
	#grep -c "Scan finished in" $input_path.output
	if [ `grep -c "Scan finished in" $input_path.output` -gt 0 ]; then
	  cat $input_path.output
	  kill -9 $pid
	  break;
	fi
      done
      
      cp $W3AF_FOLDER/output-w3af.html .
      cp $PLF_LOG/localhost_access_log*.txt .

      popd
      rm $input $input_path.output
      tar cfz ~/.w3af/sessions`date +%s`.tar.gz ~/.w3af/sessions -R
      rm -rf ~/.w3af/sessions
done

cd $parent
#rm -rf temp
