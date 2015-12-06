#!/bin/bash

# Gimme a huge history
export HISTSIZE=50000

# Don't store duplicate lines in history
export HISTCONTROL=ignoreboth

# Apend to history instead of overwriting
shopt -s histappend
