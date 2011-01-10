LIBDIR=$(shell erl -eval 'io:format("~s~n", [code:lib_dir()])' -s init stop -noshell)
PKGNAME=emysql
APP_NAME=emysql

MODULES=$(shell ls -1 src/*.erl | awk -F[/.] '{ print "\t\t" $$2 }' | sed '$$q;s/$$/,/g')
	
all: app
	mkdir -p ebin
	(cd src;$(MAKE))

app: ebin/$(PKGNAME).app

ebin/$(PKGNAME).app: src/$(PKGNAME).app.src
	@sed -e 's/{modules, \[\]}/{modules, [$(MODULES)]}/' < $< > $@

docs:
	erl -noshell -run edoc_run application "'$(APP_NAME)'" '"."' '[{def,{vsn,"$(VSN)"}}]'
	
clean:
	(cd src;$(MAKE) clean)
	(cd t;$(MAKE) clean)
	rm -rf ebin/*.app cover erl_crash.dump

package: clean
	@mkdir emysql-$(VERSION)/ && cp -rf ebin include Makefile README src support t $(PKGNAME)-$(VERSION)
	@COPYFILE_DISABLE=true tar zcf $(PKGNAME)-$(VERSION).tgz $(PKGNAME)-$(VERSION)
	@rm -rf $(PKGNAME)-$(VERSION)/
		
install:
	@for i in ebin/*.beam ebin/*.app include/*.hrl; do install -m 644 -D $$i $(prefix)/$(LIBDIR)/$(PKGNAME)-$(VERSION)/$$i ; done

test: all
	(cd t;$(MAKE))
	prove t/*.t
