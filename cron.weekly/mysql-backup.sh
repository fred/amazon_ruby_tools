#!/bin/bash
export AMAZON_ACCOUNT_ID="203884546599"
export AMAZON_ACCESS_KEY_ID="1520PNAT8S8GRPN0Z182"
export AMAZON_SECRET_ACCESS_KEY="AwNE1QCEp80nKNMM01YLH5xHExRXqt61iWioowcY"
export AMAZON_BUCKET_NAME="ruberion_backups"
/usr/bin/ruby /root/fred_ruby_tools/mysql_backup_S3.rb >> /var/log/mysql_backup_S3.log
