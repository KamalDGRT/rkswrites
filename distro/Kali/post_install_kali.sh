#!/bin/bash

clear

banner() {
    printf "\n\n\n"
    msg="| $* |"
    edge=$(echo "$msg" | sed 's/./-/g')
    echo "$edge"
    echo "$msg"
    echo "$edge"
}

pause() {
    read -s -n 1 -p "Press any key to continue . . ."
    clear
}

enable_grub_menu() {
    # Find & Replace part contributed by: https://github.com/nanna7077
    clear
    banner "Showing the GRUB menu at boot"
    printf "\n\nThe script will change the grub default file."
    printf "\n\nThe file is: /etc/default/grub\n"
    printf "\nIn that file, there will be a line that looks like this:"
    printf "\n\n     GRUB_TIMEOUT=5\n\n"
    printf "\nThe script will change the value of GRUB_TIMEOUT to -1.\n"

    SUBJECT='/etc/default/grub'
    SEARCH_FOR='GRUB_TIMEOUT='
    sudo sed -i "/^$SEARCH_FOR/c\GRUB_TIMEOUT=-1" $SUBJECT
    printf "\n/etc/default/grub file changed.\n"

    banner "Showing the GRUB menu at boot"
    printf "\n\nGenerating the new GRUB configuration\n\n"
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    printf "\n\nGRUB config updated. It will be reflected in the next boot.\n\n"
}

install_Xclip() {
    banner "Installing xclip"
    printf"\e[1;32m\n\nUpdating the package cache...\n\e[0m"
    sudo apt update

    printf "\e[1;32m\nInstalling: xclip\n\e[0m"
    sudo apt install -y xclip
}

install_Figlet() {
    banner "\nInstalling Figlet\n"
    sudo apt install -y figlet
}

gitsetup() {
    banner "Setting up SSH for git and GitHub"

    read -e -p "Enter your GitHub Username                 : " GITHUB_USERNAME
    read -e -p "Enter the GitHub Email Address             : " GITHUB_EMAIL_ID
    read -e -p "Enter the default git editor (vim / nano)  : " GIT_CLI_EDITOR

    if [[ $GITHUB_EMAIL_ID != "" && $GITHUB_USERNAME != "" && $GIT_CLI_EDITOR != "" ]]; then
        printf "\n - Configuring GitHub username as: ${GITHUB_USERNAME}"
        git config --global user.name "${GITHUB_USERNAME}"

        printf "\n - Configuring GitHub email address as: ${GITHUB_EMAIL_ID}"
        git config --global user.email "${GITHUB_EMAIL_ID}"

        printf "\n - Configuring Default git editor as: ${GIT_CLI_EDITOR}"
        git config --global core.editor "${GIT_CLI_EDITOR}"

        printf "\n - Fast Forwarding All the changes while git pull"
        git config --global pull.ff only

        printf "\n - Generating a new SSH key for ${GITHUB_EMAIL_ID}"
        printf "\n\nJust press Enter and add passphrase if you'd like to. \n\n"
        ssh-keygen -t ed25519 -C "${GITHUB_EMAIL_ID}"

        printf "\n\nAdding your SSH key to the ssh-agent..\n"

        printf "\n - Start the ssh-agent in the background..\n"
        eval "$(ssh-agent -s)"

        printf "\n\n - Adding your SSH private key to the ssh-agent\n\n"
        ssh-add ~/.ssh/id_ed25519

        printf "\n - Copying the SSH Key Content to the Clipboard..."

        printf "\n\nLog in into your GitHub account in the browser (if you have not)"
        printf "\nOpen this link https://github.com/settings/keys in the browser."
        printf "\nClik on New SSH key."
        xclip -selection clipboard <~/.ssh/id_ed25519.pub
        printf "\nGive a title for the SSH key."
        printf "\nPaste the clipboard content in the textarea box below the title."
        printf "\nClick on Add SSH key.\n\n"
        pause
    else
        printf "\nYou have not provided the details correctly for Git Setup."
        if ask_user "Want to try Again ?"; then
            gitsetup
        else
            printf "\nSkipping: Git and GitHub SSH setup..\n"
        fi
    fi
}

