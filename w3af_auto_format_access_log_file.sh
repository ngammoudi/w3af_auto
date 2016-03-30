#!/bin/bash
if [ "${DEBUG}" == "true" ]; then
   set -xv
fi

function usage
{
   echo "usage: parser.sh -i|--input_file input_file -o|--output output_file -h|--host address [-v|--version to show help]"
}
i=0
while [ "$1" != "" ]; do
    case $1 in
        -i | --input_file )	 input_file=$2
        	 i=`expr $i + 1`
                                ;;
        -o | --output )	 output_file=$2
        	 tmp_file=$output_file'.tmp'
        	 i=`expr $i + 1`
                                ;;
        -h | --host )           target_host=$2
        	 i=`expr $i + 1`
                                ;;
        -v | --version)	 usage
        	 exit
        	 ;;
   esac
    shift
    shift
done

#echo $input_file','$output_file','$target_host

if [ $i -lt 3 ]
then
	usage
exit
fi

if [[ -e $tmp_file ]]
then
	rm $tmp_file
fi

if [[ -e $input_file ]]
then	
	awk 'BEGIN{a="'$target_host'"}{print a$7}' $input_file > $tmp_file

	sort -u $tmp_file > $output_file
	rm $tmp_file
	echo "W3af file $output_file exported"
else
	echo "Access log file $intput_file does not exist."
fi


