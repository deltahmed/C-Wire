#!usr/bin/bash

# 
display_help() {
    echo "Utilisation : c-wire.sh <chemin_csv> <type_station> <type_consommateur> [<identifiant_centrale>] [-h]"
    echo "  <chemin_csv> : Chemin vers le fichier CSV contenant les données. (obligatoire)"
    echo "  <type_station> : Type de station à traiter (hvb, hva, lv). (obligatoire)"
    echo "  <type_consommateur> : Type de consommateur à traiter (comp, indiv, all). (obligatoire)"
    echo "  <identifiant_centrale> : Identifiant de la centrale (optionnel)."
    echo "  -h : Affiche cette aide et ignore tous les autres paramètres."
    echo "Règles :"
    echo "  - Les options interdites : hvb all, hvb indiv, hva all, hva indiv."
    echo "  - Les dossiers tmp et graphs doivent exister ou être créés."
}

#
if [[ "$1" == "-h" || "$#" -lt 3 ]]; then
    display_help
    exit 0
fi

CSV_FILE="$1"
STATION_TYPE="$2"
CONSUMER_TYPE="$3"
ID="${4:-}"

if [[ ! -f "$CSV_FILE" ]]; then
    echo "Erreur : Le fichier CSV fourni n'existe pas."
    display_help
    exit 1
fi

if [[ "$STATION_TYPE" != "hvb" && "$STATION_TYPE" != "hva" && "$STATION_TYPE" != "lv" ]]; then
    echo "Erreur : Le type de station doit être 'hvb', 'hva' ou 'lv'."
    display_help
    exit 1
fi

if [[ "$CONSUMER_TYPE" != "comp" && "$CONSUMER_TYPE" != "indiv" && "$CONSUMER_TYPE" != "all" ]]; then
    echo "Erreur : Le type de consommateur doit être 'comp', 'indiv' ou 'all'."
    display_help
    exit 1
fi

if { [[ "$STATION_TYPE" == "hvb" || "$STATION_TYPE" == "hva" ]] && [[ "$CONSUMER_TYPE" == "all" || "$CONSUMER_TYPE" == "indiv" ]]; }; then
    echo "Erreur : Les combinaisons 'hvb all', 'hvb indiv', 'hva all', 'hva indiv' sont interdites."
    display_help
    exit 1
fi


TMP_DIR="tmp"
GRAPHS_DIR="graphs"
if [[ ! -d "$TMP_DIR" ]]; then
    mkdir "$TMP_DIR"
else
    rm -rf "$TMP_DIR/*"
fi

if [[ ! -d "$GRAPHS_DIR" ]]; then
    mkdir "$GRAPHS_DIR"
fi

if [[ ! -d "input" ]]; then
    mkdir "input"
fi

if [[ ! -d "tests" ]]; then
    mkdir "tests"
fi

if [[ "$STATION_TYPE" == "hvb" ]]; then
	tail -n+2 "$CSV_FILE" | awk -F';' '$2 != "-" && $3 == "-" && $4 == "-"  {print $0}' | cut -d';' -f2,7,8 | tr '-' '0' > tmp/tmphvbcomp.csv

elif [[ "$STATION_TYPE" == "hva" ]]; then
	tail -n+2 "$CSV_FILE" | awk -F';' '$3 != "-" && $4 == "-"  {print $0}' | cut -d';' -f3,7,8 | tr '-' '0' > tmp/tmphvacomp.csv

elif [[ "$CONSUMER_TYPE" == "comp" ]]; then
	tail -n+2 "$CSV_FILE" | awk -F';' '$4 != "-" && $6 == "-"  {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > tmp/tmplvcomp.csv

elif [[ "$CONSUMER_TYPE" == "indiv" ]]; then
	tail -n+2 "$CSV_FILE" | awk -F';' '$4 != "-" && $5 == "-"  {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > tmp/tmplvindiv.csv

else
	tail -n+2 "$CSV_FILE" | awk -F';' '$4 != "-" {print $0}' | cut -d';' -f4,7,8 | tr '-' '0' > tmp/tmplvall.csv

fi

FILTERED_FILE="tmp/tmp$2$3.csv"

C_PROGRAM="./codeC/CWIRE_C"
MAKEFILE_DIR="codeC"
cd codeC
make
cd ..
if [[ ! -f "$C_PROGRAM" ]]; then
    echo "Compilation du programme C..."
        echo "Erreur : Échec de la compilation du programme C."
        exit 1
fi

OUTPUT_FILE="tests/${STATION_TYPE}_${CONSUMER_TYPE}.csv"
if [[ -f "$OUTPUT_FILE" ]]; then
    rm -f "$OUTPUT_FILE"
fi
echo "Traitement des données..."
START=$(date +%s)
$C_PROGRAM "$FILTERED_FILE" "$STATION_TYPE" "$CONSUMER_TYPE" > "$OUTPUT_FILE"
END=$(date +%s)

if [[ $? -ne 0 ]]; then
    echo "Erreur : Le programme C a échoué."
    exit 1
fi


DURATION=$((END - START))
echo "Traitement terminé en $DURATION secondes."


echo "Traitement complet. Fichiers de sortie : $OUTPUT_FILE"