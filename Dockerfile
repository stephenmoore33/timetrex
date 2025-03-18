FROM ubuntu:xenial

# MAINTAINER Josh Lukens <jlukens@botch.com>

ENV DEBIAN_FRONTEND noninteractive

USER root

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# MY ENV
ENV DEBIAN_FRONTEND=noninteractive
ENV BASE_URL=http://localhost:80
ENV HOST_NAME="localhost"
ENV URL_POSTFIX="/timetrex/interface"
ENV ADMIN_EMAIL=admin@example.com
ENV DB_HOST=db
ENV DB_NAME=timetrex
ENV DB_USER=timetrex
ENV DB_PASS=timetrex
ENV EMAIL_DELIVERY_METHOD="smtp"
ENV EMAIL_SMTP_HOST="smtp.gmail.com"
ENV EMAIL_SMTP_PORT=587
ENV EMAIL_SMTP_USERNAME="timetrex@gmail.com"
ENV EMAIL_SMTP_PASSWORD="testpass123"
ENV EMAIL_DOMAIN="mydomain.com"
ENV EMAIL_LOCAL_PART="DoNotReply"
ENV PRODUCTION="TRUE"
ENV FORCE_SSL="FALSE"
ENV ENABLE_CSRF_VALIDATION="FALSE"
ENV DISABLE_AUTO_UPGRADE="TRUE"


RUN apt-get update -y -qq && \
    apt-get dist-upgrade -y && \
    apt-get install -y locales software-properties-common && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \

# install tools
    apt-get install -y supervisor vim unzip wget && \

# install TimeTrex prequirements
    apt-get install -y apache2 libapache2-mod-php php php7.0-cgi php7.0-cli php7.0-pgsql php7.0-pspell php7.0-gd php7.0-gettext php7.0-imap php7.0-intl php7.0-json php7.0-soap php7.0-zip php7.0-mcrypt php7.0-curl php7.0-ldap php7.0-xml php7.0-xsl php7.0-mbstring php7.0-bcmath postgresql && \

# clean up
    apt-get autoclean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \

# install timetrex
    cd /tmp  && \
#    wget http://www.timetrex.com/direct_download/TimeTrex_Community_Edition_v11.0.2.zip && \
#    unzip TimeTrex_Community_Edition_v11.0.2.zip -d /var/www/html/ && \
#    rm -f /tmp/TimeTrex_Community_Edition_v11.0.2.zip && \
#    wget http://www.timetrex.com/download/TimeTrex_Community_Edition-manual-installer.zip && \
# new link
    wget https://raw.githubusercontent.com/stephenmoore33/timetrex/main/TimeTrex_Community_Edition-manual-installer.zip && \
    unzip TimeTrex_Community_Edition-manual-installer.zip -d /var/www/html/ && \
    rm -f /tmp/TimeTrex_Community_Edition-manual-installer.zip && \
    mv /var/www/html/TimeTrex* /var/www/html/timetrex && \
    chgrp www-data -R /var/www/html/timetrex/ && \
    chmod 775 /var/www/html/timetrex && \
    mkdir /database && \
    chown -R postgres: /database && \
    sed -i "s#data_directory =.*#data_directory = '/database'#" /etc/postgresql/9.5/main/postgresql.conf && \
    chsh -s /bin/bash www-data


COPY ["supervisord.conf", "httpd.conf", "maint.conf", "postgres.conf", "/etc/supervisor/conf.d/"]
COPY ["*.sh", "/"]
COPY ["mpm_prefork.conf", "/etc/apache2/mods-available/mpm_prefork.conf"]
COPY ["timetrex.ini.php.dist", "/"]
EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]