rks_gnome_themes() {
    banner "Changing the default GNOME theme"
    printf "\e[1;32m\n\nChanging the default GNOME theme\e[0m"

    currentDirectory=$(pwd)

    printf "\e[1;32m\n\nEnabling User Themes Extension...\e[0m"
    gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com

    printf "\e[1;32m\nCreating a directory to clone the KamalDGRT/rks-gnome-themes repo..\e[0m"
    if [ -d ~/RKS_FILES/GitRep ]; then
        printf "\e[1;32m\nDirectory exists.\nSkipping the creation step..\n\e[0m"
    else
        mkdir -p ~/RKS_FILES/GitRep
    fi

    printf "\n\e[1;32mGoing inside ~/RKS_FILES/GitRep\n\e[0m"
    cd ~/RKS_FILES/GitRep

    printf "\n\e[1;32mChecking if the KamalDGRT/rks-gnome-themes repository exists...\e[0m"
    if [ -d ~/RKS_FILES/GitRep/rks-gnome-themes ]; then
        printf "\n\e[1;32mRepository exists. \nSkipping the cloning step..\n\e[0m"
    else
        printf "\n\e[1;32mRepository does not exist in the system..\e[0m"
        printf "\n\e[1;32mCloning the GitHub Repo: KamalDGRT/rks-gnome-themes\n\e[0m"
        git clone https://github.com/KamalDGRT/rks-gnome-themes.git
    fi

    printf "\e[1;32m\nGoing inside rks-gnome-themes directory...\n\e[0m"
    cd rks-gnome-themes

    printf "\e[1;32m\n\nChecking if ~/.themes directory exists...\e[0m"
    if [ -d ~/.themes ]; then
        printf "\e[1;32m\Directory exists. \nSkipping the creation step..\n\e[0m"
    else
        printf "\e[1;32m\nDirectry does not exist in the system..\e[0m"
        printf "\e[1;32m\nCreating .themes at location ~/\e[0m"
        mkdir ~/.themes
    fi

    printf "\e[1;32m\n\nChecking if ~/.icons directory exists...\e[0m"
    if [ -d ~/.icons ]; then
        printf "\e[1;32m\Directory exists. \nSkipping the creation step..\n\e[0m"
    else
        printf "\e[1;32m\nDirectry does not exist in the system..\e[0m"
        printf "\e[1;32m\nCreating .icons at location ~/\e[0m"
        mkdir ~/.icons
    fi

    printf "\e[1;32m\n\nCopying the Flat-Remix-Blue-Dark Icon Theme\e[0m"
    cp -rf Icon/Flat-Remix-Blue-Dark ~/.icons

    printf "\e[1;32m\n\nCopying the Mojave-dark-solid-alt Theme\e[0m"
    cp -rf Theme/Mojave-dark-solid-alt ~/.themes

    printf "\e[1;32m\n\nCopying the Kimi-dark Theme\e[0m"
    cp -rf Theme/Kimi-dark ~/.themes

    printf "\e[1;32m\nChanging Interface Theme to : Kimi-dark\e[0m"
    gsettings set org.gnome.desktop.interface gtk-theme "Kimi-dark"

    printf "\e[1;32m\nChanging WM Theme to : Mojave-dark-solid-alt\e[0m"
    gsettings set org.gnome.shell.extensions.user-theme name 'Mojave-dark-solid-alt'

    printf "\e[1;32m\nChanging Icon Theme to : Flat-Remix-Blue-Dark\e[0m"
    gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue-Dark"

    printf "\e[1;32m\n\nComing back to th present working directory\n\n\e[0m"
    cd "${currentDirectory}"
}

