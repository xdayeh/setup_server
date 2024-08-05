# setup_server
This Bash script automates the process of setting up a new user, configuring a virtual host in Apache, and creating a basic index.php file in the user's public HTML directory on an Ubuntu system. The script performs the following tasks:

User Creation: Creates a new user with a specified username, home directory, and Bash shell.
Password Setup: Prompts the administrator to set a password for the new user.
Directory Setup: Creates a public_html directory in the user's home directory and sets the appropriate permissions.
Apache Configuration: Copies the default Apache configuration, customizes it for the new virtual host, and enables the site.
Apache Modules and Services: Enables the rewrite module and restarts the Apache service to apply changes.
Hosts File Update: Adds an entry to the /etc/hosts file to map the new domain to 127.0.0.1.
Index.php Creation: Creates a basic index.php file in the user's public_html directory and sets the correct ownership.
