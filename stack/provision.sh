# installing tools

echo "Updating system"
export DEBIAN_FRONTEND=noninteractive
apt-get update > /dev/null
apt-get upgrade -y > /dev/null

echo "Setting timezone"
echo "Europe/London" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata >& /dev/null

echo "Installing MySQL"
echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections
apt-get install -y mysql-server > /dev/null
apt-get install -y mysql-client > /dev/null

echo "Installing Apache"
apt-get install -y apache2 > /dev/null

echo "Installing PHP"
apt-get install software-properties-common
add-apt-repository ppa:ondrej/php
apt-get update
apt-get install -y php7.1 > /dev/null
apt-get install -y php7.1-cli > /dev/null
apt-get install -y php7.1-common > /dev/null
apt-get install -y php7.1-json > /dev/null
apt-get install -y php7.1-opcache > /dev/null
apt-get install -y php7.1-mysql > /dev/null
apt-get install -y php7.1-mcrypt > /dev/null
apt-get install -y php7.1-curl > /dev/null
apt-get install -y php7.1-gd > /dev/null
apt-get install -y php7.1-mbstring > /dev/null
apt-get install -y php7.1-fpm > /dev/null
apt-get install -y php7.1-soap > /dev/null
apt-get install -y php7.1-xml > /dev/null
apt-get install -y php7.1-zip > /dev/null

echo "Installing XDebug"
apt-get install php-xdebug > /dev/null
echo "[Xdebug]" > /etc/php/7.1/mods-available/xdebug.ini
echo 'zend_extension="/usr/lib/php/20151012/xdebug.so"' >> /etc/php/7.1/mods-available/xdebug.ini
echo "xdebug.remote_enable=true" >> /etc/php/7.1/mods-available/xdebug.ini
echo "xdebug.remote_connect_back=true" >> /etc/php/7.1/mods-available/xdebug.ini
echo "xdebug.idekey=PHPSTORM" >> /etc/php/7.1/mods-available/xdebug.ini

echo "Installing ImageMagick"
apt-get install -y imagemagick > /dev/null
apt-get install -y imagemagick-6.q16 > /dev/null

echo "Installing ZIP"
apt-get install -y zip > /dev/null

echo "Installing libraries"
apt-get install -y libapache2-mod-php > /dev/null
apt-get install -y libmysqlclient20 > /dev/null

echo "Configuring PHP"
sed -i \
    -e 's/^max_execution_time\s*=.*$/max_execution_time = 60/' \
    -e 's/^error_reporting\s*=.*$/error_reporting = E_ALL/' \
    -e 's/^html_errors\s*=.*$/html_errors = Off/' \
    -e 's/^post_max_size\s*=.*$/post_max_size = 24M/' \
    -e 's/^upload_max_filesize\s*=.*$/upload_max_filesize = 32M/' \
    -e 's/^session\.gc_probability\s*=.*$/session.gc_probability = 1/' \
    /etc/php/7.1/apache2/php.ini

echo "Configuring MySQL"

cat > /etc/mysql/conf.d/bytemark.cnf <<"END"
[mysqld]
innodb_file_per_table = on
max_connections = 151
END

cat > /etc/mysql/mysql.conf.d/mysqld.cnf <<"END"
[mysqld]
sql_mode = "STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
END

# let mysql listen to the outside world
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

DATABASE="vagrant"
REMOTE_USER="vagrant"
REMOTE_PASSWORD="password"

echo "Create Database and Setting up '${REMOTE_USER}' mysql user"

mysql --default-character-set=utf8 -uroot -proot 2> /dev/null <<END
CREATE DATABASE IF NOT EXISTS ${DATABASE} DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;

DROP USER IF EXISTS '${REMOTE_USER}'@'%';
CREATE USER '${REMOTE_USER}'@'%' IDENTIFIED BY '${REMOTE_PASSWORD}';

GRANT ALL PRIVILEGES ON *.* TO '${REMOTE_USER}'@'%';

FLUSH PRIVILEGES;
END

service mysql restart

echo "Configuring Apache"
if [ ! -f /etc/apache2/conf-available/fqdn.conf ]
then

  echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf
  a2enconf fqdn > /dev/null
fi

# generating self signed certificates
if [ ! -f /etc/ssl/certs/cert.crt ]
then

  echo "Generating SSL certificate... "

  # generate private key with no password
  openssl genrsa -out /etc/ssl/private/cert.key 1024

  # generate self-signed certificate
  openssl req \
    -new \
    -x509 \
    -days 3650 \
    -key /etc/ssl/private/cert.key \
    -out /etc/ssl/certs/cert.crt \
    -subj "/CN=vagrant.local"
fi

# always update the default apache ssl config file
cat /vagrant/vendor/hkwak/qvagrant/stack/apache-default-ssl.template \
> "/etc/apache2/sites-available/000-default-ssl.conf"

a2ensite 000-default-ssl
a2dissite 000-default

a2disconf serve-cgi-bin > /dev/null

a2dismod -f autoindex > /dev/null
a2enmod mime_magic > /dev/null
a2enmod rewrite > /dev/null
a2enmod socache_shmcb > /dev/null
a2enmod ssl > /dev/null

service apache2 restart

# installing composer
curl --silent https://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer

# installing node.js
apt-get -y install nodejs