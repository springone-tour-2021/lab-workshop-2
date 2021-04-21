#!/bin/bash
# Install httpie
virtualenv /home/eduk8s/bin/httpie
source /home/eduk8s/bin/httpie/bin/activate
pip install httpie
deactivate
echo 'alias http="/home/eduk8s/bin/httpie/bin/http"' >> ~/.bash_profile
