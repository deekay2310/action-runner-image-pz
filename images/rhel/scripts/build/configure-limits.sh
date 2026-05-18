#!/bin/bash -e
################################################################################
##  File:  configure-limits.sh
##  Desc:  Configure limits
################################################################################
echo 'session required pam_limits.so' >> /etc/pam.d/system-auth
echo 'session required pam_limits.so' >> /etc/pam.d/password-auth
echo 'DefaultLimitNOFILE=65536' >> /etc/systemd/system.conf
echo 'DefaultLimitSTACK=16M:infinity' >> /etc/systemd/system.conf

# Raise Number of File Descriptors
# shellcheck disable=SC2129
echo '* soft nofile 65536' >> /etc/security/limits.conf
echo '* hard nofile 65536' >> /etc/security/limits.conf

# Double stack size from default 8192KB
echo '* soft stack 16384' >> /etc/security/limits.conf
echo '* hard stack 16384' >> /etc/security/limits.conf
