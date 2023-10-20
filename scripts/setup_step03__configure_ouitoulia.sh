#!/usr/bin/env bash

# This script performs the initial configuration of Ouitoulía.
# Run this script in the location where your composer.json is.

echo "-- Installo il tema ----------------------------------------------------"
drush -y pm:install components big_pipe inline_form_errors responsive_image
drush -y theme:enable bootstrap_italia skenografia
drush -y config:set system.theme default skenografia

echo "-- Installo i vocabolari -----------------------------------------------"
drush -y pm:install lexika

echo "-- Importo le voci di tassonomia ---------------------------------------"
drush -y pm:install sunchronizo_lexika
drush migrate:import --all

echo "-- Installo i tipi di Media gestiti ------------------------------------"
drush -y pm:install bibliotheke

echo "-- Installo il modulo utenti -------------------------------------------"
drush -y pm:install prosopon

echo "-- Installo i campi usati dalle entità Node ----------------------------"
drush -y pm:install themethla

# Fix node_reference module for minimal profile
drush -y config:import --partial --source="$(drush drupal:directory)/themes/contrib/bootstrap_italia/modules/bootstrap_italia_paragraph_node_reference/config/optional"

echo "-- Importo i ruoli dell'entity 'User' ----------------------------------"
drush -y pm:install sunchronizo_prosopon
drush migrate:import scuola_roles

echo "Configuro i permessi ---------------------------------------------------"
drush -y pm:install exesti