#!/bin/bash -e
################################################################################
##  File: configure-system.sh
##  Desc: Post deployment system configuration actions for CentOS
################################################################################

# Source helper scripts
# shellcheck disable=SC1091
source "$HELPER_SCRIPTS"/etc-environment.sh
source "$HELPER_SCRIPTS"/os.sh

if [ -d "/opt/post-generation" ]; then
    rm -rf "/opt/post-generation"
fi
mv -f "${IMAGE_FOLDER}/post-generation" /opt

# Adjust permissions
echo "chmod -R 777 /opt"
chmod -R 777 /opt
echo "chmod -R 777 /usr/share"
chmod -R 777 /usr/share

chmod 755 "$IMAGE_FOLDER"

# Remove quotes around PATH in /etc/environment and ensure system directories are present
ENVPATH=$(grep 'PATH=' /etc/environment | head -n 1 | sed -z 's/^PATH=*//')
ENVPATH=${ENVPATH#"\""}
ENVPATH=${ENVPATH%"\""}

# Append standard system directories so that login shells via PAM (e.g. sudo su -c)
# can find basic commands like find, grep, etc.
for dir in /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin; do
    if [[ ":${ENVPATH}:" != *":${dir}:"* ]]; then
        ENVPATH="${ENVPATH}:${dir}"
    fi
done

replace_etc_environment_variable "PATH" "${ENVPATH}"
echo "Updated /etc/environment: $(cat /etc/environment)"

# Clean yarn and npm cache if installed
if command -v yarn > /dev/null; then
    yarn cache clean
fi

if command -v npm > /dev/null; then
    npm cache clean --force
fi
