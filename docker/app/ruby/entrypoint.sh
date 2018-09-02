#!/bin/bash
set -e

bundle check --path vendor/bundle || bundle install --path vendor/bundle
exec "$@"
