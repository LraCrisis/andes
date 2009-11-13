#
#    Create system-wide lisp libraries.
#
#  The following are instructions for creating the various libraries
#  by hand and packaging them up into sbcl-site-libraries.tgz
#  Normally, users will just want to invoke "install-site-libraries"

#  ;; Install the hunchentoot web server http://www.weitz.de/hunchentoot/
#  ;; using asdf-install.  asdf-install broken in that it will try to load
#  ;; packages we said we didn't need, like cl+ssl and its dependent cffi.
#  ;; Start sbcl by typing "sbcl" and run:
#     (require 'asdf-install)
#     (push :hunchentoot-no-ssl *features*) ;we have apache to do this
#     (asdf-install:install 'hunchentoot) ;here it will say package not trusted multiple times
#     (asdf-install:install 'cl-json)
#     (quit)  ; exit the lisp server

#  clsql can be obtained from http://clsql.b9.com
#  However, it does not work well with asdf-install and cffi.
#  So we include a local copy which we patch and install in the system-wide
#  sbcl libraries.
#
clsql-v = 4.0.5
install-clsql:
	tar zxf clsql-$(clsql-v).tar.gz
	patch -p0 < clsql-$(clsql-v).patch
	mv clsql-$(clsql-v) /usr/local/lib/sbcl/site
	cd /usr/local/lib/sbcl/site-systems; ln -s ../site/clsql-$(clsql-v)/*.asd .

#  Also, need to fix error handling in usocket and hunchentoot:
#  apply as patches (See Bug #1614):
#    r4323 from svn co svn://bknr.net/svn/trunk/thirdparty/hunchentoot
#    r497 from  svn co svn://common-lisp.net/project/usocket/svn/usocket/trunk usocket-svn
#

create-site-libraries:
	chmod -R go+r /usr/local/lib/sbcl/site/md5*
	-cd /usr/local/lib/sbcl/site; rm */*.fasl; rm */*/*.fasl
	tar zcf sbcl-site-libraries.tgz --directory=/usr/local/lib/sbcl/ site site-systems

#
#  Install sbcl site libraries from copy in git.
#
install-site-libraries:
	@echo "This must be run as \"su root\""
	tar zxf sbcl-site-libraries.tgz -C /usr/local/lib/sbcl
	chown -R $(USER) /usr/local/lib/sbcl

install-database:
	@echo "This will destroy any existing database!"
	@echo "Enter mysql password"
	cd LogProcessing/databaseCreationScripts; mysql -u root -p < AndesDatabaseCreationSQL.sql

install-dojo:
	cd web-UI; $(MAKE) install

install-solver:
	cd Algebra/src; $(MAKE) executable

ifeq ($(shell uname),Darwin)
  httpd-document-root = /Library/webServer/Documents
  httpd-conf-dir = /etc/httpd/users
else ifeq ($(shell uname),Linux)
  httpd-document-root = /var/www/html
  httpd-conf-dir = $(if $(shell test -e /etc/apache2 && echo "1"),\
                   /etc/apache2,/etc/httpd)/conf.d
endif

configure-httpd:
	@echo "This must be run as root"
	cp andes-server.conf $(httpd-conf-dir)
	ln -s `pwd`/web-UI $(httpd-document-root)
	ln -s `pwd`/review $(httpd-document-root)
	ln -s `pwd`/images $(httpd-document-root)

update:
	git pull
	cd problems; git pull
	cd solutions; git pull
	cd Algebra/src; $(MAKE) executable
	cd web-UI; $(MAKE) update

