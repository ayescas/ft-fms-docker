#!/usr/bin/env bash


printf "\n  --  \e[34mStarting install inside fmsinstall container\e[39m\n"
# settings
build_dir_mount=/root/build/

# cert_prefix=$CERT_PREFIX
c_cert=$CERT_CERT
c_bundle=$CERT_BUNDLE
c_key=$CERT_KEY

assisted_install=$ASSISTED_INSTALL
fms_admin_user=$FMS_ADMIN_USER
fms_admin_pass=$FMS_ADMIN_PASS
package_remove=$PACKAGE_REMOVE

# unset envs
unset CERT_CERT CERT_BUNDLE CERT_KEY ASSISTED_INSTALL FMS_ADMIN_USER FMS_ADMIN_PASS PACKAGE_REMOVE || exit 1

# color prompt global
echo "PS1='\[\033[02;32m\]\u@\H:\[\033[02;34m\]\w\$\[\033[00m\] '" >> /etc/bashrc

# install CentOS SCLo repository for httpd24
yum install centos-release-scl deltarpm -y || exit 1

# update
yum update -y

# pre packages, possibly omit sudo, autofs
# yum install bash-completion firewalld nano policycoreutils net-tools httpd24 httpd24-mod_ssl -y || exit 1
yum install bash-completion firewalld nano policycoreutils net-tools httpd24 httpd24-mod_ssl -y || { printf "error while installing pre-packages"; exit 1; }

# download filemaker_server package
package=$(find "$build_dir_mount" -name "*.rpm")
if [[ ! $package ]]; then
    printf "no rpm package found"
    exit 1
fi

# preload dependencies
yum install --downloadonly --downloaddir=/root/deps "${package}" -y || { printf "error while preloading yum packages"; exit 1; }

# preinstall dependencies
yum install root/deps/* -y

# install filemaker_server
FM_ASSISTED_INSTALL="${build_dir_mount}""${assisted_install}" yum install "${package}" -y || { echo "error while installing filemaker server"; exit 1; }

# check
systemctl --no-pager || { printf "error while systemctl"; exit 1; }

# import cert
if [[ $c_cert ]] && [[ $c_bundle ]] && [[ $c_key ]]; then
    printf "\nimport certificate\n"
    fmsadmin certificate import -yu "${fms_admin_user}" -p "${fms_admin_pass}" --keyfile ${build_dir_mount}"${c_key}" --intermediateCA ${build_dir_mount}"${c_bundle}" ${build_dir_mount}"${c_cert}" || { printf "error while installing certificates"; exit 1; }
fi

# default fms config
printf "\n  --  \e[34mdefault fmsadmin settings... \e[39m\n"
fmsadmin -u "$fms_admin_user" -p "$fms_admin_pass" set serverconfig SecureFilesOnly=false || { printf "error while fmsadmin securefilesonly"; exit 1; }
fmsadmin -u "$fms_admin_user" -p "$fms_admin_pass" -y disable schedule 1 || { printf "error while fmsadmin disable schedule"; exit 1; }

# change systemd unit stop timeout
sed -i 's/TimeoutStopSec=2m/TimeoutStopSec=20m/g' /etc/systemd/system/fmshelper.service || { printf "error while changing systemd unit"; exit 1; }

# remove install packages
printf "\nremove install packages\n"
rm -r /root/deps/
if [[ $package_remove -eq 1 ]]; then
    printf "\nremove fms package\n"
    rm -r "${package}" || { exit 1; }
fi

echo "" > ${build_dir_mount}build_success

printf "\n  --  \e[34mFinished install inside fmsinstall container, returning...\e[39m\n"

# exit
exit 0
