#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "please specify environment [dev|test|prod], eg: $0 dev"
    exit
fi

case $1 in
    prod) echo you are working on prod; echo Please check and press key to continue or ctrl-c to exit; read ;;
    dev | test ) ;;
    *) echo please specify correct parameters; exit 1;;
esac


ansible-playbook -i inventory.yml -e 'ansible_python_interpreter=/usr/bin/python3' openhab-$1.yml

echo "Executing tests against openhab-$1 vm instance:"
cd ../tests 
molecule verify -s openhab-$1
