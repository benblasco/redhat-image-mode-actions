FROM registry.redhat.io/rhel9/rhel-bootc:9.6

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

# Harden the image using the ACSC Essential 8 profile
# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/security-hardening-and-compliance-of-bootable-images#building-hardened-bootable-images_security-hardening-and-compliance-of-bootable-images
RUN oscap-im --profile e8 /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml

#clean up caches in the image and lint the container
RUN rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf
RUN bootc container lint

EXPOSE 80
