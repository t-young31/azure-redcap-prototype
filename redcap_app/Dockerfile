FROM appsvc/php:8.0-apache_20211102.4

# OS setup
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
    cron python3 python3-pip # sendmail

# Site setup
WORKDIR /home/site/wwwroot
RUN rm hostingstart.html && \
    wget --no-check-certificate https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem

# Copy the directory into the root and setup
COPY ./redcap/* .
RUN echo "session.cookie_secure = On" >> /home/site/redcap.ini && \
    echo "* * * * * /usr/local/bin/php /home/site/wwwroot/cron.php > /dev/null" >> /etc/crontab

ENTRYPOINT ["./entrypoint.sh"]
