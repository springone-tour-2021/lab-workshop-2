#!/bin/bash

echo 'export PS1_OLD="$PS1"' >> ~/.bash_profile
echo 'export PS1="\e[;33m[\w]\$ \e[m "' >> ~/.bash_profile
