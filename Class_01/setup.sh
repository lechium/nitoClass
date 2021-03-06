#!/bin/bash

## This script will likely be constantly changing as i find better ways to handle the different tasks involved. It is the introduction to my free #nitoClass on tvOS development 
## from start to finish. The goal of this class is to teach everything from normal application development and how it differs from iOS and macOS all the way until the most complex
## tweak development imaginable. There will be a companion slack or discord set up for this in addition to an old school forum. the awkwardtv wiki will be instrumental as well
## there MAY be a new more modernized wiki set up as well to be catered specifically to this class. 

## Class 1
## This script aims to analyze your system and automatically set up anything possible to make the initial process easier for you to get moving! 
## will make exhaustive comments as necessary in case you want to learn a little bit about shell scripting as well!
## bash scripting isnt my speciality, i can do it, but im not an expert. forgive the mess!

# linux notes
# https://raw.githubusercontent.com/lechium/nitoClass/master/toolchain-linux.tar.gz 
# https://iweb.dl.sourceforge.net/project/osboxes/v/vm/55-U--u/19.10/U-1910-VM-64bit.7z
# deb http://apt.llvm.org/eoan/ llvm-toolchain-eoan-10 main
# https://github.com/theos/theos/wiki/Installation-Linux

# sudo apt-get install fakeroot git perl clang-10.0 build-essential curl dpkg nvim
# echo "export THEOS=~/theos" >> ~/.profile
# git clone --recursive https://github.com/lechium/theos.git codegen $THEOS
# curl -O https://raw.githubusercontent.com/lechium/nitoClass/master/toolchain-linux.tar.gz
# tar fxpz toolchain-linux.tar.gz -C $THEOS/toolchain
# rm toolchain-linux.tar.gz

config_nvim() {
	echo "Configuring nvim..."
	mkdir -p ~/.config/nvim
	pushd ~/.config/nvim || return
	curl -O https://raw.githubusercontent.com/lechium/nitoClass/master/nvim/init.vim
	curl -O https://raw.githubusercontent.com/lechium/nitoClass/master/nvim/ycm_extra_conf.py
	popd || return
	
}

bail() {
	echo "$1"
	exit
}

install_ninja() {
	
	echo "Installing ninja and dpkg!"
	brew install ninja dpkg	
}

