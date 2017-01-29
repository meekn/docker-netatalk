FROM alpine:latest

MAINTAINER Sam Powers <sampowers@gmail.com>

ENV BUILDDEPS="curl build-base automake autoconf libtool avahi-dev libgcrypt-dev linux-pam-dev cracklib-dev db-dev libevent-dev krb5-dev tdb-dev file"
ENV RUNTIMEDEPS="avahi libldap libgcrypt python avahi dbus dbus-glib py-dbus linux-pam cracklib db libevent krb5 tdb"

RUN apk --no-cache add $BUILDDEPS $RUNTIMEDEPS
RUN mkdir -p /build/netatalk \
&& curl -Ls https://github.com/Netatalk/Netatalk/archive/netatalk-3-1-10.tar.gz | tar zx -C /build/netatalk --strip-components=1
RUN cd /build/netatalk \
&& ./bootstrap \
&& ./configure \
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
&& make -j $(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
&& make install \
&& cd / && rm -rf /build \
&& mkdir /media/share \
&& apk del --purge $BUILDDEPS

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY afp.conf /etc/afp.conf

EXPOSE 548

CMD ["/docker-entrypoint.sh"]
