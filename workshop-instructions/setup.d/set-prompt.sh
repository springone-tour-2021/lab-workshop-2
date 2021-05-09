#!/bin/bash

echo 'export PS1_OLD="$PS1"' >> ~/.bash_profile
echo 'export PS1="\n\[\033[33m\]\w\$ \[\033[0m\]"' >> ~/.bash_profile
