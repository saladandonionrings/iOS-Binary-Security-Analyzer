#!/bin/bash

check_feature() {
    local title=$1
    local commands=$2

    echo "[*] $title"
    printf "%-15s | %s\n" "Function" "Value"
    printf "%-15s | %s\n" "-----------" "----------------------------------"

    for cmd in "${commands[@]}"; do
        local function_name="${cmd##* }"
        function_name="${function_name//\'/}" # remove quotes
        output=$(eval $cmd)
        if [ -z "$output" ]; then
            printf "%-15s | %s\n" "$function_name" "N/F"
        else
            IFS=$'\n'
            for line in $output; do
                printf "%-15s | %s\n" "$function_name" "$line"
                function_name="" 
            done
            unset IFS
        fi
        printf "%-15s | %s\n" "-----------" "----------------------------------"
    done
    echo ""
}

if [ $# -eq 0 ]; then
    echo "No binary provided. Usage: ./check.sh <binary>"
    exit 1
fi

binary=$1

echo "[+] iOS Binary Security Analyzer"
echo "*N/F = Not Found"
echo ""
echo "------------------------------------------"
echo "---------------- SECURITY ----------------"
echo "------------------------------------------"
echo ""
# Check if the binary is encrypted
crypt_info=$(otool -arch all -Vl "$binary" | grep -A5 LC_ENCRYPT | grep -w cryptid)
if [[ $crypt_info = *"1"* ]]; then
    echo "[+] Binary is encrypted :"
else
    echo "[-] Binary is not encrypted."
fi
echo $crypt_info
echo ""

# Perform the checks
check_feature "PIE (Position Idependant Executable)" "otool -hv $binary | grep PIE"
check_feature "Stack Canaries" "otool -I -v $binary | grep stack_chk"
check_feature "ARC (Automatic Reference Counting)" "otool -I -v $binary | grep _objc_"

echo "-----------------------------------------"
echo "---------------- INSECURE ---------------"
echo "-----------------------------------------"
echo ""

check_feature "Weak Cryptography (MD5)" "otool -I -v $binary | grep -w '_CC_MD5'"
check_feature "Weak Cryptography (SHA1)" "otool -I -v $binary | grep -w '_CC_SHA1'"

# The previous checks
functions=("_random" "_srand" "_rand" "_gets" "_memcpy" "_strncpy" "_strlen" "_vsnprintf" "_sscanf" "_strtok" "_alloca" "_sprintf" "_printf" "_vsprintf" "_malloc")
echo "[*] Unsafe and insecure functions"
printf "%-15s | %s\n" "Function" "Value"
printf "%-15s | %s\n" "-----------" "----------------------------------"

for function in "${functions[@]}"; do
    output=$(otool -I -v $binary | grep -w $function)
    if [ -z "$output" ]; then
        printf "%-15s | %s\n" "$function" "N/F"
    else
        IFS=$'\n'
        for line in $output; do
            printf "%-15s | %s\n" "$function" "$line"
            function="" 
        done
        unset IFS
    fi
    printf "%-15s | %s\n" "-----------" "----------------------------------"
done
