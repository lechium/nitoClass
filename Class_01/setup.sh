#!/bin/bash

## This script will likely be constantly changing as i find better ways to handle the different tasks involved. It is the introduction to my free #nitoClass on tvOS development 
## from start to finish. The goal of this class is to teach everything from normal application development and how it differs from iOS and macOS all the way until the most complex
## tweak development imaginable. There will be a companion slack or discord set up for this in addition to an old school forum. the awkwardtv wiki will be instrumental as well
## there MAY be a new more modernized wiki set up as well to be catered specifically to this class. 

## Class 1
## This script aims to analyze your system and automatically set up anything possible to make the initial process easier for you to get moving! 
## will make exhaustive comments as necessary in case you want to learn a little bit about shell scripting as well!

## Essentials 

## macOS (for now)
## Xcode (for now)
## brew
## theos
## apt/dpkg
## some download links for reference https://download.developer.apple.com/Developer_Tools/Xcode_10.1/Xcode_10.1.xip
## https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_macOS_10.13_for_Xcode_10/Command_Line_Tools_macOS_10.13_for_Xcode_10.dmg
## https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_macOS_10.14_for_Xcode_10.2/Command_Line_Tools_macOS_10.14_for_Xcode_10.2.dmg
## https://download.developer.apple.com/Developer_Tools/Xcode_11.3.1/Xcode_11.3.1.xip
## https://download.developer.apple.com/Developer_Tools/Xcode_11.4/Xcode_11.4.xip
## account sign up page https://developer.apple.com/account/
## downloads: https://developer.apple.com/download/more/

## 

bold=$(tput bold)
normal=$(tput sgr0)

OS_VERS="`sw_vers -productVersion`"

HAS_XCODE="`which xcode-select`"
CLANG_PATH="`xcrun -f clang`"
CLANGPLUS_PATH="`xcrun -f clang++`"

open_developer_account_site() {

		echo -e "\n\t${bold}** You need an apple developer account set up before continuing. Opening https://developer.apple.com/account in 3 seconds and then exiting.\n\tSetup an account and then rung the script again.**\n\n"
		sleep 3
		open "https://developer.apple.com/account"
		exit 1
}

id_check() {
	echo -e "Do you have a Apple developer account? (Yes free acounts are sufficient) [y/n]: "
	read idcheck
	if [ $idcheck == 'y' ]; then
		echo ""
	elif [ $idcheck == 'Y' ] ; then
		echo ""
	elif [ $idcheck == 'N' ]; then
		open_developer_account_site 
	elif [ $idcheck == 'n' ]; then
		open_developer_account_site 
	fi 
}

install_xcode() {

	echo "OS Version detected: $OS_VERS"

	id_check

	## make sure they have an apple id
	## make sure they are authenticated in their favorite web browser 
	## check OS version first to see which Xcode we can download
}

if [ -z $HAS_XCODE ]; then
	echo -e "Xcode & its command line tools are required to continue"
	exit 1
else
	echo -e "Xcode exists, continue!\n"
## if you are wondering why this is here, since i have xcode installed im lazily testing the negative path here instead to make sure it works for you.
	install_xcode

fi

usage() {
	echo "usage: $0 [-h|--help]" 
	exit 0
}


while test $# -gt 0; do 
	case "$1" in 
		-h|--help)
			usage
			;;
		*)
			break
			;;

		esac 
	done

