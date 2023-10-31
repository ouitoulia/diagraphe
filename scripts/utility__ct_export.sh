#!/usr/bin/env bash
################################################################################
#
#  Questo è uno script che estrae in maniera selettiva i ct senza campi storage
#
#  Author: Pietro Arturo Panetta
#  Site: https://www.drupal.org/u/arturopanetta
#  Copyright: @arturu 2023
#  License: GPL-3.0-only
#
################################################################################

# node.type.bundle    Status
config_status=$(drush config:status | awk '/^  [a-zA-Z]/ {print $1}')

filtered_lines=$(echo "$config_status" | awk '/node\.type/')

content_types=()
while IFS= read -r line; do
  content_type=$(echo "$line" | awk -F '.' '{print $3}')
  content_types+=("$content_type")
done <<< "$filtered_lines"

echo "Quale content type desideri esportare? [numero]: "
select chosen_type in "${content_types[@]}"; do
  if [[ -n $chosen_type ]]; then
    echo "Hai scelto il content type: $chosen_type"
    break
  else
    echo "Opzione non valida. Riprova."
  fi
done

read -p "Inserisci la cartella di salvataggio (vuoto per creare una cartella con il nome del content type): " folder

# Verifico se la cartella di salvataggio è stata specificata,
# altrimenti imposto come cartella di salvataggio il nome del content type
if [[ -z "$folder" ]]; then
  folder="$chosen_type"
fi

# Verifico se la cartella di salvataggio esiste già
if [[ -d "$folder" ]]; then
  echo "La cartella di salvataggio '$folder' esiste già. Esportazione annullata."
  exit 1
fi

# Creazione della cartella di salvataggio
mkdir -p "$folder"

# Variabile dove verrà salvato il risultato dei filtri eseguiti
# su $config_status con il content type scelto
filtered_config=""

# Elenco di pattern di configurazioni che corrispondono al content type scelto
config_patterns=(
  "core.base_field_override.node.$chosen_type"
  "core.entity_form_display.node.$chosen_type"
  "field.field.node.$chosen_type"
  "language.content_settings.node.$chosen_type"
  "node.type.$chosen_type"
  "pathauto.pattern.*$chosen_type"
)

# Itero su ogni riga in $config_status
while IFS= read -r line; do
  # Verifico se la riga corrisponde a uno dei pattern specificati
  for pattern in "${config_patterns[@]}"; do
    if [[ $line =~ ^$pattern ]]; then
      filtered_config+="$line"$'\n'
      break
    fi
  done
done <<< "$config_status"

# Salvo le configurazioni
for config in $filtered_config; do
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
