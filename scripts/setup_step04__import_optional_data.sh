#!/usr/bin/env bash

# This script performs the initial configuration of Ouitoulía.
# Run this script in the location where your composer.json is.

# Lista migrazioni opzionali (impostazione di default)
opzioni=("demo" "menu_opzionali" "taxonomy_indirizzi_di_studio_infanzia" "taxonomy_indirizzi_di_studio_primaria" "taxonomy_indirizzi_di_studio_secondaria_primo_grado" "taxonomy_indirizzi_di_studio_secondaria_secondo_grado" "taxonomy_indirizzi_di_studio_universita" "taxonomy_indirizzi_di_studio_afam" "taxonomy_materie_secondaria_primo_grado" "taxonomy_materie_secondaria_secondo_grado" "taxonomy_materie_laboratori")

# Controllo se viene passata una lista diversa tramite parametro
if [[ $# -ge 1 && "$(declare -p "$1" 2>/dev/null)" =~ "declare -a" ]]; then
  # Se il primo argomento è un array, lo assegno a opzioni
  opzioni=("${!1}")
fi

# Funzione per trasformare il nome della migrazione in un formato più leggibile
format_migrazione() {
  local migrazione="$1"
  # Rimuovo il prefisso "taxonomy_"
  migrazione="${migrazione#taxonomy_}"

  # Sostituisco "_" con " "
  migrazione="${migrazione//_/ }"

  if [[ $1 == "demo" ]]; then
    migrazione="il $1"
  else
    migrazione="i dati: $migrazione"
  fi
  echo "$migrazione"
}

for opzione in "${opzioni[@]}"; do
  nome_migrazione_formattata=$(format_migrazione "$opzione")

  read -rp "Vuoi importare ${nome_migrazione_formattata}? [si/no] (no): " risposta
  risposta=${risposta:-no}

  if [[ $risposta == "si" || $risposta == "yes" || $risposta == "s" || $risposta == "y" ]]; then
    if [[ $opzione == "demo" ]]; then
      drush migrate:import --update --all
      break
    else
      drush migrate:import --update "$opzione"
    fi
  fi
done
