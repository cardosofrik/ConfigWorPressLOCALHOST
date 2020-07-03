#! /bin/bash -x
#sh wordpress.sh
#Script, auxiliar a instalação do WordPress localhost no Ubuntu.
# Ajusta o WordPress para utilizar  Sqlite.
#Instala configura e especifica a permissão.
msg="""
Tec: \n
1 - Php\n
2 - Sqlite3\n
3 - Apache\n
3 - WordPress\n
"""
echo $msg
echo "php"
add-apt-repository ppa:ondrej/php
apt install apt-transport-https lsb-release ca-certificates curl -y
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt update
download='
php7.4 php7.4-common php7.4-cli
php7.4-curl php7.4-mbstring php7.4-bz2 php7.4-readline php7.4-intl
php7.4-bcmath php7.4-bz2 php7.4-curl php7.4-intl php7.4-mbstring php7.4-readline php7.4-xml php7.4-zip
libapache2-mod-php7.4
php7.4-sqlite3'
for url in $download
 do
  echo "Instalara `apt-get install $url`"
done

echo "WordPress"
wordpressSQLITE='
https://br.wordpress.org/latest-pt_BR.tar.gz
https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip'
for ws in $wordpressSQLITE 
 do
  echo "Baixando `wget $ws`"
done

tar -xvzf latest-pt_BR.tar.gz 
unzip sqlite-integration.1.8.1.zip

echo "Configurando wordpress"
mv -v sqlite-integration wordpress/wp-content/plugins/
mv -v wordpress/wp-content/plugins/sqlite-integration/db.php wordpress/wp-content/
mv -v wordpress/wp-config-sample.php wp-config.php

echo "Configurando Apache"

touch /etc/apache2/sites-available/wordpress.conf
echo "<Directory /usr/share/wordpress>" >> wordpress.conf
echo "Options FollowSymLinks" >> wordpress.conf
echo "AllowOverride Limit Options FileInfo" >> wordpress.conf
echo "DirectoryIndex index.php" >> wordpress.conf
echo "Order allow,deny" >> wordpress.conf
echo "Allow from all" >> wordpress.conf
echo "</Directory>" >> wordpress.conf
echo "<Directory /usr/share/wordpress/wp-content>" >> wordpress.conf
echo "Options FollowSymLinks" >> wordpress.conf
echo "Order allow,deny" >> wordpress.conf
echo "Allow from all" >> wordpress.conf
echo "</Directory>" >> wordpress.conf

a2enmod rewrite
apache2ctl configtest
touch wordpress/.htaccess
mkdir wordpress/wp-content/upgrade

echo "Copiando para diretorio do apache"
cp -r wordpress/ /var/www/html/
echo "Permissões"
echo """Adicionando permissão usuario e grupo\n
USUARIO : GRUPO\n
www-data:www-data
"""
chown -R www-data:www-data /var/www/html/wordpress

#Permissões

echo """Aplicando permissões no diretorio:\n
 u = usuario : ler,escrever exec\n
 g = grupo : ler exec.\n
 o = outros : nada\n"""
echo """Aplicando permissões no arquivo:\n
 u = usuario : ler, escreve\n
 g = group : ler, exec\n
 o = outros : sem permissoes\n
"""
find /var/www/html/wordpress/ -type d -exec chmod u=rwx,g=rx,o=-rwx \{\} \;
#arquivos
# u = usuario : ler escrever
# g = grupo ler
# o = outros NÃO podem ler escrever exec.
find /var/www/html/wordpress/ -type f -exec chmod u=rw,g=r,o=-rwx \{\} \;

echo "Finalizado"
