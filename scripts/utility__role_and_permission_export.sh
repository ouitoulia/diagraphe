#!/usr/bin/env bash
################################################################################
#
#  Questo è uno script che estrae in maniera selettiva i permessi
#
#  Author: Pietro Arturo Panetta
#  Site: https://www.drupal.org/u/arturopanetta
#  Copyright: @arturu 2023
#  License: AGPL-3.0-only
#
################################################################################

config_status=$(drush config:status)

# user.role
filtered_lines=$(echo "$config_status" | awk '/user\.role\./ && /Only in DB/ {print $1}')

# Cartella di salvataggio
read -p "Inserisci la cartella di salvataggio (vuoto per creare una cartella con il nome 'roles'): " folder

# Verifico se la cartella di salvataggio è stata specificata,
# altrimenti imposto 'roles' come cartella di salvataggio
if [[ -z "$folder" ]]; then
  folder="roles"
fi

# Verifico se la cartella di salvataggio esiste già
if [[ -d "$folder" ]]; then
  echo "La cartella di salvataggio '$folder' esiste già. Esportazione annullata."
  exit 1
fi

# Creazione della cartella di salvataggio
mkdir -p "$folder"

# Salvo le configurazioni
for config in $filtered_lines; do
  file="$folder/$config.yml"
  drush_config=$(drush config:get "$config" --format=yaml)

  # Rimuovo la chiave uuid
  drush_config=$(echo "$drush_config" | sed '/^uuid:/d')

  # Rimuovo la chiave _core e le righe successive che iniziano con due spazi
  drush_config=$(echo "$drush_config" | sed '/^_core:/,+1d')

  # Verifica se l'estrazione della configurazione è riuscita
  if [[ -n $drush_config ]]; then
    # Salvo il contenuto serializzato in $file
    echo "$drush_config" > "$file"
    # Mostro lo stato di avanzamento
    echo "Ho salvato ${config}.yml"
  else
    # Se l'estrazione della configurazione ha fallito
    echo "Errore durante l'estrazione della configurazione: $config"
  fi
done

echo "Esportazione completata!"