configure_title_bar() {
    banner "Configure Title Bar"
    printf "\e[1;32m\n\nShowing Battery Percentage\e[0m"
    gsettings set org.gnome.desktop.interface show-battery-percentage true

    printf "\e[1;32m\nShow Time in 12 hour format\e[0m"
    gsettings set org.gnome.desktop.interface clock-format 12h

    printf "\e[1;32m\nShow the seconds in Clock\e[0m"
    gsettings set org.gnome.desktop.interface clock-show-seconds true

    printf "\e[1;32m\nShow the Weekday in Clock\n\n\e[0m"
    gsettings set org.gnome.desktop.interface clock-show-weekday true

    printf "\e[1;32m\nAdding Minimize and Maximize buttons on the left\n\n\e[0m"
    gsettings set org.gnome.desktop.wm.preferences button-layout "close,maximize,minimize:"

    printf "\e[1;32m\nEnable Tray Icons\n\n\e[0m"
    gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
}

install_Brave() {
    banner "Installing Brave Browser"

    printf "\e[1;32m\n\nInstalling Brave Browser\e[0m"
    printf "\e[1;32m\nInstalling requirements - apt-transport-https, curl\e[0m"
    sudo apt install apt-transport-https curl

    printf "\e[1;32m\nDownloading Brave Browser keyring\e[0m"
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

    printf "\e[1;32m\nAdding source for Brave Browser in apt list\e[0m"
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

    printf "\e[1;32m\nFetching version to upgrade\e[0m"
    sudo apt update

    printf "\nInstalling brave-browser package\e[0m"
    sudo apt install brave-browser
}

install_Discord() {
    banner "Installing discord tar file"

    printf "\e[1;32m\n\nDownloading discord tar file\e[0m"
    cd ~/Downloads
    wget -O discord.tar.gz 'https://discord.com/api/download?platform=linux&format=tar.gz'

    printf "\e[1;32m\nExtracting discord tar file\e[0m"
    sudo tar -xvzf discord.tar.gz -C /opt

    printf "\e[1;32m\nAdding symbolic link on /usr/bin/Discord\e[0m"
    sudo ln -sf /opt/Discord/Discord /usr/bin/Discord

    printf "\e[1;32m\nCopying discord.desktop to /usr/share/applications\e[0m"
    sudo cp -r /opt/Discord/discord.desktop /usr/share/applications

    printf "\e[1;32m\nInstalling libatomic1\e[0m"
    sudo sudo apt install libatomic1

    printf "\e[1;32m\nAdding executable file for discord.desktop\e[0m"
    SUBJECT='/usr/share/applications/discord.desktop'
    SEARCH_FOR='Exec='
    sudo sed -i "/^$SEARCH_FOR/c\/usr/bin/Discord" $SUBJECT

    printf "\e[1;32m\nAdding icon for discord.desktop\e[0m"
    SEARCH_FOR='Icon='
    sudo sed -i "/^$SEARCH_FOR/c\/opt/Discord/discord.png" $SUBJECT
}

install_Telegram() {
    banner "Installing Telegram"
    printf "\e[1;32m\n Install Telegram\e[0m"
    sudo apt install telegram-desktop
}

install_snapd() {
    banner "Installing Snap"

    printf "\e[1;32m\n\nInstalling snapd and apparmor\e[0m"
    sudo apt install snapd apparmor

    printf "\e[1;32m\nStarting snapd.socket and enabling to start on boot\e[0m"
    sudo systemctl enable --now snapd.socket

    printf "\e[1;32m\nStarting apparmor.socket and enabling to start on boot\e[0m"
    sudo systemctl enable --now apparmor.service

    printf "\e[1;32m\nEnabling Classic Snap Support by creating the symbolic link\e[0m"
    sudo ln -s /var/lib/snapd/snap /snap
}

install_NeoFetch() {
    banner "Installing Neofetch"

    printf "\e[1;32m\nInstalling NeoFetch\e[0m"
    sudo apt-get install neofetch
}

