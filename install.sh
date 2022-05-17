#! /bin/bash

echo "Working in"
echo "- $(pwd)"

echo Installing zsh plugins
echo ---------------------- \n

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  # install oh my zsh
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# auto complete for zsh
# git clone https://github.com/zsh-users/zsh-autosuggestions \
#   ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# git clone https://github.com/zsh-users/zsh-syntax-highlighting \
#   ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting


# Link dotfiles
#
echo
echo Linking dotfiles
echo ----------------
echo

HOMEDIR=$HOME
BACKUPDIR="$HOMEDIR/.dotfiles.backups"
CURRENTDIR=$(pwd -P)
DOTFILEDIR="$CURRENTDIR/dotfiles"

backup_dotfile() {
  if [[ -e "$HOMEDIR/$1" ]]; then

    # Do we already have any backups? How many?
    # This needs some work. Doesn't handle things like
    # $BACKUPDIR/.vim* and $BACKUPDIR/.vimrc* well
    dotfile_count=$(find $BACKUPDIR/$1* -maxdepth 0 2> /dev/null | wc -l | sed 's/ //g')

    if [[ $dotfile_count -ne '0' ]]; then
      mv $HOMEDIR/$1 $BACKUPDIR/$1.$dotfile_count
    else
      mv $HOMEDIR/$1 $BACKUPDIR/$1
    fi
  fi
}

symlink_dotfile() {
  ln -sf $DOTFILEDIR/$1 $HOMEDIR/$1
}


if [[ ! -e $BACKUPDIR ]]; then
  echo "Creating back ups folder $BACKUPDIR..."
  mkdir $BACKUPDIR
fi

dotfiles=$(ls -1 -A $DOTFILEDIR 2> /dev/null)

if [[ $dotfiles ]]; then
  echo "Symlinking dotfiles..."

  for dotfile in $dotfiles; do
    echo "$dotfile"
    backup_dotfile $dotfile
    symlink_dotfile $dotfile
  done

  echo "All set! Any existing files were moved to $BACKUPDIR"

else
  echo "You don't have anything in '$DOTFILEDIR'"
fi

if [ -f /etc/zsh/zshrc.default.inc.zsh ]; then
  # assume that this default file will load our .zshrc.d/* files
  rsync -avh /etc/zsh/zshrc.default.inc.zsh "${HOME}/.zshrc"
else
  # if this replaces an existing config, check $HOME/.zshrc.pre-oh-my-zsh
  rsync -avh .zshrc "${HOME}/.zshrc"
fi

if [[ $SPIN ]]; then
  git config --global user.email "justina.chua@shopify.com"
  git config --global user.name "Justina Chua"
  git config --global --unset-all credential.helper
fi
