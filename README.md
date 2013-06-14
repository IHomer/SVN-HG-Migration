# SVN to HG migration scripts

This repository contains a couple of Bash scripts we used to migrate our Subversion repositories to Mercurial. These shouldn't be considered robust, _production ready_ scripts (even though they worked perfectly for us). **Use at your discretion!**


## Sync SVN

Synchronizes an SVN repository to a local SVN repository. 

This creates and synchronizes to a new local SVN repository and cannot be used to synchronize the repository at a later date (use `svnadmin sync /your/local/repo` for that).

	Usage:
	./sync-svn.sh -l <arg> -r <arg>

	Synchronize a remote SVN repository to a local SVN repository.
	-l path to the local SVN repository
	-r URL of the remote SVN repository

## Migrate to HG

Migrates an SVN repository to an HG repository.

**Immediately pushes the local HG repository to a remote repository if a URL for a remote repository is provided!**

	Usage:
	./migrate-svn-hg.sh -s <arg> -t <arg> -l <arg> [-a <arg>] [-b <arg>] [-r <arg>] [-u <arg>] [-m <arg>]

	Migrate your Subversion repository to a Mercurial repository.
	-s URL of the SVN repository
	-t path to the SVN repository's trunk
	-l directory of the local HG repository
	-a path to the SVN repository's tags
	-b path to the SVN repository's branches
	-r URL of the remote HG repository
	-u path to file to remap user names
	-m path to file to remap branch names