if [[ "$(uname)" = "Linux" ]]; then
	echo "on linux!"
	ALL=$(uname -a)
	ID=$(grep -i -m 1 ID /etc/os-release | cut -d = -f 2 | tr -d \")
	VID=$(grep -i -m 1 VERSION_ID /etc/os-release | cut -d = -f 2 | tr -d \")
	VC=$(grep -i -m 1 VERSION_CODENAME /etc/os-release | cut -d = -f 2 | tr -d \")
	echo "ID: $ID"
	if [[ $ID == "arch" ]]; then
		echo "ArchLinux"
		sudo pacman-key --refresh-keys
		sudo pacman -Sy archlinux-keyring
		sudo pacman -Su
		sudo pacman -S git perl curl dpkg neovim "python>=3.7" ctags cmake ruby libpng ninja python-pynvim python2 wget libxml2 clang rsync base-devel
		exit 1 # for now
	elif [[ $ID == "ubuntu" ]]; then
		echo "Ubuntu $VID ($VC)..."
		sudo apt-add-repository "deb http://apt.llvm.org/$VC/ llvm-toolchain-$VC-10 main"
		sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 15CF4D18AF4F7421
		sudo apt-get update
		echo "Installing packages through apt..."
		sudo apt-get install fakeroot git perl clang-10 build-essential curl dpkg neovim python3.7-dev exuberant-ctags cmake libpng-dev libpng16-16 libxml2-dev pkg-config ninja-build ruby
	elif [[ $ID == "centos" ]]; then
		echo "CentOS $VID..."
		sudo yum install git perl curl ctags cmake python3 ruby libpng wget libxml2 clang pkg-config vim lsb python3-devel python2 python2-devel neovim
		sudo yum groupinstall 'Development Tools'
	elif [[ $ID == "fedora" ]]; then
		echo "Fedora $VID..."
		sudo yum install git perl curl ctags cmake python3 ruby libpng wget libxml2 clang pkg-config vim lsb python3-devel python2 python2-devel neovim
		sudo yum groupinstall 'Development Tools'
	else
		echo "UnKnown flavor of Linux $ALL ..."
		exit 1
	fi
	echo "export THEOS=~/theos" >> ~/.profile
	# shellcheck disable=SC2016
	echo 'export PATH=$PATH:"$THEOS"/bin:~/xcbuild/build/' >> ~/.profile
	# shellcheck disable=SC1090
	source ~/.profile
	echo "Cloning theos..."
	git clone --recursive https://github.com/lechium/theos.git -b codegen "$THEOS"
	echo "Installing toolchain..."
	curl -O https://raw.githubusercontent.com/lechium/nitoClass/master/toolchain-8.tar.gz
	mkdir "$THEOS"/toolchain/linux 
	sudo mkdir -p /opt/local
	sudo tar fxz toolchain-8.tar.gz -C /opt/local/
	ln -s /opt/local/toolchain "$THEOS"/toolchain/linux/appletv

	## kabirs toolchain just in case
	curl https://kabiroberai.com/toolchain/download.php?toolchain=ios-linux -Lo toolchain.tar.gz
 	tar xzf toolchain.tar.gz -C "$THEOS"/toolchain
 	rm toolchain.tar.gz
	rm -rf "$THEOS"/sdks
	pushd "$THEOS" || bail "failed to pushd"
	echo "Cloning SDKs..."
	git clone https://github.com/lechium/sdks.git
	popd || bail "failed to popd"
	echo "Installing xcpretty..."
	sudo gem install xcpretty
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	# shellcheck disable=SC2016
	echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ~/.bash_profile
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	config_nvim
	echo "Checking for ninja..."
	# shellcheck disable=SC2091
	$(which ninja) || install_ninja
	echo "Cloning xcbuild..."
	git clone --depth=1 https://github.com/facebook/xcbuild
	pushd xcbuild || bail "failed to pushd xcbuild"
	git submodule update --init
	sed -i 's|-Werror||g' CMakeLists.txt
	echo "Making xcbuild..."
	make
	echo "to finish installing neovim and YouCompleteMe you must first run nvim :PlugInstall and then '~/.config/nvim/plugged/YouCompleteMe/install.py --clang-completer'"
	#pushd ~/.config/nvim/plugged/YouCompleteMe
	#./install.py
	exit 0
fi


## Essentials 

## macOS (for now)
## Xcode (for now)
## brew
## theos
## apt/dpkg
## some download links for reference https://download.developer.apple.com/Developer_Tools/Xcode_10.1/Xcode_10.1.xip
## https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_macOS_10.14_for_Xcode_10.2/Command_Line_Tools_macOS_10.14_for_Xcode_10.2.dmg
## https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_for_Xcode_11.3.1/Command_Line_Tools_for_Xcode_11.3.1.dmg
## https://download.developer.apple.com/Developer_Tools/Xcode_11.3.1/Xcode_11.3.1.xip
## https://download.developer.apple.com/Developer_Tools/Xcode_11.4/Xcode_11.4.xip
## account sign up page https://developer.apple.com/account/
## downloads: https://developer.apple.com/download/more/
## 10.13 = HS
## 10.14 = Mojavers
## 10.15 = Catalina
## 

EQUAL=0
GT=1
LT=2
bold=$(tput bold)
normal=$(tput sgr0)

OS_VERS=$(sw_vers -productVersion)
#OS_VERS="10.15.1"

HAS_XCODE=$(which xcode-select)
#CLANG_PATH=$(xcrun -f clang)
#CLANGPLUS_PATH=$(xcrun -f clang++)

# not sure of the licensing of this but ill figure it out later -
# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash 

vercomp () {
	if [[ "$1" == "$2" ]]
	then
		return 0
	fi
	local IFS=.
	local i ver1=("$1") ver2=("$2")
	# fill empty fields in ver1 with zeros
	for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
	do
		ver1[i]=0
	done
	for ((i=0; i<${#ver1[@]}; i++))
	do
		if [[ -z ${ver2[i]} ]]
		then
			# fill empty fields in ver2 with zeros
			ver2[i]=0
		fi
		if ((10#${ver1[i]} > 10#${ver2[i]}))
		then
			return 1

		fi
		if ((10#${ver1[i]} < 10#${ver2[i]}))
		then
			return 2
		fi
	done
	return 0
}

open_developer_account_site() {

	echo -e "\n\t${bold}** You need an apple developer account set up before continuing. Opening https://developer.apple.com/account in 3 seconds and then exiting.\n\tSetup an account and then run the script again.**\n\n"
	sleep 3
	open "https://developer.apple.com/account"
	exit 1
}

id_check() {
	echo -e "${bold} Do you have a Apple developer account? (Free acounts are sufficient) [y/n]: ${normal}\n"
	read -r idcheck
	if [ "$idcheck" == 'y' -o "$idcheck" == 'Y' ]; then
		return 0
	elif [ "$idcheck" == 'N' -o "$idcheck" == 'n' ]; then
		open_developer_account_site 
	fi 
	return 1
}

install_xcode() {

	vercomp "$OS_VERS" "10.15"
	CATPLUS="$?"
	vercomp "$OS_VERS" "10.14"
	MPLUS="$?"
	vercomp "$OS_VERS" "10.13"
	HSPLUS="$?"
	echo -e "OS Version: $OS_VERS\n"
	if [ $CATPLUS == $GT -o $CATPLUS == $EQUAL ]; then
		echo -e "Catalina detected\n"
		#open "https://download.developer.apple.com/Developer_Tools/Xcode_11.4/Xcode_11.4.xip"
		#open "https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_for_Xcode_11.4/Command_Line_Tools_for_Xcode_11.4.dmg"
	elif [ $MPLUS == $EQUAL -o $MPLUS == $GT  ]; then 
		echo -e "Mojave detected\n"
		#open "https://download.developer.apple.com/Developer_Tools/Xcode_11.3.1/Xcode_11.3.1.xip"
		#open "https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_for_Xcode_11.3.1/Command_Line_Tools_for_Xcode_11.3.1.dmg"
	elif [ $HSPLUS == $EQUAL -o $HSPLUS == $GT ]; then
		echo -e "High Sierra detected\n"
		#open "https://download.developer.apple.com/Developer_Tools/Xcode_10.1/Xcode_10.1.xip"
		#open "https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_macOS_10.13_for_Xcode_10/Command_Line_Tools_macOS_10.13_for_Xcode_10.dmg"
	fi

	id_check

	## make sure they have an apple id
	## make sure they are authenticated in their favorite web browser 
	## check OS version first to see which Xcode we can download
}

if [ -z "$HAS_XCODE" ]; then
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

