FROM alpine:latest

MAINTAINER Kouta Asai alice02

ENV NETATALK_VERSION 3.1.10
ENV DEPS="build-base libtool avahi-dev libgcrypt-dev linux-pam-dev cracklib-dev db-dev libevent-dev krb5-dev tdb-dev file"

RUN mkdir -p /build/netatalk
WORKDIR /build/netatalk/

RUN apk --no-cache add \
    		   $DEPS \
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
		   tdb \
		   && wget http://downloads.sourceforge.net/project/netatalk/netatalk/${NETATALK_VERSION}/netatalk-${NETATALK_VERSION}.tar.bz2 -q -O - | tar jx

WORKDIR netatalk-${NETATALK_VERSION}

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
	&&  mkdir /media/share

RUN apk del --purge $DEPS

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY afp.conf /etc/afp.conf

EXPOSE 548

CMD ["/docker-entrypoint.sh"]
