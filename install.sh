#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home 
# directory to any desired dotfiles in ~/dotfiles
############################


SCRIPT=$(readlink -f $0)
BASE_DIR=`dirname $SCRIPT`

USERNAME=$(id -un)
THISHOST=$(hostname -f)

USER_HOME=$(eval echo ~${SUDO_USER})

configs=$BASE_DIR/configs 
host_archive="$BASE_DIR/archive/$USERNAME-$THISHOST" 

config_files="vimrc vim zshrc bashrc gitconfig"    # list of files/folders to symlink in homedir

function log()
{
	echo "$1"
}

function apply_diff()
{
	old=$1;new=$2;dot=""
	if [[ $new == $USER_HOME ]]; then
		dot="."
	fi

	for config in $config_files; do
		log 
		if [[ ! -e $old/$config ]]; then
			log "$config - new file" 
			cp -r $new/$dot$config $old/$config
			continue
		fi
		
		diff -r $old/$config $new/$dot$config
		if [[ ! $? == 0 ]]; then
			meld $old/$config $new/$dot$config
		fi
	done
}

function copy_all()
{
	from=$1;destination=$2;dot=""
	if [[ $from == $USER_HOME ]]; then
		dot="."
	fi

	for config in $config_files; do
		log "cp -r $from/$dot$config $destination/$config"
		cp -r $from/$dot$config $destination/$config
	done
}

function update_archive()
{
	if [[ ! -d "$host_archive" ]]; then
		log "$host_archive - new host"

		mkdir -p $host_archive
		copy_all ~ $host_archive
	else 
		apply_diff $host_archive $USER_HOME
	fi
}

function update_configs()
{
	if [[ ! -d "$configs" ]]; then
		mkdir -p $configs
	fi
	apply_diff $configs $host_archive
	
}



update_archive
update_configs

exit 1
# create dotfiles_old in homedir
echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir
echo "done"

# change to the dotfiles directory
echo -n "Changing to the $dir directory ..."
cd $dir
echo "done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
for file in $files; do
    echo "Copy $file from ~ to $olddir"
    cp  -r ~/.$file ~/dotfiles_old/
    # echo "Creating symlink to $file in home directory."
    # ln -s $dir/$file ~/.$file
done

install_zsh () {
# Test to see if zshell is installed.  If it is:
if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Clone my oh-my-zsh repository from GitHub only if it isn't already present
    if [[ ! -d $dir/oh-my-zsh/ ]]; then
        git clone http://github.com/michaeljsmalley/oh-my-zsh.git
    fi
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
        chsh -s $(which zsh)
    fi
else
    # If zsh isn't installed, get the platform of the current machine
    platform=$(uname);
    # If the platform is Linux, try an apt-get to install zsh and then recurse
    if [[ $platform == 'Linux' ]]; then
        sudo apt-get install zsh
        install_zsh
    # If the platform is OS X, tell the user to install zsh :)
    elif [[ $platform == 'Darwin' ]]; then
        echo "Please install zsh, then re-run this script!"
        exit
    fi
fi
}

# install_zsh
