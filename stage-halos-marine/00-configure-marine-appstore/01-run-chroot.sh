#!/bin/bash -e

# This runs in the chroot environment (inside the image being built)
# Configure the marine app store to be added on first boot via direct database insertion

MARINE_APPSTORE_SLUG="marine"
MARINE_APPSTORE_NAME="Marine"
MARINE_APPSTORE_URL="https://github.com/hatlabs/runtipi-marine-app-store"
MARINE_APPSTORE_BRANCH="main"

echo "Configuring marine app store to be added on first boot..."

# Create a script that adds the app store directly to the database
cat > /usr/local/bin/add-marine-appstore.sh <<'SCRIPT_EOF'
#!/bin/bash -e

SLUG="marine"
NAME="Marine"
URL="https://github.com/hatlabs/runtipi-marine-app-store"
BRANCH="main"

# Calculate SHA256 hash of the URL
HASH=$(echo -n "${URL}" | sha256sum | cut -d' ' -f1)

echo "Waiting for Runtipi database to be ready..."
for i in {1..60}; do
    if docker exec runtipi-db pg_isready -U tipi -d tipi >/dev/null 2>&1; then
        echo "Database is ready"
        break
    fi
    sleep 2
done

# Check if database is ready after waiting
docker exec runtipi-db pg_isready -U tipi -d tipi >/dev/null 2>&1 || { echo 'Database failed to become ready'; exit 1; }
# Additional wait to ensure database migrations are complete
sleep 5

# Check if app store already exists
EXISTS=$(docker exec runtipi-db psql -U tipi -d tipi -t -c "SELECT COUNT(*) FROM app_store WHERE slug='${SLUG}';" 2>/dev/null | tr -d ' ')

if [ "$EXISTS" -eq "0" ]; then
    echo "Adding ${NAME} app store to database..."
    docker exec runtipi-db psql -U tipi -d tipi -c \
        "INSERT INTO app_store (slug, hash, name, enabled, url, branch, \"createdAt\", \"updatedAt\")
         VALUES ('${SLUG}', '${HASH}', '${NAME}', true, '${URL}', '${BRANCH}', NOW(), NOW());" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "✓ Successfully added ${NAME} app store"
        exit 0
    else
        echo "✗ Failed to add ${NAME} app store to database"
        exit 1
    fi
else
    echo "✓ ${NAME} app store already exists"
    exit 0
fi
SCRIPT_EOF

chmod +x /usr/local/bin/add-marine-appstore.sh

# Create a systemd one-shot service to add the app store on first boot
cat > /etc/systemd/system/add-marine-appstore.service <<EOF
[Unit]
Description=Add Marine App Store to Runtipi
After=runtipi.service docker.service
Requires=runtipi.service docker.service

[Service]
Type=oneshot
# Add the marine app store via direct database insertion
ExecStart=/usr/local/bin/add-marine-appstore.sh
# Disable the service after successful execution
ExecStartPost=/bin/systemctl disable add-marine-appstore.service
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
systemctl enable add-marine-appstore.service

echo "Marine app store service configured - will be added via database insertion on first boot"
