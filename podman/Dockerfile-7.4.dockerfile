FROM rockylinux:8

# Set working directory
WORKDIR /app

# Install EPEL, PowerTools, and essential tools
RUN set -eux; \
    dnf install -y epel-release dnf-plugins-core && \
    dnf config-manager --set-enabled powertools && \
    dnf makecache

# Install Apache, mod_ssl, wget, git, tar, xz
RUN set -eux; \
    dnf install -y httpd mod_ssl wget git tar xz && \
    dnf clean all && rm -rf /var/cache/dnf

# Install Remi repository and PHP 7.4
RUN set -eux; \
    dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm && \
    dnf module reset -y php && \
    dnf module enable -y php:remi-7.4 && \
    dnf install -y \
        php php-cli php-fpm php-mysqlnd php-mbstring php-xml php-gd php-xdebug php-ldap \
    && dnf clean all && rm -rf /var/cache/dnf

# Install Node 18 LTS and npm
RUN set -eux; \
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash - && \
    dnf install -y nodejs gcc-c++ make && \
    dnf clean all && rm -rf /var/cache/dnf

RUN dnf install -y fuse-sshfs && dnf clean all && rm -rf /var/cache/dnf


# Add php to path
ENV PATH="${PATH}:/opt/remi/php74/root/usr/bin:/opt/remi/php74/root/usr/sbin"
 
# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/tmp --filename=composer
 
# Copy config
COPY httpd.conf /etc/httpd/conf/

RUN chmod 744 /etc/httpd/conf/httpd.conf
 
EXPOSE 8082 9003
ENTRYPOINT ["/app/SynchWeb/entrypoint.bash", "-7"]
