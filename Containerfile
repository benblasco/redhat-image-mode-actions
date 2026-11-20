FROM registry.redhat.io/rhel10/rhel-bootc:latest

#install software
RUN dnf -y install tmux mkpasswd

#configure bootc-user
RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel bootc-user -p $pass

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

#Using the optional heredoc format to help simplify the number of times we call RUN
RUN <<EORUN
set -xeuo pipefail

#configure web server and relocate the webroot to be read-only and managed by this container image
dnf -y install httpd openscap-utils scap-security-guide

dnf clean all
systemctl enable httpd
mv /var/www /usr/share/www
sed -ie 's,/var/www,/usr/share/www,' /etc/httpd/conf/httpd.conf
echo "Welcome to the bootc-http instance!" > /usr/share/www/html/index.html

EORUN

# Harden the image using the Australian Cyber Security Centre (ACSC) ISM Official - Base profile
# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/secure-harden_and_secure_bootc_images_2
RUN oscap-im --profile ism_o /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml

#clean up caches in the image and lint the container
RUN rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf
RUN bootc container lint

EXPOSE 80
