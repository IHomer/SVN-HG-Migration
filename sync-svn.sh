#!/bin/bash

# Prerequisites
# - svnadmin
# - svnsync

# u - Undeclared variables
# x - Trace
# set -ux


# Arguments
SVN_LOCAL=""
SVN_REMOTE=""

while getopts "l:r:h" opt; do
    case "$opt" in
        l)
            SVN_LOCAL=$OPTARG
            ;;
        r)
            SVN_REMOTE=$OPTARG
            ;;
        h)
            echo "Usage:"
            echo "$0 -l <arg> -r <arg>"
            echo
            echo "Synchronize a remote SVN repository to a local SVN repository."
            echo "-l path to the local SVN repository"
            echo "-r URL of the remote SVN repository"
            exit
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done

if [[ $# == 0 || "$SVN_LOCAL" == "" || "$SVN_REMOTE" == "" ]]; then
    echo "Need help? Use -h."
    exit
fi


# Error handling
ERR_1="Error 1: Missing argument"
ERR_2="Error 2: directory of local SVN repository already exists"

function exit_error
{
    case "$1" in
        1) 
            echo $ERR_1
            exit $1
            ;;
        2) 
            echo $ERR_2
            exit $1
            ;;
        0)
            ;;
        *) 
            echo "Unknown error $1"
            exit 1
            ;;
    esac
}


# Steps
function svn_directory_exists()
{
    if [[ -d "$SVN_LOCAL" ]]; then
        exit_error 2 
    fi
}

function create_svn_repo()
{
    svnadmin create $SVN_LOCAL
}

function init_svn_repo()
{
    echo '#!/bin/sh' > $SVN_LOCAL/hooks/pre-revprop-change
    chmod +x $SVN_LOCAL/hooks/pre-revprop-change
    svnsync init file://`pwd`/$SVN_LOCAL $SVN_REMOTE
}

function sync_svn_repo()
{
    svnsync sync file://`pwd`/$SVN_LOCAL
}


# Run
function main()
{
    svn_directory_exists

    create_svn_repo
    init_svn_repo
    sync_svn_repo

    exit 0
}

main