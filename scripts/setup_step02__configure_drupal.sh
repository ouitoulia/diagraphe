#!/usr/bin/env bash

# This script performs the initial configuration of Ouitoulía.
# The first parameter is a string and allows you to choose the admin password.
# If you run the script without parameters it will generate a random password.
# Use `drush uli` to get an access token.

echo -e "\n\n-- Installo Ouitoulía -------------------------------------------"
drush -y site:install minimal --locale=it --account-pass=${1}

echo -e "\n\n-- Localizzazione in Italiano -----------------------------------"
drush -y config:set system.date country.default IT
drush -y config:set system.date first_day 1
drush -y config:set system.date timezone.default Europe/Rome
drush -y config:set core.date_format.long pattern 'l, j F Y - H:i'
drush -y config:set core.date_format.medium pattern 'D, d/m/Y - H:i'
drush -y config:set core.date_format.short pattern 'd/m/Y - H:i'

echo -e "\n\n-- Imposto il numero massimo di caratteri nel sommario ----------"
drush -y config:set text.settings default_summary_length 160

echo -e "\n\n-- Attivo il tema di amministrazione ----------------------------"
drush -y theme:enable claro
drush -y config:set system.theme admin claro
drush -y config:set node.settings use_admin_theme 1
drush -y pm:install toolbar admin_toolbar admin_toolbar_tools

echo -e "\n\n-- Solo gli amministratori possono registrare nuovi utenti ------"
drush -y config:set user.settings register admin_only

echo -e "\n\n-- Installo e configuro i moduli base ---------------------------"
drush -y pm:install field entity_reference_display
