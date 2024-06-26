#!/usr/bin/env sh

# This script performs the initial configuration of Ouitoulía.
# The first parameter is a string and allows you to choose the admin password.
# If you run the script without parameters it will generate a random password.
# Use `drush uli` to get an access token.

printf "\n\n-- Installo Ouitoulía ------------------------------------------\n"
drush -y site:install minimal --locale=it --account-pass=${1}

printf "\n\n-- Localizzazione in Italiano ----------------------------------\n"
drush -y config:set system.date country.default IT
drush -y config:set system.date first_day 1
drush -y config:set system.date timezone.default Europe/Rome
drush -y config:set core.date_format.long pattern 'l, j F Y - H:i'
drush -y config:set core.date_format.medium pattern 'D, d/m/Y - H:i'
drush -y config:set core.date_format.short pattern 'd/m/Y - H:i'

printf "\n\n-- Imposto il numero massimo di caratteri nel sommario ---------\n"
drush -y config:set text.settings default_summary_length 160

printf "\n\n-- Attivo il tema di amministrazione ---------------------------\n"
drush -y theme:enable claro
drush -y config:set system.theme admin claro
drush -y config:set node.settings use_admin_theme 1
drush -y pm:install toolbar admin_toolbar admin_toolbar_tools

printf "\n\n--  Solo gli amministratori possono registrare nuovi utenti ----\n"
drush -y config:set user.settings register admin_only

printf "\n\n-- Installo e configuro i moduli base --------------------------\n"
drush -y pm:install field entity_reference_display

printf "\n\n-- Impostazioni di default del modulo core/file ----------------\n"
drush -y config:set file.settings filename_sanitization.transliterate 1
drush -y config:set file.settings filename_sanitization.replace_whitespace 1
drush -y config:set file.settings filename_sanitization.replace_non_alphanumeric 1
drush -y config:set file.settings filename_sanitization.deduplicate_separators 1
drush -y config:set file.settings filename_sanitization.lowercase 1
