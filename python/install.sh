#!/usr/bin/env bash

check_command() {
    if ! type $1 > /dev/null 2>&1; then
        echo "missing $1"
        exit 1
    fi
}

check_command python
check_command pip 
check_command virtualenv
source virtualenvwrapper_lazy.sh
workon default

pip install yapf

deactivate
