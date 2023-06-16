FROM appsvc/php:7.4-apache_20211102.4

# OS setup
RUN apt-get install --yes --no-install-recommends \
    cron python3 python3-pip # sendmail

# Site setup
WORKDIR /home/site/wwwroot
RUN rm hostingstart.html && \
    wget --no-check-certificate https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem

# Copy the directory into the root and setup
COPY redcap /home/site/wwwroot
RUN echo "session.cookie_secure = On" >> /home/site/redcap.ini && \
    echo "* * * * * /usr/local/bin/php /home/site/wwwroot/cron.php > /dev/null" >> /etc/crontab

COPY entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]