install_Audio_Tools() {
    banner "Installing Audio Tools"

    printf "\e[1;32m\nInstalling Audio Tools\e[0m"
    sudo apt install -y pulseaudio pavucontrol alsa-utils alsa-ucm-conf
}

install_NVIDIA_drivers() {
    banner "Installing NVIDIA drivers"

    printf "\e[1;32m\nInstall NVDIA-Drivers\e[0m"
    sudo apt install nvidia-driver nvidia-cuda-toolkit
}

install_gdebi() {
    banner "Installing gdebi"

    printf "\e[1;32m\nInstall gdebi\e[0m"
    sudo apt install gdebi
}

install_MS_Fonts() {
    banner "Installing MS Fonts"

    printf "\e[1;32m\n\nInstalling Microsoft Core Fonts\e[0m"
    sudo apt-get install ttf-mscorefonts-installer
}

install_Sublime_Text() {
    banner "Installing Sublime Text"

    printf "\e[1;32m\nInstalling Sublime Text\e[0m"
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    sudo apt-get install apt-transport-https
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt-get update
    sudo apt-get install sublime-text
}

install_Kotlin() {
    banner "Installing Kotlin CLI"

    printf"\e[1;32m\nInstalling kotlin compiler...\e[0m"
    sudo snap install --classic kotlin
}

install_Django() {
    banner "Installing Django Admin"

    printf"\e[1;32m\nInstalling django-admin...\e[0m"
    sudo apt install python3 python3-django python3-pip -y
}

install_gh_CLI() {
    banner "Installing gh CLI"
    printf"\e[1;32m\nAdding gh repository in apt...\e[0m"
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
    sudo apt-add-repository https://cli.github.com/packages

    printf"\e[1;32m\nFetching the packages details...\e[0m"
    sudo apt update

    printf"\e[1;32m\nInstalling gh CLI using apt...\e[0m"
    sudo apt install gh -y
}

install_Heroku_CLI() {
    banner "Installing Heroku CLI"
    printf"\e[1;32m\nInstalling Heroku CLI using apt...\e[0m"
    curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
}

install_VSCode() {
    banner "Installing Visual Studio Code"
    printf "\e[1;32m\nInstalling Microsoft Visual Studio Code...\e[0m"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt install apt-transport-https
    sudo apt update
    sudo apt install code
}

install_PyCharm_Community_Edition() {
    banner "Installing PyCharm Community Edition"
    printf "\e[1;32m\nInstalling IntelliJ PyCharm Community Edition\e[0m"
    cd ~/Downloads
    wget -O pycharm.tar.gz https://download.jetbrains.com/python/pycharm-community-2021.1.3.tar.gz
    sudo tar xzf pycharm.tar.gz -C /opt/
    sudo mv /opt/pycharm-*/ /opt/pycharm/
    cd /opt/pycharm/bin
    sh pycharm.sh
}

install_Pip() {
    banner "Installing PIP and VENV"
    sudo apt install python3-pip python3-venv
}

install_YoutubeDL() {
    banner "Installing Youtube-DL"
    sudo apt install youtube-dl
}

