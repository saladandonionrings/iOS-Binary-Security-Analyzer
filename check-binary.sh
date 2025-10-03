#!/bin/bash
#
# CHECK BINARY SECURITY FOR IOS APPLICATIONS
# Credits : https://github.com/saladandonionrings/iOS-Binary-Security-Analyzer
# Update : 2025-10-03
#

# ANSI Color Codes
RED='\033[0;31m'    # Red for High Risk / Missing Protection
GREEN='\033[0;32m'  # Green for OK / Mitigation Found
YELLOW='\033[1;33m' # Yellow/Orange for Warning
CYAN='\033[0;36m'   # Cyan for Section Headers
MAGENTA='\033[0;35m' # Main Title
WHITE='\033[1;37m'  # White for descriptions/details
NC='\033[0m'       # No Color

# Configuration
BINARY=$1
OT_COMMON_FLAGS="-I -v" # Common flags for otool to list imports

# --- Utility Functions (Descriptions) ---

# Function to get the description for mitigations (Title is the key)
get_mitigation_description() {
    case "$1" in
        "PIE") echo "Enables Address Space Layout Randomization (ASLR). Protects against ROP attacks. (Fundamental mitigation).";;
        "Stack Canaries") echo "Stack Protection. Inserts a 'canary' to detect and prevent most stack-based Buffer Overflows.";;
        "ARC") echo "Automatic Reference Counting (ARC) handles memory management, reducing 'use-after-free' and memory leak errors.";;
        *) echo "N/A";;
    esac
}

# Function to get the description for insecure C functions (Function Name is the key)
get_function_description() {
    case "$1" in
        "_gets") echo "HIGH: Does not check destination buffer size, GUARANTEED Buffer Overflow. AVOID ABSOLUTELY.";;
        "_sprintf") echo "HIGH: Can cause Buffer Overflows if the destination buffer is too small.";;
        "_vsprintf") echo "HIGH: Variable args version of sprintf. Same Buffer Overflow risk.";;
        "_alloca") echo "HIGH: Stack allocation. Can cause a Stack Overflow if the requested size is too large.";;
        "_CC_MD5"|"_CC_SHA1") echo "HIGH: Weak cryptography (obsolete). Do not use for security (passwords, signatures).";;
        "_memcpy") echo "WARNING: Memory copy. Dangerous if the destination buffer size is incorrect (Overflow).";;
        "_strncpy") echo "WARNING: String copy. Risky if the result is not manually NULL-terminated or size is wrong.";;
        "_strlen") echo "WARNING: Calculates length. Improper use can lead to memory size calculation errors.";;
        "_vsnprintf") echo "WARNING: Formatting function. Reduced risk if the size limit is correctly enforced.";;
        "_sscanf") echo "WARNING: Formatted reading. Can cause Buffer Overflows if read strings are not size-limited.";;
        "_strtok") echo "WARNING: Not thread-safe. Use 'strtok_r' in a multi-threaded environment.";;
        "_malloc") echo "WARNING: Memory allocation. Checked for risks of dynamic memory management errors.";;
        "_printf") echo "WARNING: Can cause Format String Vulnerabilities if the format string comes from untrusted source.";;
        "_random"|"_srand"|"_rand") echo "WARNING: Weak pseudo-random number generator. Unsuitable for cryptographic key or token generation.";;
        *) echo "N/A";;
    esac
}

# --- Utility Functions (Formatting & Execution) ---

