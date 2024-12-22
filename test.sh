#!/bin/bash

# Fonction pour afficher l'animation de loading
loading_animation() {
  
  local pid=$1  # PID du processus à surveiller
  local status_text=$2
  local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
  while kill -0 $pid 2>/dev/null; do
    for (( i=0; i<${#chars}; i++ )); do
      echo -ne "\r[${chars:$i:1}] $status_text..."  # Affiche sur la même ligne
      sleep 0.2
    done
  done
  
}

# Exemple de commande à exécuter
long_running_command() {
  echo "Exécution de la commande longue..."
  sleep 5  # Simulation d'une tâche longue
  return 1  # Simule une erreur (code de sortie != 0)
}

# Lancement de la commande en arrière-plan
long_running_command &
cmd_pid=$!
loading_animation $cmd_pid "En cours"
wait $cmd_pid  
exit_code=$?

# Affichage du résultat
if [ $exit_code -eq 0 ]; then
    
  echo -e "\r[✔ ] Terminé avec succès !"  # Efface l'animation et affiche le succès
else
  echo -e "\r[✖ ] Échec de la commande (code: $exit_code)."  # Efface l'animation et affiche l'erreur
fi
