# Setup Server

This Bash script automates the process of setting up a new user, configuring a virtual host in Apache, and creating a basic `index.php` file in the user's public HTML directory on an Ubuntu system. 

## Features

The script performs the following tasks:

1. **User Creation**: Creates a new user with a specified username, home directory, and Bash shell.
2. **Password Setup**: Prompts the administrator to set a password for the new user.
3. **Directory Setup**: Creates a `public` directory in the user's home directory and sets the appropriate permissions.
4. **Apache Configuration**: Copies the default Apache configuration, customizes it for the new virtual host, and enables the site.
5. **Apache Modules and Services**: Enables the `rewrite` module and restarts the Apache service to apply changes.
6. **Hosts File Update**: Adds an entry to the `/etc/hosts` file to map the new domain to `127.0.0.1`.
7. **Index.php Creation**: Creates a basic `index.php` file in the user's `public` directory and sets the correct ownership.

## Usage

Follow these steps to use the script:

1. Download the script using `curl`:
   ```bash
   curl -O https://raw.githubusercontent.com/xdayeh/setup_server/main/website.sh
2. Make the script executable:
   ```bash
   chmod +x website.sh
3. Run the script with sudo privileges:
   ```bash
   sudo ./website.sh
