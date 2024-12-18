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

C_PROGRAM="./codeC/cwire"
MAKEFILE_DIR="codeC"
if [[ ! -f "$C_PROGRAM" ]]; then
    echo "Compilation du programme C..."
    (cd "$MAKEFILE_DIR" && make)
    if [[ $? -ne 0 ]]; then
        echo "Erreur : Échec de la compilation du programme C."
        exit 1
    fi
fi


FILTERED_FILE="$TMP_DIR/filtered_data.csv"
if [[ -n "$CENTRAL_ID" ]]; then
    grep ";$CENTRAL_ID;" "$CSV_FILE" > "$FILTERED_FILE"
else
    cp "$CSV_FILE" "$FILTERED_FILE"
fi


OUTPUT_FILE="tests/${STATION_TYPE}_${CONSUMER_TYPE}.csv"
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


if [[ "$STATION_TYPE" == "lv" && "$CONSUMER_TYPE" == "all" ]]; then
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

