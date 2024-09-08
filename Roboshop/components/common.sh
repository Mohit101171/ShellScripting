#!bin/bash
status_check() {
    if [ $1 -eq 0 ]; then
        echo -e "\e[32mSUCCESS\e[0m"
    else
        echo -e "\e[31mFAILURE\e[0m"
        exit 2
    fi
} 

print() {
    echo -n -e "$1 "
}