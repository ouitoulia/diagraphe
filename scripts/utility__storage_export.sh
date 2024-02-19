#!/usr/bin/env bash
################################################################################
#
#  Questo è uno script che estrae in maniera selettiva i campi storage
#
#  Author: Pietro Arturo Panetta
#  Site: https://www.drupal.org/u/arturopanetta
#  Copyright: @arturu 2023
#  License: AGPL-3.0-only
#
################################################################################

config_status=$(drush config:status)

# field.storage.entity.field_machine_name    Status 
field_storage_configs=$(echo "$config_status" | awk '/field\.storage\./ && /Only in DB/ {print $1}')

# Lista entity
entity_list=()

# Estrae le entity uniche dall'elenco delle configurazioni di storage dei campi
while read -r line; do
  # [id] field.storage.entity.field_machine_name
  entity=$(echo "$line" | awk -F 'field\.storage\.' '{print $2}' | awk -F '.' '{print $1}')
  if [[ ! " ${entity_list[@]} " =~ " $entity " ]]; then
    entity_list+=("$entity")
  fi
done <<< "$field_storage_configs"

echo "Entity disponibili:"
for ((i=0; i<${#entity_list[@]}; i++)); do
  echo "[$(($i+1))] ${entity_list[$i]}"
done

read -p "Seleziona l'entity da cui estrarre i campi di storage (inserisci il numero): " choice

# Verifico la scelta dell'utente
if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]] || [[ "$choice" -gt ${#entity_list[@]} ]]; then
  echo "Scelta non valida. Uscita."
  exit 1
fi

selected_entity=${entity_list[$(($choice-1))]}

# Cartella di salvataggio
read -p "Inserisci la cartella di salvataggio (vuoto per creare una cartella con il nome dell'entity): " folder

# Verifico se la cartella di salvataggio è stata specificata,
# altrimenti imposto come cartella di salvataggio il nome dell'entity
if [[ -z "$folder" ]]; then
  folder="$selected_entity"
fi

# Verifico se la cartella di salvataggio esiste già
if [[ -d "$folder" ]]; then
  echo "La cartella di salvataggio '$folder' esiste già. Esportazione annullata."
  exit 1
fi

# Filtro le configurazioni basate sull'entity selezionata
filtered_configurations=$(echo "$field_storage_configs" | awk -F '.' -v entity="$selected_entity" '$3 == entity')

# Creazione della cartella di salvataggio
mkdir -p "$folder"

# Salvo le configurazioni
for config in $filtered_configurations; do
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