# Function to format output as an indented block
format_block_output() {
    local label=$1
    local output=$2
    local description=$3
    local status_color=$4
    local category=$5
    
    local status_text
    local ref_color=$NC

    echo -e "${CYAN}--- ${label} ---${NC}"

    if [ -z "$output" ]; then
        status_text="N/F"
        
        # Determine status color for missing mitigations or OK functions
        if [[ "$category" == "MITIGATION" ]]; then
             status_color=$RED
             status_text="MISSING"
        else
             status_color=$GREEN
             status_text="N/F (OK)" 
        fi
        
        echo -e "  ${status_color}Status: ${status_text}${NC}"
        echo -e "  ${WHITE}Description: ${description}${NC}"
        echo -e "  References: None found."
    else
        status_text="Found"
        
        # Apply specific color for references if it's a high-risk function
        if [[ "$status_color" == "$RED" ]]; then
            ref_color=$RED
        elif [[ "$status_color" == "$YELLOW" ]]; then
            ref_color=$YELLOW
        fi

        echo -e "  ${status_color}Status: ${status_text}${NC}"
        echo -e "  ${WHITE}Description: ${description}${NC}"
        echo -e "  ${ref_color}References:${NC}"

        # Print multi-line output with indentation
        IFS=$'\n'
        for line in $output; do
            echo -e "    ${ref_color}-> ${line}${NC}"
        done
        unset IFS
    fi
    echo ""
}

# Function to check for a security feature using otool and format as a block
check_feature_block() {
    local title=$1
    local flags=$2
    local pattern=$3
    local status_color=$4
    local category=$5
    
    local output
    
    if [[ "$category" == "MITIGATION" ]]; then
        # Use simple grep for broader pattern matching on system-level features
        output=$(otool "$flags" "$BINARY" 2>/dev/null | grep "$pattern" | awk '{$1=$1;print}')
    else
        # Use strict grep for all other C functions (more secure/precise)
        output=$(otool "$flags" "$BINARY" 2>/dev/null | grep -w "$pattern" | awk '{$1=$1;print}')
    fi

    local description
    if [[ "$category" == "MITIGATION" ]]; then
        description=$(get_mitigation_description "$title")
    else
        description=$(get_function_description "$title")
    fi

    format_block_output "$title" "$output" "$description" "$status_color" "$category"
}

# --- Main Script Logic ---

if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No binary provided. Usage: $0 <binary>${NC}"
    exit 1
fi

if [ ! -f "$BINARY" ]; then
    echo -e "${RED}Error: Binary file '$BINARY' not found.${NC}"
    exit 1
fi

binary=$1
echo -e "\n${MAGENTA}==================================================================================================================================="
echo -e "   [+] iOS Binary Security Analyzer"
echo -e "===================================================================================================================================${NC}"
echo -e "${YELLOW}Target: $binary${NC}"

# 1. Architecture
architecture=$(lipo -info "$binary" 2>/dev/null)
architecture="${architecture##*: }" 
echo -e "\n${CYAN}>>> ARCHITECTURE & BASIC INFO <<<${NC}"
echo -e "Architecture(s): ${GREEN}$architecture${NC}"

# 2. Encryption Check
echo -e "\n${CYAN}>>> ENCRYPTION STATUS (App Store) <<<${NC}"
crypt_id_value=$(otool -arch all -Vl "$binary" 2>/dev/null | grep -A5 LC_ENCRYPT | grep -w cryptid | awk '{print $2}')

if [[ "$crypt_id_value" == "1" ]]; then
    echo -e "${GREEN}[+] STATUS: Binary is ENCRYPTED (App Store Protected)${NC}"
    crypt_color=$GREEN
else
    # Unencrypted binary is a security weakness
    echo -e "${RED}[!] STATUS: Binary is NOT encrypted (Development/Decrypted)${NC}" 
    crypt_color=$RED
fi
echo -e "Cryptid Value: ${crypt_color}cryptid $crypt_id_value${NC}\n"

# Check Code Signature
CODE_SIGNATURE_OUTPUT=$(otool -l "$BINARY" 2>/dev/null | grep LC_CODE_SIGNATURE | awk '{$1=$1;print}')
CODE_SIGNATURE_DESC="Verifies the presence and integrity of the code signature required on iOS."
format_block_output "Code Signature" "$CODE_SIGNATURE_OUTPUT" "$CODE_SIGNATURE_DESC" $GREEN "MITIGATION"


# 3. Security Mitigations
echo -e "\n${CYAN}>>> SECURITY MITIGATIONS (Code Protection) <<<${NC}"

# Check PIE
check_feature_block "PIE" "-hv" "PIE" $GREEN "MITIGATION"

