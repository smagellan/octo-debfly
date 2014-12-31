#! /bin/bash

WF_VERSION="8.2.0"
ln -s wildfly-${WF_VERSION}.Final.tar.gz wildfly_${WF_VERSION}.Final.orig.tar.gz


# unpack and enter directory
tar -xzf wildfly_${WF_VERSION}.Final.orig.tar.gz
cd wildfly-${WF_VERSION}.Final


# Lets start with packaging (create debian/ dir and changelog)
mkdir debian
# 1. debian/changelog
dch --create --package wildfly --newversion="${WF_VERSION}.Final-1"


# 2. debian/compat
echo "9" > debian/compat


# 3. debian/rules
echo -ne '#!/usr/bin/make -f\n%:\n\tdh $@\n' > debian/rules



# 4. debian/control
(cat  <<ENDE
Source: wildfly
Maintainer: Your Name <your.mail@provider.lan>
Standards-Version: 3.9.5
Build-Depends: debhelper (>=9)

Package: wildfly
Architecture: all
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: wildfly application server
 WildFly Application Server (formerly known as JBoss Application Server) is the
 latest release in a series of WildFly offerings. WildFly Application Server, is
 a fast, powerful, implementation of the Java Enterprise Edition 7
 specification.  The state-of-the-art architecture built on the Modular Service
 Container enables services on-demand when your application requires them.
ENDE
)  > debian/control



# 5. debian/source/format
mkdir -p debian/source
echo "3.0 (quilt)" > debian/source/format

mkdir debian/patches;
patch -p0 < ../patchset.patch;


# 6. Add all dir to install
echo "#! /usr/bin/dh-exec

appclient  opt/wildfly/
bin/init.d/wildfly-init-debian.sh => /etc/init.d/wildfly
bin/init.d/wildfly.conf => /etc/default/wildfly
wildfly.service /lib/systemd/system/
bin  opt/wildfly/
docs  opt/wildfly/
domain  opt/wildfly/
modules  opt/wildfly/
standalone  opt/wildfly/
welcome-content  opt/wildfly/
LICENSE.txt  opt/wildfly/
README.txt  opt/wildfly/
copyright.txt  opt/wildfly/
jboss-modules.jar  opt/wildfly/" > debian/wildfly.install

chmod a+x debian/wildfly.install

# Build with dpkg-buildpackage
dpkg-buildpackage -us -uc


