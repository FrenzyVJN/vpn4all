#!/bin/bash

# Define the file path
RESOLVED_CONF="/etc/systemd/resolved.conf"

# Backup the original file
sudo cp "$RESOLVED_CONF" "${RESOLVED_CONF}.backup.$(date +%F_%T)"

# Ensure the [Resolve] section exists, or add it if missing
if ! grep -q "^\[Resolve\]" "$RESOLVED_CONF"; then
    echo "[Resolve]" | sudo tee -a "$RESOLVED_CONF" > /dev/null
fi

# Add or update the DNSStubListenerExtra line
if grep -q "^DNSStubListenerExtra=" "$RESOLVED_CONF"; then
    # Update existing line
    sudo sed -i 's/^DNSStubListenerExtra=.*/DNSStubListenerExtra=127.0.0.1:5353/' "$RESOLVED_CONF"
else
    # Append the line under [Resolve]
    sudo sed -i '/^\[Resolve\]/a DNSStubListenerExtra=127.0.0.1:5353' "$RESOLVED_CONF"
fi

# Ensure DNSStubListener=no is present
if ! grep -q "^DNSStubListener=no" "$RESOLVED_CONF"; then
    sudo sed -i '/^\[Resolve\]/a DNSStubListener=no' "$RESOLVED_CONF"
fi

# Restart systemd-resolved to apply changes
sudo systemctl restart systemd-resolved

# Provide feedback
echo "The /etc/systemd/resolved.conf has been updated and systemd-resolved restarted."
