#!/bin/sh
set -e # Exit on error

echo "🚀 Starting application entrypoint..."

echo "🔄 Running database migrations..."
node src/migrations/migrate.js

if [ $? -eq 0 ]; then # Check previous command exit status i.e if migrations completed successfully
    echo "✅ Migrations completed successfully"
    echo "🌟 Starting server..."
    exec node src/server.js
else
    echo "❌ Migration failed, exiting..."
    exit 1
fi