FROM alpine:latest

MAINTAINER Sam Powers <sampowers@gmail.com>

ENV NETATALK_VERSION 3.1.10
ENV BUILDDEPS="curl build-base libtool avahi-dev libgcrypt-dev linux-pam-dev cracklib-dev db-dev libevent-dev krb5-dev tdb-dev file"

RUN mkdir -p /build/netatalk
WORKDIR /build/netatalk/

RUN apk --no-cache add \
$BUILDDEPS \
avahi \
libldap \
libgcrypt \
python \
avahi \
dbus \
dbus-glib \
py-dbus \
linux-pam \
cracklib \
db \
libevent \
krb5 \
tdb

RUN curl -Ls https://github.com/Netatalk/Netatalk/archive/netatalk-3-1-10.tar.gz | tar zx

WORKDIR Netatalk-netatalk-${NETATALK_VERSION}

RUN ./configure \
--prefix=/usr \
--sysconfdir=/etc \
--with-init-style=debian-sysv \
--without-libevent \
--without-tdb \
--with-cracklib \
--enable-krbV-uam \
--with-pam-confdir=/etc/pam.d \
--with-dbus-sysconf-dir=/etc/dbus-1/system.d \
--with-tracker-pkgconfig-version=0.16 \
&& make \
&& make install \
&& mkdir /media/share \
&& apk del --purge $BUILDDEPS

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY afp.conf /etc/afp.conf

EXPOSE 548

CMD ["/docker-entrypoint.sh"]
