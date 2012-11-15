#!/bin/bash

# P'unk Avenue Loadout: install recommended packages for web development

port install git-core mod_fastcgi mysql5-server php5-apc php5-curl php5-exif php5-gd php5-iconv php5-posix php5-imap php5-intl php5-mbstring php5-mcrypt php5-mysql php5-openssl php5-soap php5-xsl php5-mongo php5-sqlite unrar wget mongodb sqlite3 nodejs npm redis &&
mysql_install_db5 --user=mysql &&
chmod 644 /opt/local/etc/LaunchDaemons/org.macports.apache2/org.macports.apache2.plist &&
chmod 644 /opt/local/etc/LaunchDaemons/org.macports.mysql5/org.macports.mysql5.plist &&
chmod 644 /opt/local/etc/LaunchDaemons/org.macports.mongodb/org.macports.mongodb.plist &&
sudo launchctl load -w /Library/LaunchDaemons/org.macports.mysql5.plist &&
echo "Sleeping 10 seconds to let MySQL become ready..." &&
sleep 10 &&
/opt/local/lib/mysql5/bin/mysqladmin -u root password 'root' &&
sudo launchctl load -w /Library/LaunchDaemons/org.macports.apache2.plist &&
sudo launchctl load -w /Library/LaunchDaemons/org.macports.mongodb.plist &&
sudo launchctl load -w /Library/LaunchDaemons/org.macports.redis.plist &&

ln -s /opt/local/bin/mysql5 /opt/local/bin/mysql && 
ln -s /opt/local/bin/mysqldump5 /opt/local/bin/mysqldump && 
echo "Success!"
