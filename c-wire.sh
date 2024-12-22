#!usr/bin/bash

RED="\033[0;31m"     
GREEN="\033[0;32m"    
BLUE="\033[0;34m"  
CYAN="\033[0;36m" 
MAGENTA="\033[0;35m"
YELLOW="\033[0;33m"
WHITE="\033[1;37m"
BLACK="\033[0;30m" 

BOLD='\033[1m'        
UNDERLINE='\033[4m'   
RESET='\033[0m'       

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

TIME=0
TIME_START=0
TIME_END=0
FORCE_COMPILE=0
PLANT_ID=-1

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


loading_animation() {
  local pid=$1 
  local status_text=$2
  local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
  while kill -0 $pid 2>/dev/null; do
    for (( i=0; i<${#chars}; i++ )); do
      echo -ne "\r[${chars:$i:1}] $status_text...        " 
      sleep 0.2
    done
  done
  
}


for arg in "$@"; do
  if [ "$arg" == "-h" ] ; then
    display_help_logo
    display_help
    exit 0 
  fi
done

if [ $# -ne 3 ] && [ $# -ne 4 ] && [ $# -ne 5 ] ; then 
    display_error "Invalid argument number must be 3-5" ${INCORRECT_ARGC_ERROR} ${TIME}
fi

TIME_START=$(date +%s)


if [ $# -eq 4 ] ; then 
    if [ "$4" == "-r" ] ; then
        FORCE_COMPILE=1
    else
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

if [ ! -d "${TMP_DIR}" ] ; then
    mkdir "${TMP_DIR}"
else
    rm -rf "${TMP_DIR}/*"
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

CSV_treatement() {
    if [ "${STATION_TYPE}" == "hvb" ]; then
        if [ ${PLANT_ID} -eq -1 ] ; then 
            tail -n+2 "${CSV_FILE}" | awk -F';' '$2 != "-" && $3 == "-" && $4 == "-"  {print $0}' | cut -d';' -f2,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        else 
            tail -n+2 "${CSV_FILE}" | awk -v plant_id="${PLANT_ID}" -F';' '$1 == plant_id && $2 != "-" && $3 == "-" && $4 == "-"  {print $0}' | cut -d';' -f2,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        fi
        FINAL_TITLE_STATION="HV-B Station"
        FINAL_TITLE_CONSUMER="Compagny"

    elif [ "${STATION_TYPE}" == "hva" ]; then
        if [ ${PLANT_ID} -eq -1 ] ; then 
            tail -n+2 "${CSV_FILE}" | awk -F';' '$3 != "-" && $4 == "-"  {print $0}' | cut -d';' -f3,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        else 
            tail -n+2 "${CSV_FILE}" | awk -v plant_id="${PLANT_ID}" -F';' '$1 == plant_id && $3 != "-" && $4 == "-"  {print $0}' | cut -d';' -f3,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        fi
        FINAL_TITLE_STATION="Station HV-A"
        FINAL_TITLE_CONSUMER="Compagny"

    elif [ "$CONSUMER_TYPE" == "comp" ]; then
        if [ ${PLANT_ID} -eq -1 ] ; then 
            tail -n+2 "${CSV_FILE}" | awk -F';' '$4 != "-" && $6 == "-"  {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        else 
            tail -n+2 "${CSV_FILE}" | awk -v plant_id="${PLANT_ID}" -F';' '$1 == plant_id && $4 != "-" && $6 == "-"  {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        fi
        FINAL_TITLE_STATION="Station LV"
        FINAL_TITLE_CONSUMER="Compagny"

    elif [ "$CONSUMER_TYPE" == "indiv" ]; then
        if [ ${PLANT_ID} -eq -1 ] ; then 
            tail -n+2 "${CSV_FILE}" | awk -F';' '$4 != "-" && $5 == "-"  {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        else
            tail -n+2 "${CSV_FILE}" | awk -v plant_id="${PLANT_ID}" -F';' '$1 == plant_id && $4 != "-" && $5 == "-"  {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        fi
        FINAL_TITLE_STATION="Station LV"
        FINAL_TITLE_CONSUMER="Individuals"

    else
        if [ ${PLANT_ID} -eq -1 ] ; then
            tail -n+2 "${CSV_FILE}" | awk -F';' '$4 != "-" {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        else
            tail -n+2 "${CSV_FILE}" | awk -v plant_id="${PLANT_ID}" -F';' '$1 == plant_id && $4 != "-" {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > "${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"
        fi
        FINAL_TITLE_STATION="Station LV"
        FINAL_TITLE_CONSUMER="All"

    fi
    return $?
}

CSV_treatement &
cmd_pid=$!
loading_animation $cmd_pid "Data treatement in progress"
wait $cmd_pid  
exit_code=$?

if [ ${exit_code} -ne 0 ] ; then
    echo -e "\r${RED}[✖ ] Failure${RESET}                 "
    display_error "A CSV error occured, check the csv data integrity" ${CSV_ERROR} ${TIME}
fi
echo -e "\r${GREEN}[✔ ] Data treatement success !${RESET}                 "

TIME_END=$(date +%s)

TIME=$(( TIME + TIME_END - TIME_START ))

FILTERED_FILE="${TMP_DIR}/tmp${STATION_TYPE}${CONSUMER_TYPE}.csv"

C_PROGRAM="codeC/CWIRE_C"
MAKEFILE_DIR="codeC"



if [ ! -f "$C_PROGRAM" ] || [ "${FORCE_COMPILE}" -ne 0 ] ; then
    cd codeC
    make &
    cmd_pid=$!
    loading_animation $cmd_pid "Compiling C"
    wait $cmd_pid  
    if [ $? -ne 0 ] ; then
        echo -e "\r${RED}[✖ ] Failure${RESET}                 "
        display_error "Compilation failed, Make error no : $?" ${COMPILATION_ERROR} ${TIME}
    fi
    echo -e "\r${GREEN}[✔ ] Compiling success !${RESET}                 "
    cd ..
else 
    echo -e "${GREEN}[✔ ] C already compiled !${RESET}"
fi

if [ ! -f "$C_PROGRAM" ] ; then
    display_error "Compilation failed" ${COMPILATION_ERROR} ${TIME}
fi


if [ ${PLANT_ID} -eq -1 ] ; then 
	OUTPUT_FILE="tests/${STATION_TYPE}_${CONSUMER_TYPE}.csv"
else
    OUTPUT_FILE="tests/${STATION_TYPE}_${CONSUMER_TYPE}_${PLANT_ID}.csv"
fi

if [ -f "${OUTPUT_FILE}" ] ; then
    rm -f "${OUTPUT_FILE}"
fi

TIME_START=$(date +%s)

launchC() {
    ./"$C_PROGRAM" "${FILTERED_FILE}" "${OUTPUT_FILE}"
    return $?
}

launchC &
cmd_pid=$!
loading_animation $cmd_pid "Sum in progress"
wait $cmd_pid  

if [ $? -ne 0 ] ; then
    echo -e "\r${RED}[✖ ] Failure${RESET}                 "
    display_error "A C error occured" ${C_ERROR} ${TIME}
fi

echo -e "\r${GREEN}[✔ ] Sum success !${RESET}                 "

sort "$OUTPUT_FILE" -t':' -n -k2 -o "$OUTPUT_FILE"
if [ $? -ne 0 ] ; then
    echo -e "${RED}[✖ ] Failure${RESET}                 "
    display_error "An Undefined error occured" ${CSV_ERROR} ${TIME}
fi
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

TIME=$(( TIME + TIME_END - TIME_START ))

echo -e "\nDuration ${GREEN}${TIME}${RESET} secondes."

echo -e "Output file : ${GREEN}$OUTPUT_FILE${RESET}"