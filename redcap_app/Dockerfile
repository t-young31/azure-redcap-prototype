FROM appsvc/php:7.4-apache_20211102.4

# OS setup
RUN apt-get update && \
    apt-get install --yes --no-install-recommends cron python3 python3-pip sendmail && \
    python3 -m pip install requests beautifulsoup4

# Site setup
WORKDIR /wwwroot
RUN wget --no-check-certificate https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem

# Copy the directory into the root and setup
COPY redcap .
RUN echo "*  *    * * *   root    /usr/local/bin/php /home/site/wwwroot/cron.php > /dev/null" >> /etc/crontab

COPY settings.ini entrypoint.sh print_sql_command.py /
ENTRYPOINT ["/entrypoint.sh"]
