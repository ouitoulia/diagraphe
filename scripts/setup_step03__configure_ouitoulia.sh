#!/usr/bin/env bash

# This script performs the initial configuration of Ouitoulía.
# Run this script in the location where your composer.json is.

echo "-- Installo i vocabolari -----------------------------------------------"
composer require ouitoulia/lexika --no-cache
drush -y en lexika

echo "-- Importo le voci di tassonomia ---------------------------------------"
composer require ouitoulia/sunchronizo_lexika --no-cache
drush -y en sunchronizo_lexika
drush migrate:import --all

echo "-- Installo i tipi di Media gestiti ------------------------------------"
composer require ouitoulia/bibliotheke --no-cache
drush -y pm:install bibliotheke

echo "-- Installo i campi usati dalle entità Node ----------------------------"
composer require ouitoulia/themethla --no-cache
drush -y pm:install themethla

echo "-- Installo il tipo di contenuto Persona -------------------------------"
composer require ouitoulia/prosopon --no-cache
drush -y pm:install prosopon

echo "-- Installo il tipo di contenuto Luogo ---------------------------------"
composer require ouitoulia/topographia --no-cache
drush -y pm:install topographia

echo "-- Importo i ruoli dell'entity 'User' ----------------------------------"
composer require ouitoulia/sunchronizo_prosopon --no-cache
drush -y pm:install sunchronizo_prosopon
drush migrate:import scuola_roles
