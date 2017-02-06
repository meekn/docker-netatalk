#!/bin/bash

if [ -z "${USER}" ]; then
    echo "Set USER environment variable."
    exit 1
fi


if [ ! -z "${USER_UID}" ]; then
    cmd="$cmd --uid ${USER_UID}"
fi
if [ ! -z "${USER_GID}" ]; then
    cmd="$cmd --gid ${USER_GID}"
    groupadd --gid ${USER_GID} ${USER}
fi
adduser $cmd --no-create-home --disabled-password --gecos '' "${USER}"
if [ ! -z "${USER_PASSWORD}" ]; then
    echo "${USER}:${USER_PASSWORD}" | chpasswd
fi

(echo ${USER_PASSWORD}; echo ${USER_PASSWORD}) | smbpasswd -sa ${USER}


if [ ! -d /media/data ]; then
  mkdir /media/data
  echo "use -v /my/dir/to/share:/media/data" > readme.txt
fi
chown "${USER}" /media/data


sed -i'' -e "s,%USER%,${USER:-},g" /etc/afp.conf
sed -i'' -e "s,%USER%,${USER:-},g" /etc/samba/smb.conf

echo ---begin-afp.conf--
cat /etc/afp.conf
echo ---end---afp.conf--

echo ---begin-smb.conf--
cat /etc/samba/smb.conf
echo ---end---smb.conf--

mkdir -p /var/run/dbus
rm -f /var/run/dbus/pid
dbus-daemon --system

cat > /etc/supervisord.conf << EOS
[supervisord]
nodaemon=true
EOS

if [ "${AVAHI}" == "1" ]; then
    sed -i '/rlimit-nproc/d' /etc/avahi/avahi-daemon.conf
    cat >> /etc/supervisord.conf << EOS

[program:avahi-daemon]
command=avahi-daemon
stdout_logfile=NONE
stderr_logfile=NONE
autorestart=true
EOS
else
    echo "Skipping avahi daemon, enable with env variable AVAHI=1"
fi;

cat >> /etc/supervisord.conf << EOS

[program:netatalk]
command=netatalk -d
stdout_logfile=NONE
stderr_logfile=NONE
autorestart=true

[program:nmbd]
command=nmbd -FS
stdout_logfile=NONE
stderr_logfile=NONE
autorestart=true

[program:smbd]
command=smbd -FS --configfile=/etc/samba/smb.conf
stdout_logfile=NONE
stderr_logfile=NONE
autorestart=true
EOS

exec supervisord -c /etc/supervisord.conf
