#!/bin/bash

# Function to display error messages and exit
error_exit() {
    echo "$1" 1>&2
    exit 1
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

# Create public_html directory
sudo -u "$USERNAME" mkdir -p "$PUBLIC_HTML" || error_exit "Failed to create public directory."

# Set directory permissions
sudo chmod 755 "$USER_HOME" || error_exit "Failed to set permissions for $USER_HOME."

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

# Enable the new site and reload Apache
sudo a2ensite "$WEBSITE.conf" || error_exit "Failed to enable site $WEBSITE."
sudo systemctl reload apache2 || error_exit "Failed to reload Apache."

# Enable the rewrite module and restart Apache
sudo a2enmod rewrite || error_exit "Failed to enable rewrite module."
sudo systemctl restart apache2 || error_exit "Failed to restart Apache."

# Update /etc/hosts
sudo bash -c "echo $HOST_ENTRY >> /etc/hosts" || error_exit "Failed to update /etc/hosts."

# Create an index.php file in the public_html directory
sudo bash -c "cat > $PUBLIC_HTML/index.php" <<EOF
<?php
echo "Welcome to $WEBSITE!";
?>
EOF

# Change ownership of the index.php file to the created user
sudo chown "$USERNAME:$USERNAME" "$PUBLIC_HTML/index.php" || error_exit "Failed to change ownership of index.php."

echo "Configuration complete. The site is available at http://www.$WEBSITE"
