#!usr/bin/bash

# These variables define ANSI color codes for formatting text output in the terminal.
RED="\033[0;31m"     
GREEN="\033[0;32m"    
BLUE="\033[0;34m"  
CYAN="\033[0;36m" 
MAGENTA="\033[0;35m"
YELLOW="\033[0;33m"
WHITE="\033[1;37m"
BLACK="\033[0;30m" 

# Formatting codes for bold text, underlined text, and resetting styles.
BOLD='\033[1m'        
UNDERLINE='\033[4m'   
RESET='\033[0m'       

# Constants for error codes, used to identify specific types of errors during execution.
UNDEFINED_ERROR=500
VALUE_ERROR=501
FILE_ERROR=502
INCORRECT_ARGS_ERROR=503
INCORRECT_ARGC_ERROR=504
CSV_ERROR=505
STATION_ERROR=506
CONSUMER_ERROR=507
FORBIDEN_ERROR=508
COMPILATION_ERROR=509
C_ERROR=510

# Initialization of global variables:
# TIME: Keeps track of the total runtime.
# TIME_START, TIME_END: Used to measure durations.
# FORCE_COMPILE: Flag to force compilation of the C program.
# PLANT_ID: Indicates the plant identifier (default is -1, meaning not specified).
TIME=0
TIME_START=0
TIME_END=0
FORCE_COMPILE=0
PLANT_ID=-1

# Function to display an ASCII logo followed by usage instructions.
display_help_logo() {
    
    echo -e "\n\n"
    echo -e "${YELLOW}██╗  ██╗███████╗██╗     ██████╗ ${RESET}"
    echo -e "${YELLOW}██║  ██║██╔════╝██║     ██╔══██╗${RESET}"
    echo -e "${YELLOW}███████║█████╗  ██║     ██████╔╝${RESET}"
    echo -e "${YELLOW}██╔══██║██╔══╝  ██║     ██╔═══╝${RESET}"
    echo -e "${YELLOW}██║  ██║███████╗███████╗██║${RESET}"
    echo -e "${YELLOW}╚═╝  ╚═╝╚══════╝╚══════╝╚═╝${RESET}"
    echo -e "\n${BOLD}Usage:"
}

# Detailed instructions for running the script, including parameter explanations.
display_help() {
    echo -e "  ${BOLD}bash c-wire.sh <path_to_csv> <station_type: hva hvb lv> <consumer_type: comp indiv all> [<plant_identifier>] [-h] [-r] ${RESET}"
    echo -e "\n${BOLD}Parameters:${RESET}"
    echo -e "  ${RED}<path_to_csv>${RESET}: Path to the CSV file containing the data. ${RED}(mandatory)${RESET}"
    echo -e "  ${RED}<station_type>${RESET}: Type of station to process (hvb, hva, lv). ${RED}(mandatory)${RESET}"
    echo -e "  ${RED}<consumer_type>${RESET}: Type of consumer to process (comp, indiv, all). ${RED}(mandatory)${RESET}"
    echo -e "  ${YELLOW}<plant_identifier>${RESET}: Identifier of the plant ${YELLOW}(optional)${RESET}."
    echo -e "  -h: Displays this help message and ignores all other parameters.\n"
    echo -e "  -r: force C compilation can only be the last parameter\n"

    echo -e "${BOLD}Rules:${RESET}"
    echo -e "  - ${RED}Forbidden combinations:${RESET} hvb all, hvb indiv, hva all, hva indiv."

    echo -e "${BOLD}Examples:${RESET}"
    echo "  bash c-wire.sh data.csv hva comp"
    echo -e "  bash c-wire.sh data.csv lv indiv 1\n"

    echo "Make sure your CSV file is correctly formatted to avoid errors."
}

