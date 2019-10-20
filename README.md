# The quick installation and configuration of Vagrant in the php project

## Prerequisites

Before you start, install the Vigrant binaries from this location:
 
 [https://www.vagrantup.com/intro/getting-started/install.html](https://www.vagrantup.com/intro/getting-started/install.html)
 
 You will also need to install the Virtual Box from : 
 
 [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
 
 ## Installation

To install the package please run

```
composer require hkwak/qvagrant
```

After the installation please copy the file located in ./vagrant/hkwak/qvagrant/Vagrantfile into your root package folder
and install the public and var directories.
The public folder will be used by the apache server as a root directory, whilst the var folder will be used for storing log files 

```
cp ./vendor/hkwak/qvagrant/Vagrantfile .; mkdir public; mkdir var
``` 
Additionally create some index file in the public folder to be able to access it via browser:

```
 echo "<?php phpinfo();" > ./public/index.php
```

By default the IP of the hosting is set to : 192.168.10.10 and the domain is set to : vagrant.local.
In order bo to be able to access the hosted website you need to add the following entry to your hosts file:

```
192.168.10.10   vagrant.local
```

## Mysql

The default configuration of the mysql admin user is :

```
DATABASE="vagrant"
REMOTE_USER="vagrant"
REMOTE_PASSWORD="password"
```

## Running the vagrant box
To run the vagrant box type:
```
vagrant up
```
To stop: 
```
vagrant halt
```
To connect to the box via ssh:
```
vagrant ssh
```

One the vagrant box is up you can visit the page by opening https://vagrant.local in your browser

 
 
 
