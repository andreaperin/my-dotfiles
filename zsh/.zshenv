#!/bin/zsh
#
# .zshenv - Zsh environment file, loaded always.

# NOTE: .zshenv needs to live at ~/.zshenv, not in $ZDOTDIR!

# Set ZDOTDIR if you want to re-home Zsh.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export ZDOTDIR=$XDG_CONFIG_HOME/zsh

# You can use .zprofile to set environment vars for non-login, non-interactive shells.
if [[ ( ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprofile"
fi