install_and_configure_LAMP() {
    banner "Installing and Configuring LAMPP"
    cd ~/Downloads

    printf "\e[1;32m\n\nInstalling necessary LAMP stack packages\e[0m"
    sudo apt install -y apache2 mariadb-server mariadb-client php \
        libapache2-mod-php wget php php-cgi php-mysqli php-pear \
        php-mbstring libapache2-mod-php php-common php-xml \
        php-xmlrpc php-soap php-cli php-zip php-bcmath php-tokenizer \
        php-json php-curl php-gd php-phpseclib php-mysql composer xclip

    printf "\e[1;32m\nStarting apache2.socket and enabling to start on boot\e[0m"
    sudo systemctl enable --now apache2

    printf "\e[1;32m\nStarting snapd.socket and enabling to start on boot\e[0m"
    sudo systemctl enable --now mariadb

    printf "\e[1;32m\nEnabling basic security measures for the MariaDB database\e[0m"
    yes | sudo mysql_secure_installation

    printf "\e[1;32m\nAdding root user with Test@12345 as password\e[0m"
    sudo mysqladmin -u root password 'Test@12345'

    printf "\e[1;32m\nDownloading PHP tar file\e[0m"
    wget -O phpmyadmin.tar.gz 'https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz'

    printf "\e[1;32m\nDownloading keyring for phpmyadmin\e[0m"
    wget 'https://files.phpmyadmin.net/phpmyadmin.keyring'

    printf "\e[1;32m\nImporting phpmyadmin keyring\e[0m"
    gpg --import phpmyadmin.keyring

    printf "\e[1;32m\nDownloading phpmyadmin tar file\e[0m"
    wget -O phpmyadmin.tar.gz.asc 'https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz.asc'

    printf "\e[1;32m\nVerifyiny phpmyadmin tar file\e[0m"
    gpg --verify phpmyadmin.tar.gz.asc

    printf "\e[1;32m\nCreating phpmyadmin directory on /var/www/html/\e[0m"
    sudo mkdir /var/www/html/phpmyadmin/

    printf "\e[1;32m\nExtracting and exporting phpmyadmin.tar.gz\e[0m"
    sudo tar xvf phpmyadmin.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin

    printf "\e[1;32m\nCopying config.sample.inc.php as config.inc.php\e[0m"
    sudo cp /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php

    printf "\e[1;32m\nGenerating random password and copying to clipboard\e[0m\n"
    openssl rand -base64 32 | xclip -selection clipboard
    printf "\e[1;32mPassword is copied\n"
    printf "\e[1;32m\nSet the passphrase for cfg['blowfish_secret'] with the copied password \e[0m\n"
    pause
    sudo nano /var/www/html/phpmyadmin/config.inc.php

    printf "\e[1;32m\nGiving permission for group and root to read-write and resctricting all permission for others\e[0m"
    sudo chmod 660 /var/www/html/phpmyadmin/config.inc.php

    printf "\e[1;32m\nChanging symbolic links ownership \e[0m"
    sudo chown -R www-data:www-data /var/www/html/phpmyadmin

    printf "\e[1;32m\nRestarting the apache2 socket\e[0m"
    sudo systemctl restart apache2

    printf "\e[1;32m\nEnabling the RewriteEngine\e[0m"
    sudo a2enmod rewrite

    printf "\e[1;32m\nReloading the apache2 service\e[0m"
    sudo systemctl reload apache2

    printf "\e[1;32m\nAdding Laravel Installer globally\e[0m"
    composer global require laravel/installer

    printf "\e[1;32m\nGetting the updated php.ini\e[0m"
    wget 'https://raw.githubusercontent.com/KamalDGRT/linux-conf/main/Kali/lampp/php.ini' -P ~/Downloads

    printf "\e[1;32m\nCreating backup of the current php.ini file...\e[0m"
    sudo cp /etc/php/7.4/apache2/php.ini /etc/php/7.4/apache2/php.ini.backup

    printf "\e[1;32m\n\nCopying the updated php.ini\e[0m"
    sudo cp ~/Downloads/php.ini /etc/php/7.4/apache2/php.ini

    printf "\e[1;32m\nRestarting the apache2 service\e[0m"
    sudo systemctl restart apache2
}

install_qBittorrent() {
    banner "Installing qBittorrent"
    sudo apt install -y qbittorrent
}

install_Everything() {
    gitsetup

    install_Xclip
    install_NeoFetch
    install_Figlet
    install_Audio_Tools
    install_MS_Fonts

    install_gdebi
    install_Pip
    install_YoutubeDL
    install_snapd

    rks_gnome_themes
    configure_title_bar

    install_Brave
    install_Discord
    install_Telegram
    install_Sublime_Text
    install_Kotlin
    install_Django
    install_gh_CLI
    install_Heroku_CLI
    install_VSCode
    install_and_configure_LAMP
    install_qBittorrent
    install_NVIDIA_drivers
}
