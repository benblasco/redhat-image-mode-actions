FROM registry.redhat.io/rhel10/rhel-bootc:latest

#Using the optional heredoc format to help simplify the number of times we call RUN
#install software
RUN <<EORUN
set -xeuo pipefail

dnf -y group install "Server with GUI"
dnf clean all
rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf

systemctl set-default graphical.target

EORUN


#configure bootc-user
RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel bootc-user -p $pass

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

#lint the container
RUN bootc container lint
