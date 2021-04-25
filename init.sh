#!/bin/bash

default_password="Azerty45"

is_installed() {
  inst="$(which $1)"
}

end() {
  echo -e ""
  echo -e "\e[33mComputer will reboot in 10 seconds, everything should be well configured, cheers!\e[0m"
  echo -e "\e[33mPasswords for Xavier and Yohan have been created ($default_password), don't forget to change them with chpasswd command\e[0m"
  sleep 10
  reboot
}

check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "Please run as root"
    exit
  fi
}

conclusion() {
  is_installed $1
  if [ "$inst" != "" ]; then
    echo -e "\e[32m[+]\e[0m $1 is now installed"
  else
    echo -e "\e[31m[-]\e[0m Failed to install $1"
  fi
}

# npm
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -

sudo apt install git vim zsh nodejs build-essential fonts-powerline net-tools xclip openssh-client openssh-server ssmtp

#shell
if [ "$(cat ~/.zshrc | grep agnoster)" = "" ]; then
  echo -e "\e[33m[.]\e[0m Installing zsh config"
  sudo chsh -s /bin/zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  sed -i 's/robbyrussell/agnoster/g' ~/.zshrc
  mkdir -p ~/.zsh
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
  mv zsh-syntax-highlighting ~/.zsh
  echo -e "source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>${ZDOTDIR:-$HOME}/.zshrc
  sudo adduser -D -s /bin/zsh

  # should install globally oh-my-zsh
fi

# docker

is_installed docker
if [ "$inst" = "" ]; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
  usermod -aG docker xavier
  usermod -aG docker yohan
fi
conclusion docker

#user creation

sudo useradd -m xavier
sudo useradd -m yohan
echo xavier:$default_password | sudo chpasswd
echo yohan:$default_password | sudo chpasswd
sudo usermod -aG sudo xavier
sudo usermod -aG sudo yohan
sudo chsh -s /bin/zsh xavier
sudo chsh -s /bin/zsh yohan
sudo cp -r .zsh* /home/xavier
sudo cp -r .zsh* /home/yohan
cd ~
echo "Azot users added successfully!"

# put the users ssh key on the server

#ssh config
if [ ! -f ~/.ssh/id_rsa.pub ]; then
  ssh-keygen -t rsa -b 4096

fi

#ssh key
if [ ! -f ~/.ssh/id_rsa.pub ]; then
  echo -e "\e[33m[.]\e[0m Installing ssh config"
  ssh-keygen
  xclip -sel clip <~/.ssh/id_rsa.pub
  echo -e "You can now paste your ssh key in github"
fi

# TODO check IP public accessibility configuration

# TODO change port


# TODO configure email

# https://blog.edmdesigner.com/send-email-from-linux-command-line/
# send email with
# ssh command server@publicip
# how to check passwords
# you have to change your password which is Azerty45
# from local user on linux - ssh-copy-id -i ~/.ssh/mykey user@host
# add lines to the right file to connect directly
# no permit password to connect on server
# install zsh on both users
# delete raspberry user




# check secure

# list of users
# check passwords != azerty45
# check if all rsa keys
