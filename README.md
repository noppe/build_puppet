# Package Puppet for various OS's.

Guide to building Puppet agents.

# About


Since any reasonable modern OS have puppet in the standard repositories, why do we build the puppet software ourselves?

There are several reasons for this:

- Ruby depends on dynamically loaded libraries, for example zlib and openssl. By including these into the EIS puppet package we eliminate the risk of an OS patch to break puppet

- Some OSes in EIS scope does not provide puppet at all, or an older version. We can build EIS puppet for these

- We get the same version of puppet on all EIS managed servers, implying that we can use the same puppet language features for all clients

- The EIS puppet package installs in /opt/puppet, thus it is possible to have the OS puppet package installed simultaneously

- A tailor-made package fits our requirements better

# Supported Distributions

    * Solaris 11.1 sparc
    * Solaris 11.1 x86
    * Solaris 10 sparc
    * Solaris 10 x86
    * Solaris 9 sparc
    * Openindiana 5.11 oi_151a7 x86
    * Ubuntu 12.04 LTS
    * RedHat 5-series and correspondin CentOS, x86
    * RedHat 6-series and correspondin CentOS, x86
    * SuSE 10
    * SuSE 11

# Prerequisites

The following components are used.

## Sources

    facter-1.7.1
    hiera-1.2.1
    puppet-3.2.2
    ruby-1.8.7-p358
    ruby-shadow-2.1.4
    augeas-1.1.0
    ruby-augeas-0.5.0
    readline-6.2
    openssl-0.9.8w
    zlib-1.2.8

## Tools
    C compiler, usually gcc
    make and gmake
    perl
    fpm
    rpmbuild

### Solaris 10 x86:
    /usr/sfw/bin/gcc 3.4.3, patched with http://www.openssl.org/~appro/values.c to get usable openssl libs

### Solaris 10 sparc:
    /usr/sfw/bin/gcc 3.4.3

# Build Instructions
***Add here!***

## Notes on building components

### Augeas

Add <pre>"-lncurses"</pre> to CFLAGS in configure statement. Otherwise build will fail with "Could not find a working readline library"

### RedHat

       Install "libxml2" on Redhat flavors.

