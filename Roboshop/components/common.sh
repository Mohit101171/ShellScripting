#!bin/bash
status_check() {
    if [ $1 -ne 0 ]; then
        echo -e "\e[32mSUCCESS\e[0m"
    else
        echo -e "\e[33mFAILURE\e[0m"
        exit 2
    fi
} 