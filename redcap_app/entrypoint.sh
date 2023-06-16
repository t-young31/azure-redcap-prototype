#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -x trace

function init_database_if_required(){

    mssql_command=$(python3 /print_sql_command.py)

    if [ "$mssql_command" = "none" ]; then
        echo "Database is initialised already"
    else
        echo "Initalising database"
        mysql --host-name "$APPSETTING_DBHostName" \
            --user "$APPSETTING_DBUserName" \
            --password"$APPSETTING_DBPassword" \
            --database "$APPSETTING_DBName" \
            --ssl  <<EOF
$mssql_command
UPDATE $APPSETTING_DBName.redcap_config SET value = 'https://$WEBSITE_HOSTNAME/' WHERE field_name = 'redcap_base_url';
UPDATE $APPSETTING_DBName.redcap_config SET value = '$APPSETTING_StorageAccount' WHERE field_name = 'azure_app_name';
UPDATE $APPSETTING_DBName.redcap_config SET value = '$APPSETTING_StorageKey' WHERE field_name = 'azure_app_secret';
UPDATE $APPSETTING_DBName.redcap_config SET value = '$APPSETTING_StorageContainerName' WHERE field_name = 'azure_container';
UPDATE $APPSETTING_DBName.redcap_config SET value = '4' WHERE field_name = 'edoc_storage_option';
REPLACE INTO $APPSETTING_DBName.redcap_config (field_name, value) VALUES ('azure_quickstart', '1');
EOF
    fi
}

function webserver_is_up(){
    # If the server is up then we should be able to curl the index page quickly
    curl --max-time 5 "localhost:${WEBSITES_PORT}"
}

# Replace connection values
database_php_path="/wwwroot/database.php"
sed -i "s/.*your_mysql_host_name/\$hostname = \'$APPSETTING_DBHostName\';/g" "$database_php_path"
sed -i "s/.*your_mysql_db_name/\$db = \'$APPSETTING_DBName\';/g" "$database_php_path"
sed -i "s/.*your_mysql_db_username/\$username = \'$APPSETTING_DBUserName\';/g" "$database_php_path"
sed -i "s/.*your_mysql_db_password/\$password = \'$APPSETTING_DBPassword\';/g" "$database_php_path"
sed -i "s|db_ssl_ca[[:space:]]*= '';|db_ssl_ca = '$APPSETTING_DBSslCa';|" "$database_php_path"
sed -i "s/db_ssl_verify_server_cert = false;/db_ssl_verify_server_cert = true;/" "$database_php_path"
sed -i "s/\$salt = '';/\$salt = '$(echo $RANDOM | md5sum | head -c 20; echo;)';/" "$database_php_path"

# Configure reccomended settings
settings_path="/home/site/redcap.ini"
cp /settings.ini "$settings_path"
sed -i "s/replace_smtp_server_name/$APPSETTING_smtpFQDN/" "$settings_path"
sed -i "s/replace_smtp_port/$APPSETTING_smtpPort/" "$settings_path"
sed -i "s/replace_sendmail_from/$APPSETTING_fromEmailAddress/" "$settings_path"
sed -i "s:replace_sendmail_path:/usr/sbin/sendmail -t -i:" "$settings_path"

a2enmod headers  # enable apache headers module
echo "Header set MyHeader \"%D %t"\" >> /etc/apache2/apache2.conf
echo "Header always unset \"X-Powered-By\"" >> /etc/apache2/apache2.conf
echo "Header unset \"X-Powered-By\"" >> /etc/apache2/apache2.conf

service cron start 

# Move files as azure webapps mount things into /home/site/wwwroot/, for some reason
rm -rf /home/site/wwwroot/*
cp -rs /wwwroot/* /home/site/wwwroot/  # symlinking is faster than moving

# Call base entrypoint to start apache in the background
/bin/init_container.sh  &

while [ ! webserver_is_up ]; do
    sleep 5
done

init_database_if_required
wait 
