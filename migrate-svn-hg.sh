#!/bin/bash

# Prerequisites
# - hg
# - hg convert

# u - Undeclared variables
# x - Trace
# set -ux


# Arguments
SVN_URL=""
SVN_TRUNK=""
HG_LOCAL=""
SVN_TAGS=""
SVN_BRANCHES=""
HG_REMOTE=""
HG_AUTHOR_MAP=""
HG_BRANCH_MAP=""

while getopts "t:s:l:a:b:r:u:m:h" opt; do
  case "$opt" in
    s)
      SVN_URL=$OPTARG
      ;;
    t)
      SVN_TRUNK=$OPTARG
      ;;
    l)
      HG_LOCAL=$OPTARG
      ;;
    a)
      SVN_TAGS=$OPTARG
      ;;
    b)
      SVN_BRANCHES=$OPTARG
      ;;
    r)
      HG_REMOTE=$OPTARG
      ;;
    u)
      HG_AUTHOR_MAP=$OPTARG
      ;;
    m)
      HG_BRANCH_MAP=$OPTARG
      ;;
    h)
      echo "Usage:"
      echo "$0 -s <arg> -t <arg> -l <arg> [-a <arg>] [-b <arg>] [-r <arg>] [-u <arg>] [-m <arg>]"
      echo
      echo "Migrate your Subversion repository to a Mercurial repository."
      echo "-s URL of the SVN repository"
      echo "-t path to the SVN repository's trunk"
      echo "-l directory of the local HG repository"
      echo "-a path to the SVN repository's tags"
      echo "-b path to the SVN repository's branches"
      echo "-r URL of the remote HG repository"
      echo "-u path to file to remap user names"
      echo "-m path to file to remap branch names"
      exit
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [[ $# == 0 || "$SVN_URL" == "" || "$SVN_TRUNK" == "" || "$HG_LOCAL" == "" ]]; then
   echo "Need help? Use -h."
   exit
fi


# Error handling
ERR_1="Error 1: Missing argument"
ERR_2="Error 2: directory of local HG repository already exists"
ERR_3="Error 3: the file to remap user names does not exist"
ERR_4="Error 4: the file to remap branch names does not exist"

function exit_error
{
   case "$1" in
      1) echo $ERR_1
         exit $1
         ;;
      2) echo $ERR_2
         exit $1
         ;;
      3) echo $ERR_3
         exit $1
         ;;
      4) echo $ERR_4
         exit $1
         ;;
      0)
         ;;
      *) echo "Unknown error $1"
         exit 1
         ;;
   esac
}


# Steps
function hg_directory_exists()
{
   if [[ -d "$HG_LOCAL" ]]; then
      exit_error 2 
   fi
}

function author_map_exists()
{
   if [[ "$HG_AUTHOR_MAP" != "" && ! -f "$HG_AUTHOR_MAP" ]]; then
      exit_error 3 
   fi
}

function branch_map_exists()
{
   if [[ "$HG_BRANCH_MAP" != "" && ! -f "$HG_BRANCH_MAP" ]]; then
      exit_error 4
   fi
}

function convert()
{
   SVN_TRUNK_ARG="--config convert.svn.trunk=$SVN_TRUNK"
   SVN_BRANCHES_ARG=""
   SVN_TAGS_ARG=""

   if [[ "$SVN_BRANCHES" != "" ]]; then
      SVN_BRANCHES_ARG="--config convert.svn.branches=$SVN_BRANCHES"
   fi

   if [[ "$SVN_TAGS" != "" ]]; then
      SVN_TAGS_ARG="--config convert.svn.tags=$SVN_TAGS"
   fi

   AUTHOR_MAP_ARG=""
   BRANCH_MAP_ARG=""

   if [[ "$HG_AUTHOR_MAP" != "" ]]; then
      AUTHOR_MAP_ARG="--authormap $HG_AUTHOR_MAP"
   fi

   if [[ "$HG_BRANCH_MAP" != "" ]]; then
      BRANCH_MAP_ARG="--branchmap $HG_BRANCH_MAP"
   fi

   hg $SVN_TRUNK_ARG $SVN_BRANCHES_ARG $SVN_TAGS_ARG convert $SVN_URL $HG_LOCAL $AUTHOR_MAP_ARG $BRANCH_MAP_ARG
}

function push()
{
   if [[ "$HG_REMOTE" != "" ]]; then
       cd $HG_LOCAL
       hg push $HG_REMOTE
   fi
}


# Run
function main()
{
   hg_directory_exists
   author_map_exists
   branch_map_exists

   convert

   push

   exit 0
}

main
