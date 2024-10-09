#!/bin/bash

# Function to display error messages and exit
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Function to test Apache configuration before reloading
check_apache_config() {
    sudo apachectl configtest
    if [ $? -ne 0 ]; then
        error_exit "Apache configuration is invalid. Please fix the configuration."
    fi
}

# Prompt the user for the username and website
read -p "Enter the username: " USERNAME
read -p "Enter the website (e.g., example.com): " WEBSITE

# Validate inputs
if [[ -z "$USERNAME" || -z "$WEBSITE" ]]; then
    error_exit "Username and website cannot be empty."
fi

# Define variables
USER_HOME="/home/$USERNAME"
PUBLIC_HTML="$USER_HOME/public"
APACHE_CONF="/etc/apache2/sites-available/$WEBSITE.conf"
HOST_ENTRY="127.0.0.1 www.$WEBSITE"

# Add the user and check for errors
sudo useradd -m -s /bin/bash "$USERNAME" || error_exit "Failed to add user $USERNAME."

# Set the user password (prompts for input)
echo "Please set a password for $USERNAME:"
sudo passwd "$USERNAME" || error_exit "Failed to set password for $USERNAME."

# Create public_html directory and set ownership and permissions
sudo -u "$USERNAME" mkdir -p "$PUBLIC_HTML" || error_exit "Failed to create public directory."
sudo chown "$USERNAME:$USERNAME" "$PUBLIC_HTML" || error_exit "Failed to change ownership for $PUBLIC_HTML."
sudo chmod 755 "$PUBLIC_HTML" || error_exit "Failed to set permissions for $PUBLIC_HTML."

# Copy the default Apache configuration and edit it
sudo cp /etc/apache2/sites-available/000-default.conf "$APACHE_CONF" || error_exit "Failed to copy Apache config."

# Append Apache configuration for the new site
sudo bash -c "cat > $APACHE_CONF" <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@$WEBSITE
    ServerName $WEBSITE
    ServerAlias www.$WEBSITE
    DocumentRoot $PUBLIC_HTML
    <Directory $PUBLIC_HTML>
        Options Indexes FollowSymLinks
        AllowOverride all
        Require all granted
        Options -Indexes
        ServerSignature Off
    </Directory>
</VirtualHost>
EOF

# Set global ServerName to suppress AH00558 warning
if ! grep -q "ServerName" /etc/apache2/apache2.conf; then
    echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
fi

# Enable the new site
sudo a2ensite "$WEBSITE.conf" || error_exit "Failed to enable site $WEBSITE."

# Test the Apache configuration before reloading
check_apache_config

# Restart Apache only if configuration is valid
sudo systemctl restart apache2 || error_exit "Failed to restart Apache."

# Enable the rewrite module and restart Apache
sudo a2enmod rewrite || error_exit "Failed to enable rewrite module."
sudo systemctl reload apache2 || error_exit "Failed to reload Apache."

# Update /etc/hosts
if ! grep -q "$HOST_ENTRY" /etc/hosts; then
    sudo bash -c "echo $HOST_ENTRY >> /etc/hosts" || error_exit "Failed to update /etc/hosts."
fi

# Create an index.php file in the public_html directory
sudo bash -c "cat > $PUBLIC_HTML/index.php" <<EOF
<?php
echo "Welcome to $WEBSITE!";
?>
EOF

# Change ownership of the index.php file to the created user
sudo chown "$USERNAME:$USERNAME" "$PUBLIC_HTML/index.php" || error_exit "Failed to change ownership of index.php."

echo "Configuration complete. The site is available at http://www.$WEBSITE"
