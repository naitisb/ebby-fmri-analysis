#!/bin/bash

################################################################################
# GENERATE THE SCANS.TSV FILE THAT WILL BE USED TO MARK RUN EXCLUSIONS
# 
# More information on these files: 
#	https://bids-specification.readthedocs.io/en/stable/modality-agnostic-files.html#scans-file
################################################################################

# usage documentation - shown if no text file is provided
Usage() {
    echo
    echo "Usage:"
    echo "./generate_scanfiles.sh <list of subjects>"
    echo
    echo "Example:"
    echo "./generate_scanfiles.sh list.txt"
    echo 
    echo "list.txt is a file containing the participants to generate the scans.tsv file for:"
    echo "001"
    echo "002"
	echo "..."
    echo
	echo
    echo "Script created by Melissa Thye"
    echo
    exit
}
[ "$1" = "" ] && Usage

# indicate whether session folders are used (always 'yes' for EBC data)
sessions='yes'

# extract sample from list of subjects filename (i.e., are these pilot or HV subjs)
sample=` basename $1 | cut -d '-' -f 3 | cut -d '.' -f 1 `

# define data directories depending on sample information
if [[ ${sample} == 'pilot' ]]
then
	bidsDir="/EBC/preprocessedData/TEBC-5y/BIDs_data/pilot"
	derivDir="/EBC/preprocessedData/TEBC-5y/derivatives/pilot"
elif [[ ${sample} == 'HV' ]]
then
	bidsDir="/EBC/preprocessedData/TEBC-5y-adultpilot/BIDs_data"
	derivDir="/EBC/preprocessedData/TEBC-5y-adultpilot/derivatives"
else
	bidsDir="/EBC/preprocessedData/TEBC-5y/BIDs_data"
	derivDir="/EBC/preprocessedData/TEBC-5y/derivatives"
fi

# print confirmation of sample and directory
echo 'Generating events.tsv files for' ${sample} 'data in' ${derivDir}

# iterate over subjects
while read p
do
	sub=$(echo ${p} |awk '{print $1}')
	
	# define subject derivatives directory depending on whether data are organized in session folders
	if [[ ${sessions} == 'yes' ]]
	then
		subDir_bids="${bidsDir}/sub-${sub}/ses-01/func"
		subDir_deriv="${derivDir}/sub-${sub}/ses-01/func"
		scan_file="sub-${sub}_ses-01_scans.tsv"
	else
		subDir_bids="${bidsDir}/sub-${sub}/func"
		subDir_deriv="${derivDir}/sub-${sub}/func"
		scan_file="sub-${sub}_scans.tsv"
	fi
	
	# create scan.tsv file for each subject who has functional data
	if [ -d ${subDir_bids} ] # if the subject has a functional data folder
	then
		echo "Generating scans.tsv file for sub-${sub}"

		# delete scans.tsv file if it already exists
		if [ -f ${subDir_bids}/${scan_file} ] || [ -f ${subDir_deriv}/${scan_file} ] 
		then 
			rm ${subDir_bids}/${scan_file}
			rm ${subDir_deriv}/${scan_file}
		fi
		
		# print run info to scan.tsv file
		printf "filename" >>  ${subDir_bids}/${scan_file}
	
		# list of functional files
		files=(`ls ${subDir_bids}/*nii.gz`)
		
		# for each file in the func directory, add filename to scans.tsv file
		for f in ${files[@]}
		do
			# extract file name (remove full path)
			current=`basename ${f}`
		
			# add file name (with directory) to scans.tsv file
			name=""
			name='\nfunc/'${current}
			printf ${name} >> ${subDir_bids}/${scan_file}
		done
	fi
	
	# copy scans.tsv to derivDir
	cp ${subDir_bids}/${scan_file} ${subDir_deriv}/${scan_file}
	
done <$1

