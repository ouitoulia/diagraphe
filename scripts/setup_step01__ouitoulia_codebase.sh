#!/usr/bin/env sh

# This script install Ouitoulía codebase.
# You can use this script to build your own images as well.

# composer create ouitoulia/diagraphe:^10.x-dev --no-install --no-cache

composer require drush/drush --no-install
composer install