# Function to display error messages. Takes three arguments:
# 1. Error message.
# 2. Error code.
# 3. Duration of execution when the error occurred.
display_error() {
    if [ $# -ne 3 ]; then
        echo -e "${MAGENTA} display_error Arguments number is incorrect ${RESET} Shell error no : ${RED} ${INCORRECT_ARGS_ERROR} ${RESET}"
        exit ${INCORRECT_ARGS_ERROR}
    fi
    echo -e "\n${MAGENTA}$1${RESET} Shell error no : ${RED}$2${RESET} (Duration : $3 sec)\n"
    echo -e "${RED}Try :${RESET}"
    display_help
    exit $2
}

# Function to display a loading animation while a background process runs.
# It uses the `kill -0` command to check if the process ID (PID) exists.
loading_animation() {
    # Declare a function that takes two arguments: a PID and a status text
    local pid=$1 # Process ID to monitor
    local status_text=$2 # Text to display during the animation
    local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏" # Define the characters to use for the animation
    while kill -0 $pid 2>/dev/null; do # The 'while' loop continues as long as the process specified by $pid is running, kill -0 $pid 2>/dev/null is telling us if the process il still alive
        # The 'for' loop iterates over each character in the $chars string
        for (( i=0; i<${#chars}; i++ )); do
            # Display the animation: one symbol at a time, followed by the status text
            # The '\r' command brings the cursor back to the beginning of the line without creating a new line
            # This is crucial for making the animation rotate on the same line
            echo -ne "\r[${chars:$i:1}] $status_text...        " 
            # Pause for 0.2 seconds before displaying the next character, slowing down the animation
            sleep 0.2
        done
    done
  
}

# Loop through all script arguments. If `-h` is found, display the help and exit.
for arg in "$@"; do
  if [ "$arg" == "-h" ] ; then
    display_help_logo
    display_help
    exit 0 
  fi
done

# Validate the number of arguments. Must be between 3 and 5.
if [ $# -ne 3 ] && [ $# -ne 4 ] && [ $# -ne 5 ] ; then 
    display_error "Invalid argument number must be 3-5" ${INCORRECT_ARGC_ERROR} ${TIME}
fi

TIME_START=$(date +%s)

# Check if the number of arguments passed to the script is exactly 4
if [ $# -eq 4 ] ; then 
    # If the 4th argument is "-r", set FORCE_COMPILE to 1 (forcing compilation)
    if [ "$4" == "-r" ] ; then
        FORCE_COMPILE=1
    else
        # If the 4th argument is not "-r", check if the plant ID provided in the 4th argument exists in the file
        # 'tail -n+2' skips the first line, 'cut -d';' -f1' extracts the first field, and
        # 'grep -q -F -- "$4"' checks if the 4th argument (plant ID) is found in the list
        if ! tail -n+2 "$1" | cut -d';' -f1 | grep -q -F -- "$4" ; then
            TIME_END=$(date +%s)
            TIME=$(( TIME + TIME_END - TIME_START ))

            display_error "Invalid plant number" ${VALUE_ERROR} ${TIME}
        fi
        PLANT_ID=$4
    fi
fi
if [ $# -eq 5 ] ; then 
    if [ "$5" == "-r" ] ; then
        FORCE_COMPILE=1
    fi
    # If the 4th argument is not "-r", check if the plant ID provided in the 4th argument exists in the file
    # 'tail -n+2' skips the first line, 'cut -d';' -f1' extracts the first field, and
    # 'grep -q -F -- "$4"' checks if the 4th argument (plant ID) is found in the list
    if ! tail -n+2 "$1" | cut -d';' -f1 | grep -q -F -- "$4" ; then
        TIME_END=$(date +%s)
        TIME=$(( TIME + TIME_END - TIME_START ))

        display_error "Invalid plant number" ${VALUE_ERROR} ${TIME}
    fi
    PLANT_ID=$4
fi

TIME_END=$(date +%s)
TIME=$(( TIME + TIME_END - TIME_START ))


CSV_FILE="$1"
STATION_TYPE="$2"
CONSUMER_TYPE="$3"
# Handeling of forbiden combinations
if [ ! -f "$CSV_FILE" ]; then
    display_error "The source file \"${CSV_FILE}\" does not exist : check file path integrity" ${FILE_ERROR} ${TIME}
fi

if [ "${STATION_TYPE}" != "hvb" ] && [ "${STATION_TYPE}" != "hva" ] && [ "${STATION_TYPE}" != "lv" ] ; then
    display_error "The station must be only \"hvb\",\"hva\" or \"lv\"" ${STATION_ERROR} ${TIME}
fi

if [ "${CONSUMER_TYPE}" != "comp" ] && [ "${CONSUMER_TYPE}" != "indiv" ] && [ "${CONSUMER_TYPE}" != "all" ] ; then
    display_error "The consumer type must be only \"comp\",\"indiv\" or \"all\"" ${STATION_ERROR} ${TIME}
fi

if { [ "${STATION_TYPE}" = "hvb" ] || [ "${STATION_TYPE}" = "hva" ] ; } && { [ "${CONSUMER_TYPE}" = "all" ] || [ "${CONSUMER_TYPE}" = "indiv" ] ; } ; then
    display_error "$STATION_TYPE ${CONSUMER_TYPE} is a forbiden combinations" ${STATION_ERROR} ${TIME}
fi

echo -e "${GREEN}[✔ ] Settings successfully checked !${RESET}                 "

TMP_DIR="tmp"
GRAPHS_DIR="graphs"
# Creation of importants folders
if [ ! -d "${TMP_DIR}" ] ; then
    mkdir "${TMP_DIR}"
else
    rm -rf "${TMP_DIR}"/*
fi

if [ ! -d "${GRAPHS_DIR}" ] ; then
    mkdir "${GRAPHS_DIR}"
fi

if [ ! -d "input" ] ; then
    mkdir "input"
fi

if [ ! -d "tests" ] ; then
    mkdir "tests"
fi

echo -e "${GREEN}[✔ ] folders successfully created !${RESET}                 "

TIME_START=$(date +%s)

if [ "${STATION_TYPE}" == "hvb" ] ; then #if STATION_TYPE is hva or hvb we know the CONSUMER_TYPE is comp
    FINAL_TITLE_STATION="HV-B Station"
    FINAL_TITLE_CONSUMER="Compagny"

elif [ "${STATION_TYPE}" == "hva" ] ; then
    FINAL_TITLE_STATION="HV-A Station "
    FINAL_TITLE_CONSUMER="Compagny"

elif [ "$CONSUMER_TYPE" == "comp" ] ; then #it not an hva or hvb so its a lv
    FINAL_TITLE_STATION="LV Station"
    FINAL_TITLE_CONSUMER="Compagny"

elif [ "$CONSUMER_TYPE" == "indiv" ] ; then #it not an hva or hvb so its a lv
    FINAL_TITLE_STATION="LV Station"
    FINAL_TITLE_CONSUMER="Individuals"

else #it not an hva or hvb its not lv comp or lv indiv so its lv all
    FINAL_TITLE_STATION="LV Station"
    FINAL_TITLE_CONSUMER="All"

fi



# Function to process the CSV file based on different conditions
CSV_treatement() {
    if [ "${STATION_TYPE}" == "hvb" ] ; then #if STATION_TYPE is hva or hvb we know the CONSUMER_TYPE is comp
        if [ ${PLANT_ID} -eq -1 ] ; then 
            # Process the CSV, skip the header line, filter data, change - in 0, and store the result in a temporary file
            tail -n+2 "${CSV_FILE}" | awk -F';' '$2 != "-" && $3 == "-" && $4 == "-"  {print $0}' | cut -d';' -f2,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        else 
            # If PLANT_ID is specified same thing but the plant id is used to filter data
            tail -n+2 "${CSV_FILE}" | awk -v plant_id="${PLANT_ID}" -F';' '$1 == plant_id && $2 != "-" && $3 == "-" && $4 == "-"  {print $0}' | cut -d';' -f2,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        fi

    elif [ "${STATION_TYPE}" == "hva" ] ; then
        
        if [ ${PLANT_ID} -eq -1 ] ; then
            # Process the CSV, skip the header line, filter data, change - in 0, and store the result in a temporary file
            tail -n+2 "${CSV_FILE}" | awk -F';' '$3 != "-" && $4 == "-"  {print $0}' | cut -d';' -f3,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        else 
            # If PLANT_ID is specified same thing but the plant id is used to filter data
            tail -n+2 "${CSV_FILE}" | awk -v plant_id="${PLANT_ID}" -F';' '$1 == plant_id && $3 != "-" && $4 == "-"  {print $0}' | cut -d';' -f3,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        fi

    elif [ "$CONSUMER_TYPE" == "comp" ] ; then #it not an hva or hvb so its a lv
        if [ ${PLANT_ID} -eq -1 ] ; then 
            # Process the CSV, skip the header line, filter data, change - in 0, and store the result in a temporary file
            tail -n+2 "${CSV_FILE}" | awk -F';' '$4 != "-" && $6 == "-"  {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        else
            # If PLANT_ID is specified same thing but the plant id is used to filter data
            tail -n+2 "${CSV_FILE}" | awk -v plant_id="${PLANT_ID}" -F';' '$1 == plant_id && $4 != "-" && $6 == "-"  {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        fi


    elif [ "$CONSUMER_TYPE" == "indiv" ] ; then #it not an hva or hvb so its a lv
        if [ ${PLANT_ID} -eq -1 ] ; then
            # Process the CSV, skip the header line, filter data, change - in 0, and store the result in a temporary file
            tail -n+2 "${CSV_FILE}" | awk -F';' '$4 != "-" && $5 == "-"  {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        else
            # If PLANT_ID is specified same thing but the plant id is used to filter data
            tail -n+2 "${CSV_FILE}" | awk -v plant_id="${PLANT_ID}" -F';' '$1 == plant_id && $4 != "-" && $5 == "-"  {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        fi

    else #it not an hva or hvb its not lv comp or lv indiv so its lv all
        if [ ${PLANT_ID} -eq -1 ] ; then 
            # Process the CSV, skip the header line, filter data, change - in 0, and store the result in a temporary file
            tail -n+2 "${CSV_FILE}" | awk -F';' '$4 != "-" {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        else
            # If PLANT_ID is specified same thing but the plant id is used to filter data
            tail -n+2 "${CSV_FILE}" | awk -v plant_id="${PLANT_ID}" -F';' '$1 == plant_id && $4 != "-" {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        fi

    fi
    return $?
}


# Run the CSV treatment function in the background (for the annimation purspos)
CSV_treatement &
# Store the process ID of the background job
cmd_pid=$!
# Call the loading_animation function to show an animated progress indicator
loading_animation $cmd_pid "Data treatement in progress"
# Wait for the background job to finish and capture its exit status
wait $cmd_pid  
exit_code=$?
# Check if the CSV processing failed (exit code is non-zero)
if [ ${exit_code} -ne 0 ] ; then
    echo -e "\r${RED}[✖ ] Failure${RESET}                 "
    display_error "A CSV error occured, check the csv data integrity" ${CSV_ERROR} ${TIME}
fi
# If successful, display a success message
echo -e "\r${GREEN}[✔ ] Data treatement success !${RESET}                 "
# Capture the end time and calculate the total duration of the process
TIME_END=$(date +%s)
# Update the total time with the duration of the process
TIME=$(( TIME + TIME_END - TIME_START ))

# Display the total duration of the process
echo -e "Duration ${GREEN}${TIME}${RESET} secondes."

FILTERED_FILE="${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"

C_PROGRAM="codeC/CWIRE_C"
MAKEFILE_DIR="codeC"


# Check if the C program exists or if force compilation is requested
if [ ! -f "$C_PROGRAM" ] || [ "${FORCE_COMPILE}" -ne 0 ] ; then
    # Navigate to the 'codeC' directory to compile the C program
    cd codeC
    # Run 'make' in the background to compile the C program (for the annimation)
    make &
    # Store the process ID of the 'make' command
    cmd_pid=$!
    # Show the loading animation while the compilation is in progress
    loading_animation $cmd_pid "Compiling C"
    # Wait for the compilation process to finish
    wait $cmd_pid 
    # If the compilation fails (non-zero exit code), display an error
    if [ $? -ne 0 ] ; then
        echo -e "\r${RED}[✖ ] Failure${RESET}                 "
        display_error "Compilation failed, Make error no : $?" ${COMPILATION_ERROR} ${TIME}
    fi
    # If compilation succeeds, print a success message
    echo -e "\r${GREEN}[✔ ] Compiling success !${RESET}                 "
    cd ..
else 
    echo -e "${GREEN}[✔ ] C already compiled !${RESET}"
fi
# If the C program still doesn't exist after compilation, display an error

if [ ! -f "$C_PROGRAM" ] ; then
    display_error "Compilation failed" ${COMPILATION_ERROR} ${TIME}
fi

# Determine the output file based on station and consumer types and the plant option
if [ ${PLANT_ID} -eq -1 ] ; then 
	OUTPUT_FILE="tests/${STATION_TYPE}_${CONSUMER_TYPE}.csv"
else
    OUTPUT_FILE="tests/${STATION_TYPE}_${CONSUMER_TYPE}_${PLANT_ID}.csv"
fi
# If the output file exists, remove it

if [ -f "${OUTPUT_FILE}" ] ; then
    rm -f "${OUTPUT_FILE}"
fi

TIME_START=$(date +%s)

# Function to run the compiled C program with the filtered file and output file

launchC() {
    ./"$C_PROGRAM" "${FILTERED_FILE}" "${OUTPUT_FILE}"
    return $?
}
# Run the C program in the background
launchC &
# Store the process ID of the C program execution

cmd_pid=$!
# Show the loading animation while the sum calculation is in progress
loading_animation $cmd_pid "Sum in progress"
# Wait for the C program to finish executing

wait $cmd_pid  

# If the C program execution fails, display an error

if [ $? -ne 0 ] ; then
    echo -e "\r${RED}[✖ ] Failure${RESET}                 "
    display_error "A C error occured" ${C_ERROR} ${TIME}
fi

# If the sum calculation succeeds, display a success message

echo -e "\r${GREEN}[✔ ] Sum success !${RESET}                 "

# Sort the output file by the second field (capacity) in numerical order

sort "$OUTPUT_FILE" -t':' -n -k2 -o "$OUTPUT_FILE"

if [ $? -ne 0 ] ; then
    echo -e "${RED}[✖ ] Failure${RESET}                 "
    display_error "An Undefined error occured" ${CSV_ERROR} ${TIME}
fi
# Modify the header of the output file to include station and consumer information
sed -i "1s/.*/${FINAL_TITLE_STATION}:Capacity:Load (${FINAL_TITLE_CONSUMER})/" "$OUTPUT_FILE"

if [ $? -ne 0 ] ; then
    echo -e "${RED}[✖ ] Failure${RESET}                 "
    display_error "An Undefined error occured" ${CSV_ERROR} ${TIME}
fi

if [ $? -ne 0 ] ; then
    display_error "An Undefined error occured" ${CSV_ERROR} ${TIME}
fi
echo -e "${GREEN}[✔ ] Sort success !${RESET}                 "

TIME_END=$(date +%s)
# If the station type is 'lv' and the consumer type is 'all', perform additional calculations
if [ "${STATION_TYPE}" == "lv" ] && [ "${CONSUMER_TYPE}" == "all" ] ; then
    TMP_FILE_MIN_MAX="${TMP_DIR}/tmp${STATION_TYPE}_${CONSUMER_TYPE}_minmax.csv"
    TMP_FILE_MIN_MAX2="${TMP_DIR}/tmp2${STATION_TYPE}_${CONSUMER_TYPE}_minmax.csv"
    if [ -f "${TMP_FILE_MIN_MAX}" ] ; then
        rm -f "${TMP_FILE_MIN_MAX}"
    fi
    if [ -f "${TMP_FILE_MIN_MAX2}" ] ; then
        rm -f "${TMP_FILE_MIN_MAX2}"
    fi
    if [ ${PLANT_ID} -eq -1 ] ; then
        FINAL_MIN_MAX="tests/${STATION_TYPE}_${CONSUMER_TYPE}_minmax.csv"
    else
        FINAL_MIN_MAX="tests/${STATION_TYPE}_${CONSUMER_TYPE}_minmax_${PLANT_ID}.csv"
    fi
    # Process the output file, calculate the min-max difference, and sort the results
    tail -n+2 "${OUTPUT_FILE}" | awk -F: '{$4=$2-$3} {print $0}' OFS=: | sort -t':' -n -k3 > ${TMP_FILE_MIN_MAX}
    # Create the final min-max output file with the top and bottom 10 results
    if [ -f "${FINAL_MIN_MAX}" ] ; then
        rm -f "${FINAL_MIN_MAX}"
    fi
    head -n10 ${TMP_FILE_MIN_MAX} > ${TMP_FILE_MIN_MAX2}
    tail -n10 ${TMP_FILE_MIN_MAX} >> ${TMP_FILE_MIN_MAX2}
    # add the header of the min-max output file
    echo "${FINAL_TITLE_STATION}:Capacity:Load (${FINAL_TITLE_CONSUMER}):Electrical efficiency" > ${FINAL_MIN_MAX}
    # Sort the final min-max file
    sort "$TMP_FILE_MIN_MAX2" -t':' -n -k4 >> ${FINAL_MIN_MAX}
    echo -e "${GREEN}[✔ ] MinMax success !${RESET}  "
    TIME_END=$(date +%s)
    tail -n+2 "${FINAL_MIN_MAX}" > "tmp/tmpgraph.csv"
    gnuplot -e "ARG='tmp/tmpgraph.csv'" graph.gn
fi

# Calculate and display the duration of this section of the process
TIME2=$(( TIME_END - TIME_START ))
TIME=$(( TIME + TIME_END - TIME_START ))
echo -e "Duration ${GREEN}${TIME2}${RESET} secondes."

echo -e "\nTotal Duration ${GREEN}${TIME}${RESET} secondes."
# Display the output file path

echo -e "Output file : ${GREEN}$OUTPUT_FILE${RESET}"

if [ "${STATION_TYPE}" == "lv" ] && [ "${CONSUMER_TYPE}" == "all" ] ; then
    echo -e "Second Output file : ${GREEN}$FINAL_MIN_MAX${RESET}"
    echo -e "Third Output file : ${GREEN}graphs/lv_all_minmax_graph.png${RESET}"
fi