#!/bin/bash

#
# =====================================================================================
#
#       Filename:  install_jdk.sh
#
#    Description:  This is the snake program
#
#        Version:  1.0
#        Created:  07/15/2014 22:24:06
#       Revision:  initial version
#          Shell:  bash      
#
#         Author:  Andrew Grammenos (andreas.grammenos@gmail.com) 
#   Organization:  FSF
#
# =====================================================================================
#

#
#   Globals
#

installdir="/opt";                  # jdk installation dir
jdktmp="/tmp/jdktmp"                # temporary directory
profileloc="/etc/profile"           # profile file location
jdkzname=$1;                        # jdk zip filename
jdkfname="";                        # jdk folder name
jdkpath="";                         # jdk install path

# nornmal java paths to be symlinked
jpath="/usr/bin/java";
jcpath="/usr/bin/javac";
jwspath="/usr/bin/javaws";

hmsg="Script halted,";          # script halt message
umsg="usage: $0 jdkzipfile";    # usage message

#
#   Functions
#

promt() {
    echo $1;
    return $TRUE;
}

# check number of input arguments
argcheck() {
    if [[ $1 -ne $2 ]]; then 
        echo "$hmsg invalid number of arguments... $3"; 
        exit; 
    fi
}

# untar and uncompress the archive
uncompress() {
    # create temporary directory
    mkdir -p $jdktmp;
    # try to uncompress
    tar -xzf $1 -C $jdktmp > /dev/null 2>&1
    # check the result
    if [[ $? -ne 0 ]]; then
      echo "$hmsg cannot uncompress file...";
      exit;  
    fi
    # update path and install variables
    jdkfname="$(ls $jdktmp)";
    jdkpath="$installdir/$jdkfname";
}

# move the directory
mvdir() {
    sudo mv "$jdktmp/$jdkfname" $installdir > /dev/null 2>&1;
    # check the result
    if [[ $? -ne 0 ]]; then
      echo "$hmsg cannot move the file, delete existing directory (if present)";
      exit;  
    fi    
}

# update profile file
uprof() {
    if [[ ! -f $1 ]]; then
        echo "$hmsg $1 was not found...";
        exit;
    fi
    
    # let's update the profile file
    echo -e $profcont | sudo tee -a $1 > /dev/null 2>&1;
}

# install updated alternatives
ualt() {
    # install the alternatives
    sudo update-alternatives --install "$jpath" "java" "$jdkpath/jre/bin/java" 1 > /dev/null 2>&1;
    sudo update-alternatives --install "$jcpath" "javac" "$jdkpath/bin/javac" 1 > /dev/null 2>&1;
    sudo update-alternatives --install "$jwspath" "javaws" "$jdkpath/bin/javaws" 1 > /dev/null 2>&1;
 
    # inform OS that we need to set them as the default one
    sudo update-alternatives --set java "$jdkpath/jre/bin/java" > /dev/null 2>&1;
    sudo update-alternatives --set javac "$jdkpath/bin/javac" > /dev/null 2>&1;
    sudo update-alternatives --set javaws "$jdkpath/bin/javaws" > /dev/null 2>&1;
}

#
#   Script logic
#

# initial version
java -version

# check number of arguments
argcheck $# 1 $umsg;

# uncompress the file
uncompress $1;

# move the files
mvdir;

# profile append contents
profcont="\nJAVA_HOME=$jdkpath
\nJRE_HOME=$jdkpath/jre
\nPATH=$PATH:$JAVA_HOME:$JRE_HOME
\nexport JAVA_HOME
\nexport JRE_HOME
\nexport PATH";

# update the profile file
#uprof $profileloc
uprof $profileloc;

# install/set alternatives
ualt;

# source the profile
source $profileloc

# end version check; this should show that Oracle JDK is the default one now
java -version

# the end...
