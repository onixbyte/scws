# Automake file on top directory
# $Id$

AUTOMAKE_OPTIONS = 1.5 subdir-objects

SUBDIRS = . libscws cli etc

DIST_SUBDIRS = libscws cli etc

EXTRA_DIST = API.md win32

UNISON_OPT = -auto -batch -prefer newer -terse -times -logfile /dev/null
	
dict:
	cd etc && make dict

dist-dict:
	cd etc && make dist-dict

