## Site-dependent definitions included in Makefiles
## Also verify the values in external_functions/ef_utility/site_specific.mk

## Full path name of the directory containing this file (the ferret root directory).
## Do not use $(shell pwd) since this is included in Makefiles in other directories.
DIR_PREFIX = $(HOME)/build/pyferret_dev
# DIR_PREFIX = $(HOME)/pyferret_dev

## Machine type for which to build Ferret/PyFerret
##   x86_64-linux      for 64-bit RHEL
##   x86_64-linux-gnu  for 64-bit Ubuntu and many "free" Linux systems
##   i386-linux        for 32-bit RHEL
##   i386-linux-gnu    for 32-bit Ubuntu and many "free" Linux systems
##   i386-apple-darwin for MacOS
BUILDTYPE = $(HOSTTYPE)
# BUILDTYPE = x86_64-linux
# BUILDTYPE = x86_64-linux-gnu
# BUILDTYPE = i386-linux
# BUILDTYPE = i386-linux-gnu
# BUILDTYPE = i386-apple-darwin
# BUILDTYPE = intel-mac

## Python 2.x executable to invoke for build and install.
PYTHON_EXE = python2.6
# PYTHON_EXE = python2.7
## The assignment of PYTHONINCDIR should not need any modifications
PYTHONINCDIR := $(shell $(PYTHON_EXE) -c "import distutils.sysconfig; print distutils.sysconfig.get_python_inc()")

## Installation directory for built Ferret.  Using the "install"
## Makefile target circumvents the need to create the fer_*.tar.gz
## files just for creating a Ferret installation.
INSTALL_FER_DIR = $(HOME)/ferret_distributions/rhel6_64
# INSTALL_FER_DIR = $(FER_DIR)

## Installation directory for cairo v1.12 or later static library 
## (contains include and lib or lib64 subdirectories).  If blank,
## the system's cairo shared library will be used.  Older versions 
## of cairo (v1.8 or later) can be used, but raster images from 
## -nodisplay may look a little fuzzy unless -gif is specified.
CAIRO_DIR = /usr/local/cairo-1.14.4
# CAIRO_DIR =

## Installation directory for pixman-1 static library (contains 
## include and lib or lib64 subdirectories) used by the above cairo 
## library.  If blank, or if CAIRO_DIR is blank, the system's 
## pixman-1 shared library will be used.
PIXMAN_DIR = /usr/local/cairo-1.14.4
# PIXMAN_DIR =

## Installation directory for HDF5 static libraries (contains 
## include and lib or lib64 subdirectories).  Do not give a location 
## to link to NetCDF shared-object libraries.
# HDF5_DIR = /usr
# HDF5_DIR = /usr/local
HDF5_DIR = /usr/local/hdf5-1.8.16
# HDF5_DIR = 

## Installation directory for NetCDF static or shared object libraries
## (contains include and lib or lib64 subdirectories).  If HDF5_DIR 
## (above) is blank, the netcdf shared-object (.so) libraries will be 
## used;  otherwise the netcdf static (.a) libraries will be used.
# NETCDF4_DIR = /usr
# NETCDF4_DIR = /usr/local
NETCDF4_DIR = /usr/local/netcdf-4.4.0

## Java home directory - this may be predefined
## from your shell environment.  If JAVA_HOME is defined,
## $(JAVA_HOME)/bin/javac and $(JAVA_HOME)/bin/jar is
## called to build threddsBrowser.jar; otherwise, it just
## uses javac and jar (from the path).
# JAVA_HOME = /usr/java/default
# JAVA_HOME = /usr/java/latest
# JAVA_HOME = /usr/lib/jvm/default-java
# JAVA_HOME = /usr/lib/jvm/java-oracle
# JAVA_HOME = /usr/lib/jvm/java-sun
JAVA_HOME = /usr/lib/jvm/java
# JAVA_HOME = /Library/Java/JavaVirtualMachines/jdk1.7.jdk/Contents/Home

# PyFerret version number - do not change this
PYFERRET_VERSION = 1.3

##
