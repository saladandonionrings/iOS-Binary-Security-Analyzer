#!/bin/bash

if [ $# -eq 0 ] || [ "$1" = "-h" ]; then
    echo "No binary provided. Usage: ./check-binary.sh <binary>"
    exit 1
fi

binary=$1
functions=("_random" "_srand" "_rand" "_gets" "_memcpy" "_strncpy" "_strlen" "_vsnprintf" "_sscanf" "_strtok" "_alloca" "_sprintf" "_printf" "_vsprintf" "_malloc")
echo "[*] Checking usage of unsafe and insecure functions in binary"
echo ""
printf "%-15s | %s\n" "Functions" "Value Identified"
printf "%-15s | %s\n" "-------------" "-------------------------------"

for function in "${functions[@]}"; do
    output=$(otool -I -v $binary | grep -w $function)
    if [ -z "$output" ]; then
        printf "%-15s | %s\n" "$function" "Nothing found"
    else
        IFS=$'\n'
        for line in $output; do
            printf "%-15s | %s\n" "$function" "$line"
            function=""
        done
        unset IFS
    fi
    printf "%-15s | %s\n" "-------------" "-------------------------------"
done
