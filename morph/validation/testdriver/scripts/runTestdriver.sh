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
                rm -rf ${name}.${suffix}.* $tmp
        done
}

configDir=config
configValue=""
mkdir -p $configDir
# Configuration directory is READ-ONLY
chmod -R 550 $configDir

outputDir=validation
rm -rf $outputDir; mkdir $outputDir

root=$(pwd)
libstring=$(ls $root/lib/libfrvtmorph_*_?.so)
provider_frvt_lib_name="frvtmorph_"
provider_frvt_lib_name+="$frvt_provider"
provider_frvt_lib_name+="_"
provider_frvt_lib_name+="$frvt_sequence"

provider_frvt_driver_name="validatemorph_"
provider_frvt_driver_name+="$provider_frvt_lib_name"

# Usage: ../bin/validatemorph detectNonScannedMorph|detectScannedMorph|detectUnknownMorph|detectNonScannedMorphWithProbeImg|detectScannedMorphWithProbeImg|detectUnknownMorphWithProbeImg|compare -c configDir -o outputDir -i inputFile -t numForks
#   detectScannedMorph ...: task to process
#   configDir: configuration directory
#   configValue: configuration parameter string
#   outputDir: directory where output logs are written to
#   inputFile: input file containing images to process
#   numForks: number of processes to fork
echo "------------------------------"
echo " Running morph detection validation"
echo "------------------------------"

# Set number of child processes to fork()
numForks=2

for action in detectNonScannedMorph detectScannedMorph detectUnknownMorph detectNonScannedMorphWithProbeImg detectScannedMorphWithProbeImg detectUnknownMorphWithProbeImg compare
do
	inputFile=input/${action}.txt
	echo -n "Running $action "

	bin/$provider_frvt_driver_name $action -c $configDir -v "$configValue" -o $outputDir -i $inputFile -t $numForks -h $action
	retEnroll=$?
	if [[ $retEnroll == 0 ]]; then
		echo "[SUCCESS]"
		#Merge output files together
		merge $outputDir/$action log
	elif [[ $retEnroll == 2 ]]; then
		echo "[NOT IMPLEMENTED]"
	else
		echo "[ERROR] $action validation failed.  There were errors during validation.  Please investigate and re-run this script.  Please ensure you've followed the validation instructions in the README.txt file."
		exit
	fi
done


