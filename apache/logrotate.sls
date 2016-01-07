/etc/logrotate.d/apache2:
  file:
    - managed
    - contents: |
        /var/log/apache2/*.log {
        	daily
        	missingok
        	rotate 14
        	compress
        	delaycompress
        	notifempty
        	create 640 root adm
        	sharedscripts
        	postrotate
                        if /etc/init.d/apache2 status > /dev/null ; then \
                            /etc/init.d/apache2 reload > /dev/null; \
                        fi;
        	endscript
        	prerotate
        		if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
        			run-parts /etc/logrotate.d/httpd-prerotate; \
        		fi; \
        	endscript
        }
