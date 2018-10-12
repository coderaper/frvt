#!/bin/bash

if [ "$#" -ne 2 ];
then
    me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
    echo -e "  Usage:\n    ${me} <provider> <sequence>\n" >&2
    echo -e "  Example:\n    ${me} Cognitec 0\n" >&2
    exit
fi

frvt_provider=$1
frvt_sequence=$2

# Function to merge output files together
# merge "filename"
function merge() {
        name=$1; shift; suffixes="$*"
        for suffix in $suffixes
        do
                tmp=`dirname $name`
                tmp=$tmp/tmp.txt
                firstfile=`ls ${name}.${suffix}.* | head -n1`
                # Get header
                head -n1 $firstfile > $tmp
                sed -i "1d" ${name}.${suffix}.*
                cat ${name}.${suffix}.* >> $tmp
                mv $tmp ${name}.${suffix}
                rm -rf ${name}.${suffix}.*
        done
}

# Configuration directory is always READ-ONLY
configDir=config
chmod -R 550 $configDir

outputDir=validation
templatesDir=$outputDir/templates
rm -rf $outputDir 
mkdir -p $templatesDir

root=$(pwd)
libstring=$(ls $root/lib/libfrvt11_*_?.so)
provider_frvt_lib_name="frvt11_"
provider_frvt_lib_name+="$frvt_provider"
provider_frvt_lib_name+="_"
provider_frvt_lib_name+="$frvt_sequence"
provider_frvt_lib_name+="_cpu"

provider_frvt_driver_name="validate11_"
provider_frvt_driver_name+="$provider_frvt_lib_name"

# Usage: ../bin/validate11 enroll|verif|match -c configDir -o outputDir -h outputStem -i inputFile -t numForks -j templatesDir
#   enroll|verif|match: task to process
#	enroll: generate enrollment templates
#	verif: generate verification templates
#	match: perform matching of templates
#   configDir: configuration directory
#   outputDir: directory where output logs are written to
#   outputStem: the string to prefix the output filename(s) with
#   inputFile: input file containing images to process (required enroll and verif template creation)
#   numForks: number of processes to fork
#   templatesDir: directory where templates are written to/read from
echo "------------------------------"
echo " Running 1:1 validation"
echo "------------------------------"

# Set number of child processes to fork()
numForks=1
echo -n "Creating Enrollment Templates (Single Process) "
inputFile=input/enroll.txt
outputStem=enroll
bin/$provider_frvt_driver_name enroll -c $configDir -o $outputDir -h $outputStem -i $inputFile -t $numForks -j $templatesDir
retEnroll=$?
if [[ $retEnroll == 0 ]]; then
	echo "[SUCCESS]" 
	# Merge output files together
	merge $outputDir/$outputStem log
else
	echo "[ERROR] Enrollment template creation validation (single process) failed"
	exit
fi

rm -rf $outputDir; mkdir -p $templatesDir
numForks=4

echo -n "Creating Enrollment Templates (Multiple Processes) "
bin/$provider_frvt_driver_name enroll -c $configDir -o $outputDir -h $outputStem -i $inputFile -t $numForks -j $templatesDir
retEnroll=$?
if [[ $retEnroll == 0 ]]; then
	echo "[SUCCESS]"
	# Merge output files together
	merge $outputDir/$outputStem log
else
	echo "[ERROR] Enrollment template creation validation (multiple process) failed.  Please ensure your software is compatible with fork(2)."
	exit
fi
echo -n "Creating Verification Templates (Multiple Processes) "
inputFile=input/verif.txt
outputStem=verif
bin/$provider_frvt_driver_name verif -c $configDir -o $outputDir -h $outputStem -i $inputFile -t $numForks -j $templatesDir
retVerif=$?
if [[ $retVerif == 0 ]]; then
	echo "[SUCCESS]" 
	# Merge output files together
	merge $outputDir/$outputStem log
else
	echo "[ERROR] Verification template creation validation failed"
	exit
fi

echo -n "Matching Templates (Multiple Processes) "
inputFile=input/match.txt
outputStem=match
bin/$provider_frvt_driver_name match -c $configDir -o $outputDir -h $outputStem -i $inputFile -t $numForks -j $templatesDir
retMatch=$?
if [[ $retMatch == 0 ]]; then
	echo "[SUCCESS]"
	# Merge output files together
	merge $outputDir/$outputStem log
else
	echo "[ERROR] Match validation failed"
	exit 
fi

if [[ $retEnroll != 0 ]] || [[ $retVerif != 0 ]] || [[ $retMatch != 0 ]]; then
	echo "There were errors during validation.  Please investigate and re-run this script.  Please ensure you've followed the validation instructions in the README.txt file."
fi

