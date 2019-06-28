#!/bin/bash

clear

show_menu(){
echo ""
echo "===================================================="
echo "HELPER MENU"
echo "===================================================="
echo "1) show Orders App"
echo "2) show Keptn"
echo "3) show Dynatrace"
echo "===================================================="
echo "Please enter your choice or <q> or <return> to exit"
read opt
}

show_menu
while [ opt != "" ]
    do
    if [[ $opt = "" ]]; then 
        exit;
    else
        clear
        case $opt in

        1)
           ./showApp.sh  2>&1 | tee logs/showApp.log
           show_menu
           ;;
        2)
           ./showKeptn.sh  2>&1 | tee logs/showKeptn.log
           show_menu
           ;;
        3)
           ./showDynatrace.sh  2>&1 | tee logs/showDynatrace.log
           show_menu
           ;;
        q)
           break
           ;;
        *) 
           echo "invalid option"
           show_menu
           ;;
    esac
fi
done