# Check Stack Canaries
CANARY_OUTPUT=$(otool -I -v "$BINARY" 2>/dev/null | grep "stack_chk" | awk '{$1=$1;print}')
CANARY_DESC=$(get_mitigation_description "Stack Canaries")
format_block_output "Stack Canaries" "$CANARY_OUTPUT" "$CANARY_DESC" $GREEN "MITIGATION"

# Check ARC
ARC_OUTPUT=$(otool -I -v "$BINARY" 2>/dev/null | grep "_objc_" | awk '{$1=$1;print}')
ARC_DESC=$(get_mitigation_description "ARC")
format_block_output "ARC" "$ARC_OUTPUT" "$ARC_DESC" $GREEN "MITIGATION"

# 4. Comprehensive Insecure/Legacy Functions
echo -e "\n${CYAN}>>> INSECURE/LEGACY FUNCTION CHECKS <<<${NC}"

# Functions that are almost always high risk or outdated: use RED
HIGH_RISK_FUNCS=(
    "_gets" "_sprintf" "_vsprintf" "_alloca" 
    "_CC_MD5" "_CC_SHA1"
)

# Functions that require careful use (yellow/warning): use YELLOW
CAREFUL_FUNCS=(
    "_memcpy" "_strncpy" "_strlen" "_vsnprintf" "_sscanf" "_strtok" 
    "_malloc" "_printf" 
    "_random" "_srand" "_rand"
)

# Check High-Risk Functions
for func in "${HIGH_RISK_FUNCS[@]}"; do
    FUNC_OUTPUT=$(otool -I -v "$BINARY" 2>/dev/null | grep -w "$func" | awk '{$1=$1;print}')
    FUNC_DESC=$(get_function_description "$func")
    format_block_output "$func" "$FUNC_OUTPUT" "$FUNC_DESC" $RED "FUNCTION"
done

# Check Careful-Use Functions
for func in "${CAREFUL_FUNCS[@]}"; do
    FUNC_OUTPUT=$(otool -I -v "$BINARY" 2>/dev/null | grep -w "$func" | awk '{$1=$1;print}')
    FUNC_DESC=$(get_function_description "$func")
    format_block_output "$func" "$FUNC_OUTPUT" "$FUNC_DESC" $YELLOW "FUNCTION"
done

# 5. LIBRARY DEPENDENCIES & DEBUGGING SYMBOLS
echo -e "\n${CYAN}>>> LIBRARY DEPENDENCIES & DEBUGGING SYMBOLS <<<${NC}"

# Check Dynamic Libraries
LIBS_OUTPUT=$(otool -L "$BINARY" 2>/dev/null | awk '{$1=$1;print}')
LIBS_DESC="Lists all dynamic libraries and frameworks the binary depends on. Check for outdated or known vulnerable dependencies."
format_block_output "Dynamic Libraries" "$LIBS_OUTPUT" "$LIBS_DESC" $GREEN "INFO"

# Check for Debugging and Anti-Analysis Functions
DEBUG_FUNCS=("ptrace" "fork" "__abort_with_payload")
DEBUG_FUNCS_DESC="Identifies functions commonly used for debugging, anti-debugging checks (ptrace, fork), or critical errors (__abort_with_payload)."

DEBUG_OUTPUT=""
for func in "${DEBUG_FUNCS[@]}"; do
    # Search for the function
    CURRENT_FUNC_OUTPUT=$(otool -I -v "$BINARY" 2>/dev/null | grep "$func" | awk '{$1=$1;print}')
    if [ ! -z "$CURRENT_FUNC_OUTPUT" ]; then
        DEBUG_OUTPUT+="${CURRENT_FUNC_OUTPUT}\n"
    fi
done

# Remove trailing newline if it exists
DEBUG_OUTPUT=$(echo -e "$DEBUG_OUTPUT" | sed '/^$/d')

format_block_output "Debugging Symbols" "$DEBUG_OUTPUT" "$DEBUG_FUNCS_DESC" $YELLOW "FUNCTION"

echo -e "\n${MAGENTA}==================================================================================================================================="
echo -e "   [+] Analysis Complete."
echo -e "===================================================================================================================================${NC}\n"
