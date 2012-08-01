#!/usr/bin/make

################# CONFIG ##########################

#fix
ETC			=	$(DESTDIR)/etc
INIT			=	$(DESTDIR)/etc/init.d
LIB			=	$(DESTDIR)/var/lib

#variable
BIN			=	$(DESTDIR)/usr/sbin
DOC			=	$(DESTDIR)/usr/share/doc

##################################################

install:
	# directories
	install -d $(INIT) $(ETC)/firewall-jay $(DOC)/firewall-jay/ $(LIB)/firewall-jay

	# config
	rm -f /usr/local/sbin/firewall-config.pl > /dev/null 2>&1
	install -m 700 -o root -g root files/firewall-config.pl $(BIN)/	
	if [ ! -e $(ETC)/firewall-jay/firewall-spy-update.config ];then \
		install -m 600 -o root -g root files/firewall-spy-update.config $(ETC)/firewall-jay/; \
	fi

	# doc
	install -m 444 INSTALL README README.Spywares README.Peers CHANGELOG COPYING $(DOC)/firewall-jay/

	# rules	& spyware list
	install -m 700 -o root -g root files/firewall.rules $(LIB)/firewall-jay/
	install -m 700 -o root -g root files/firewall-spy-update.pl $(BIN)/
	
	# old spywares files (filenames changed)
	rm -f $(LIB)/firewall-jay/block-ip.all $(LIB)/firewall-jay/block-ip.lite $(LIB)/firewall-jay/block-ip.microsoft $(LIB)/firewall-jay/block-ip.doubleclick

	rm -f $(LIB)/firewall-jay/block-ip-out.spywares-lite $(LIB)/firewall-jay/block-ip-out.microsoft $(LIB)/firewall-jay/block-ip-out.doubleclick
	# custom denied mac in
	if [ ! -e $(LIB)/firewall-jay/block-mac-in.user ]; then \
		install -m 640 -o root -g root files/block-mac-in.user $(LIB)/firewall-jay/; \
	fi


	# custom denied ip in
	if [ ! -e $(LIB)/firewall-jay/block-ip-in.user ]; then \
		install -m 640 -o root -g root files/block-ip-in.user $(LIB)/firewall-jay/; \
	fi

	# custom denied ip out
	if [ ! -e $(LIB)/firewall-jay/block-ip-out.user ]; then \
                install -m 640 -o root -g root files/block-ip-out.user $(LIB)/firewall-jay/; \
        fi

	# custom rules
	if [ ! -e $(LIB)/firewall-jay/firewall-custom.rules ]; then \
		install -m 700 -o root -g root files/firewall-custom.rules $(LIB)/firewall-jay/; \
	else \
		chmod 700 $(LIB)/firewall-jay/firewall-custom.rules; \
	fi

	# fw-jay script
	install -m 700 -o root -g root files/fw-jay $(INIT)/
	
	# remove old firewall script
	if [ -e $(INIT)/firewall ];then \
	if ( cat $(INIT)/firewall | grep 'by Jay' > /dev/null 2>&1 ) ;then \
		rm -f $(INIT)/firewall; \
	fi \
	fi
	
	##########################################################################
	#                                                                        #
	#   Jay's Iptables Firewall has heen successfully installed.             #
	#                                                                        #
	#   See 'firewall-config.pl --help' and create the configuration file.   #
	#                                                                        #
	#   UPGRADE : run 'firewall-config.pl --update'                          #
	#                                                                        #
	##########################################################################


remove:
	# rm -rf $(ETC)/firewall-jay
	rm -rf $(DOC)/firewall-jay
	rm -rf $(LIB)/firewall-jay
	rm -f $(INIT)/fw-jay
	rm -f $(BIN)/firewall-config.pl
	rm -f $(BIN)/firewall-spy-update.pl

	###########################################################################
	#                                                                         #
	#      Jay's Iptables Firewall has heen successfully removed              #
	#                                                                         #
	###########################################################################

