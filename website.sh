#!/bin/bash

# Prompt the user for the username and website
read -p "Enter the username: " USERNAME
read -p "Enter the website (e.g., example.com): " WEBSITE

# Define variables
USER_HOME="/home/$USERNAME"
PUBLIC_HTML="$USER_HOME/public"
APACHE_CONF="/etc/apache2/sites-available/$WEBSITE.conf"
HOST_ENTRY="127.0.0.1 www.$WEBSITE"

# Add the user
sudo useradd -m -s /bin/bash "$USERNAME"

# Set the user password (prompts for input)
echo "Please set a password for $USERNAME:"
sudo passwd "$USERNAME"

# Create public_html directory
sudo -u "$USERNAME" mkdir -p "$PUBLIC_HTML"

# Set directory permissions
sudo chmod 755 "$USER_HOME"

# Copy the default Apache configuration and edit it
sudo cp /etc/apache2/sites-available/000-default.conf "$APACHE_CONF"

# Append Apache configuration for the new site
sudo bash -c "cat > $APACHE_CONF" <<EOF
<VirtualHost *:80>
    ServerAdmin yqd@hotmail.com
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
sudo a2ensite "$WEBSITE.conf"
sudo systemctl reload apache2

# Enable the rewrite module and restart Apache
sudo a2enmod rewrite
sudo systemctl restart apache2

# Update /etc/hosts
sudo bash -c "echo $HOST_ENTRY >> /etc/hosts"

# Create an index.php file in the public_html directory
sudo bash -c "cat > $PUBLIC_HTML/index.php" <<EOF
<?php
echo "Welcome to $WEBSITE!";
?>
EOF

# Change ownership of the index.php file to the created user
sudo chown "$USERNAME:$USERNAME" "$PUBLIC_HTML/index.php"

echo "Configuration complete. The site is available at http://www.$WEBSITE"
