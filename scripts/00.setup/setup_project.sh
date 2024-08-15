#!/bin/bash

################################################################################
# SETUP PROJECT DIRECTORY WITH NECESSARY SCRIPTS AND DATA FILES
#
# This script should be run in the directory where the project folder will be generated
# This should typically be in your EBC/home/UUN folder
#
# This script copies and organizes the scripts and data files saved in the 
# shared location (e.g., EBC/processing) to your project folder and generates
# a PATHS.txt file. Larger data files (e.g., ROI files) won't be transferred
#
################################################################################

# usage documentation - shown if no project name is provided
Usage() {
	echo
	echo
	echo "Usage:"
	echo "./setup_project STUDY_NAME PROJECT_NAME"
	echo
	echo "You must provide (1) STUDY_NAME and (2) a PROJECT_NAME (with no spaces) so the associated project folder can be generated"
	echo
	echo "Example:"
	echo "./setup_project sgsss EMF"
	echo
	echo
	echo "This script only needs to be run once when setting up your project folder."
	echo
	echo "Script created by Melissa Thye and modified by Naiti Bhatt"
	echo
	exit
}
[ "$1" = "" ] | [ "$2" = "" ] && Usage

# define cohort
cohort=$1

# define project as text provided after script call
proj=$2

# define directories
dataDir="/RichardsonLab/processing" # location of shared files

# warn if the project directory already exists
if [ -d ${proj} ]
then
	echo
	echo "${proj} project directory already exists!"
	echo
	# rm -r ${proj} # could remove project directory
else
	# make project directories
	echo
	echo "making ${proj} project directory"
	echo

	mkdir ${proj}
	mkdir ${proj}/files
	mkdir ${proj}/scripts

	# create PATHS.txt file
	echo
	echo "saving project path to PATHS.txt file"
	echo

	echo $PWD/${proj} >> ${proj}/PATHS.txt

	# copy shared files to project directory
	echo
	echo "copying scripts and data files to project directory"
	echo

	cp -r ${dataDir}/scripts/. ${proj}/scripts
	cp -r ${dataDir}/subj_lists/. ${proj}/files/subj_lists
	cp -r ${dataDir}/event_files ${proj}/files
	cp -r ${dataDir}/contrast_files ${proj}/files
	cp -r ${dataDir}/ROI_timecourses ${proj}/files
	
	# copy example config file as template with motion thresholds that were already applied to data
	cp -r ${dataDir}/config_files/config-study_template.tsv ${proj}
fi

# optional, but nice to clean up environment
rm setup_project.sh
