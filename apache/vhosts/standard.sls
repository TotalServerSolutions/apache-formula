{% from "apache/map.jinja" import apache with context %}

include:
  - apache

{% for id, site in salt['pillar.get']('apache:sites', {}).items() %}
{% set documentroot = site.get('DocumentRoot', '{0}/{1}'.format(apache.wwwdir, id)) %}

{{ id }}:
  file:
    - managed
    - name: {{ apache.vhostdir }}/{{ id }}{{ apache.confext }}
    - source: {{ site.get('template_file', 'salt://apache/vhosts/standard.tmpl') }}
    - template: {{ site.get('template_engine', 'jinja') }}
    - context:
        id: {{ id|json }}
        site: {{ site|json }}
        map: {{ apache|json }}
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-reload



{% if site.get('CustomLog') != False %}
{% set customlogdir = salt['file.dirname'](site.get('CustomLog')) %}
{{ id }}-customlogdir:
  file.directory:
    - unless: test -d {{ customlogdir }}
    - name: {{ customlogdir }}
    - makedirs: True
    - allow_symlink: True
{% endif %}

{% if site.get('ErrorLog') != False %}
{% set customerrordir = salt['file.dirname'](site.get('ErrorLog')) %}
{{ id }}-customerrordir:
  file.directory:
    - unless: test -d {{ customerrordir }}
    - name: {{ customerrordir }}
    - makedirs: True
    - allow_symlink: True
{% endif %}

{% if site.get('DocumentRoot') != False %}
{{ id }}-documentroot:
  file.directory:
    - unless: test -d {{ documentroot }}
    - name: {{ documentroot }}
    - makedirs: True
    - allow_symlink: True
{% endif %}

{% if site.get('cgiRoot') != False %}
{% set cgidir = site.get('cgiRoot') %}
{{ id }}-cgidir:
  file.directory:
    - unless: test -d {{ cgidir }}
    - name: {{ cgidir }}
    - makedirs: True
    - allow_symlink: True
{% endif %}


{% if grains.os_family == 'Debian' %}
{% if site.get('enabled', True) %}
a2ensite {{ id }}{{ apache.confext }}:
  cmd.run:
    - unless: test -f /etc/apache2/sites-enabled/{{ id }}{{ apache.confext }}
    - require:
      - file: /etc/apache2/sites-available/{{ id }}{{ apache.confext }}
    - watch_in:
      - module: apache-reload
{% else %}
a2dissite {{ id }}{{ apache.confext }}:
  cmd.run:
    - onlyif: test -f /etc/apache2/sites-enabled/{{ id }}{{ apache.confext }}
    - require:
      - file: /etc/apache2/sites-available/{{ id }}{{ apache.confext }}
    - watch_in:
      - module: apache-reload
{% endif %}
{% endif %}

{% endfor %}
