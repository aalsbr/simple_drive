#!/bin/bash

# Script to reset the database with the improved schema
echo "Dropping the database..."
rails db:drop

echo "Creating a new database..."
rails db:create

echo "Loading the schema..."
rails db:schema:load

echo "Seeding the database with test data..."
rails db:seed

echo "Database reset completed with improved schema!"
echo "The following tables are now available:"
echo "- blobs (with storage_provider and reference_path)"
echo "- blob_binary_storages (replacing blob_contents)"
echo "- auth_tokens"

echo "\nYou can now start the server with: rails server"
