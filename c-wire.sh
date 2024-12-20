#!usr/bin/bash

RED='\033[0;31m'      
GREEN='\033[0;32m'    
BLUE='\033[0;34m'     
CYAN='\033[0;36m'     
MAGENTA='\033[0;35m'  
YELLOW='\033[0;33m'   
WHITE='\033[1;37m'    
BLACK='\033[0;30m'    

BOLD='\033[1m'        
UNDERLINE='\033[4m'   
RESET='\033[0m'       

display_help_logo() {
    echo -e "\n\n"
    echo -e "${YELLOW}██╗  ██╗███████╗██╗     ██████╗ ${RESET}"
    echo -e "${YELLOW}██║  ██║██╔════╝██║     ██╔══██╗${RESET}"
    echo -e "${YELLOW}███████║█████╗  ██║     ██████╔╝${RESET}"
    echo -e "${YELLOW}██╔══██║██╔══╝  ██║     ██╔═══╝${RESET}"
    echo -e "${YELLOW}██║  ██║███████╗███████╗██║${RESET}"
    echo -e "${YELLOW}╚═╝  ╚═╝╚══════╝╚══════╝╚═╝${RESET}"
}

display_help() {
    echo -e "\n${BOLD}Usage: \n  bash c-wire.sh <path_to_csv> <station_type: hva hvb lv> <consumer_type: comp indiv all> [<plant_identifier>] [-h] ${RESET}"
    echo -e "\n${BOLD}Parameters:${RESET}"
    echo -e "  ${RED}<path_to_csv>${RESET}: Path to the CSV file containing the data. ${RED}(mandatory)${RESET}"
    echo -e "  ${RED}<station_type>${RESET}: Type of station to process (hvb, hva, lv). ${RED}(mandatory)${RESET}"
    echo -e "  ${RED}<consumer_type>${RESET}: Type of consumer to process (comp, indiv, all). ${RED}(mandatory)${RESET}"
    echo -e "  ${YELLOW}<plant_identifier>${RESET}: Identifier of the plant ${YELLOW}(optional)${RESET}."
    echo -e "  -h: Displays this help message and ignores all other parameters.\n"

    echo -e "${BOLD}Rules:${RESET}"
    echo -e "  - ${RED}Forbidden combinations:${RESET} hvb all, hvb indiv, hva all, hva indiv."

    echo -e "${BOLD}Examples:${RESET}"
    echo "  bash c-wire.sh data.csv hva comp"
    echo -e "  bash c-wire.sh data.csv lv indiv central_01\n"

    echo "Make sure your CSV file is correctly formatted to avoid errors."
}

display_error() {

}

# 
for arg in "$@"; do
  if [ "$arg" == "-h" ] ; then
    display_help_logo
    display_help
    exit 0 
  fi
done

if [ $# -ne 3 ] ; then 
    display_help
    exit 0 

CSV_FILE="$1"
STATION_TYPE="$2"
CONSUMER_TYPE="$3"
ID="${4:-}"

if [ ! -f "$CSV_FILE" ]; then
    echo "Erreur : Le fichier CSV fourni n'existe pas."
    display_help
    exit 1
fi

if [ "$STATION_TYPE" != "hvb" && "$STATION_TYPE" != "hva" && "$STATION_TYPE" != "lv" ]; then
    echo "Erreur : Le type de station doit être 'hvb', 'hva' ou 'lv'."
    display_help
    exit 1
fi

if [ "$CONSUMER_TYPE" != "comp" && "$CONSUMER_TYPE" != "indiv" && "$CONSUMER_TYPE" != "all" ]; then
    echo "Erreur : Le type de consommateur doit être 'comp', 'indiv' ou 'all'."
    display_help
    exit 1
fi

if { [ "$STATION_TYPE" == "hvb" || "$STATION_TYPE" == "hva" ] && [ "$CONSUMER_TYPE" == "all" || "$CONSUMER_TYPE" == "indiv" ]; }; then
    echo "Erreur : Les combinaisons 'hvb all', 'hvb indiv', 'hva all', 'hva indiv' sont interdites."
    display_help
    exit 1
fi


TMP_DIR="tmp"
GRAPHS_DIR="graphs"
if [ ! -d "$TMP_DIR" ]; then
    mkdir "$TMP_DIR"
else
    rm -rf "$TMP_DIR/*"
fi

if [ ! -d "$GRAPHS_DIR" ]; then
    mkdir "$GRAPHS_DIR"
fi

C_PROGRAM="./codeC/cwire"
MAKEFILE_DIR="codeC"
if [ ! -f "$C_PROGRAM" ]; then
    echo "Compilation du programme C..."
    (cd "$MAKEFILE_DIR" && make)
    if [ $? -ne 0 ]; then
        echo "Erreur : Échec de la compilation du programme C."
        exit 1
    fi
fi


FILTERED_FILE="$TMP_DIR/filtered_data.csv"
if [ -n "$CENTRAL_ID" ]; then
    grep ";$CENTRAL_ID;" "$CSV_FILE" > "$FILTERED_FILE"
else
    cp "$CSV_FILE" "$FILTERED_FILE"
fi


OUTPUT_FILE="tests/${STATION_TYPE}_${CONSUMER_TYPE}.csv"
echo "Traitement des données..."
START=$(date +%s)
$C_PROGRAM "$FILTERED_FILE" "$STATION_TYPE" "$CONSUMER_TYPE" > "$OUTPUT_FILE"
END=$(date +%s)

if [ $? -ne 0 ]; then
    echo "Erreur : Le programme C a échoué."
    exit 1
fi


DURATION=$((END - START))
echo "Traitement terminé en $DURATION secondes."


if [ "$STATION_TYPE" == "lv" && "$CONSUMER_TYPE" == "all" ]; then
    echo "Génération du graphique avec GnuPlot..."
    gnuplot <<EOF
set terminal png
set output '$GRAPHS_DIR/lv_all_graph.png'
set title 'Consommation des Postes LV'
set xlabel 'Identifiants'
set ylabel 'Consommation (kWh)'
plot '$OUTPUT_FILE' using 1:3 with lines title 'Consommation'
EOF
fi

echo "Traitement complet. Fichiers de sortie : $OUTPUT_FILE"
if [$4 != ]; then
tail -n+2 $1 | awk -F';' '$4 != "-" {print $0} ' | cut -d';' -f4,7,8 | sort -n -k3 -t';'  > tmp/lvTmp.csv
fi

if []; then
tail -n+2 $1 | awk -F';' '$2 != "-" {print $0} ' | cut -d';' -f4,7,8 | sort -n -k3 -t';'  > tmp/lvTmp.csv
fi

if []; then
tail -n+2 $1 | awk -F';' '$3 != "-" {print $0} ' | cut -d';' -f4,7,8 | sort -n -k3 -t';'  > tmp/lvTmp.csv
fi

if []; then
tail -n+2 $1 | awk -F';' '$6 != "-" {print $0} ' | cut -d';' -f4,7,8 | sort -n -k3 -t';'  > tmp/lvTmp.csv
fi

if []; then
tail -n+2 $1 | awk -F';' '$7 != "-" {print $0} ' | cut -d';' -f4,7,8 | sort -n -k3 -t';'  > tmp/lvTmp.csv
fi