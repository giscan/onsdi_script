#!/bin/bash
DOMAIN_name=geoportal.govmu.org
echo "Install prerequisite"
apt install -y docker docker-compose python-django 
echo "Cloning GeoNode Project"
git clone git://github.com/GeoNode/geonode-project.git
echo "Create Custom Project"
django-admin2 startproject --template=./geonode-project -e py,rst,json,yml,ini,env,sample -n Dockerfile onsdi
echo " Modify domain name in docker-compose.override"
sed -i -e "s/localhost/$DOMAINE_name/g" docker-compose.override.yml
echo "Create custom local settings"
touch onsdi/onsdi/local_settings.py
echo '# -*- coding: utf-8 -*-
#########################################################################
#
# Copyright (C) 2018 OSGeo
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#########################################################################

""" There are 3 ways to override GeoNode settings:
   1. Using environment variables, if your changes to GeoNode are minimal.
   2. Creating a downstream project, if you are doing a lot of customization.
   3. Override settings in a local_settings.py file, legacy.
"""

import ast
import os
from urlparse import urlparse, urlunparse
from geonode.settings import *

PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))

MEDIA_ROOT = os.getenv('MEDIA_ROOT', os.path.join(PROJECT_ROOT, "uploaded"))

STATIC_ROOT = os.getenv('STATIC_ROOT',
                        os.path.join(PROJECT_ROOT, "static_root")
                        )

SECRET_KEY = os.getenv('SECRET_KEY', "0lup9#8(kxs*7t%-a8x6giscan$0&u966+1qs2$3f#qdm2p@21m")


# If you want to enable Mosaics use the following configuration
UPLOADER = {
    # 'BACKEND': 'geonode.rest',
    'BACKEND': 'geonode.importer',
    'OPTIONS': {
        'TIME_ENABLED': True,
        'MOSAIC_ENABLED': True,
    },
    'SUPPORTED_CRS': [
        'EPSG:4326',
        'EPSG:3785',
        'EPSG:3857',
        'EPSG:32647',
        'EPSG:32736',
        'EPSG:32740'
    ],
    'SUPPORTED_EXT': [
        '.shp',
        '.csv',
        '.kml',
        '.kmz',
        '.json',
        '.geojson',
        '.tif',
        '.tiff',
        '.geotiff',
        '.gml',
        '.xml'
    ]
}

# pycsw settings
PYCSW = {
    # pycsw configuration
    'CONFIGURATION': {
        # uncomment / adjust to override server config system defaults
        # 'server': {
        #    'maxrecords': '10',
        #    'pretty_print': 'true',
        #    'federatedcatalogues': 'http://catalog.data.gov/csw'
        # },
        'server': {
            'home': '.',
            'url': CATALOGUE['default']['URL'],
            'encoding': 'UTF-8',
            'language': LANGUAGE_CODE,
            'maxrecords': '20',
            'pretty_print': 'true',
            # 'domainquerytype': 'range',
            'domaincounts': 'true',
            'profiles': 'apiso,ebrim',
        },
        'manager': {
            # authentication/authorization is handled by Django
            'transactions': 'false',
            'allowed_ips': '*',
            # 'csw_harvest_pagesize': '10',
        },
        'metadata:main': {
            'identification_title': 'Mauritius ONSDI Catalog',
            'identification_abstract': 'ONSDI is an open source platform' \
            ' that facilitates the creation, sharing, and collaborative use' \
            ' of geospatial data',
            'identification_keywords': 'sdi, catalogue, discovery, metadata,' \
            ' Mauritius', 'spatial data',
            'identification_keywords_type': 'theme',
            'identification_fees': 'None',
            'identification_accessconstraints': 'None',
            'provider_name': 'National Computer Board',
            'provider_url': SITEURL,
            'contact_name': 'Lastname, Firstname',
            'contact_position': 'Position Title',
            'contact_address': '7th Floor, Stratton Court La Poudriere Street',
            'contact_city': 'Port Louis',
            'contact_stateorprovince': 'Port Louis',
            'contact_postalcode': 'Zip or Postal Code',
            'contact_country': 'Country',
            'contact_phone': '+230 - 210 55 20',
            'contact_fax': '+230 - 212 42 40',
            'contact_email': 'opendata@govmu.org',
            'contact_url': 'http://www.ncb.mu',
            'contact_hours': '9:00 - 16:00',
            'contact_instructions': 'During hours of service. Off on ' \
            'weekends.',
            'contact_role': 'pointOfContact',
        },
        'metadata:inspire': {
            'enabled': 'true',
            'languages_supported': 'eng,fre',
            'default_language': 'eng',
            'date': '2019-07-01',
            'gemet_keywords': 'Utility and governmental services',
            'conformity_service': 'notEvaluated',
            'contact_name': 'National Computer Board',
            'contact_email': 'opendata@govmu.org',
            'temp_extent': 'YYYY-MM-DD/YYYY-MM-DD',
        }
    }
}
' >> onsdi/onsdi/local_settings.py

echo "Add beta banner"
echo ".navbar-brand {

    background: url("../img/logo_onsdi.png");
    background-repeat: no-repeat;
    background-position: center;
    background-size: contain;
    text-indent: -9999px;
    height: 65px;
    width: 200px;

}


body:after{
  content: "beta";
  position: fixed;
  width: 80px;
  height: 25px;
  background: #EE8E4A;
  top: 7px;
  left: -20px;
  text-align: center;
  font-size: 13px;
  font-family: sans-serif;
  text-transform: uppercase;
  fontweight: bold;
  color: #fff;
  line-height: 27px;
  -ms-transform:rotate(-45deg);
  -webkit-transform:rotate(-45deg);
  transform:rotate(-45deg);
}" >> onsdi/onsdi/static/css/site_base.css

echo "Custom logo copy"
cp -rf logo_onsdi.png onsdi/onsdi/static/img/
echo "Custom logo configuration"
rm onsdi/onsdi/templates/site_index.html
touch onsdi/onsdi/templates/site_index.html
echo '{% extends 'index.html' %}
{% load i18n %}
{% comment %}
This is where you can override the hero area block. You can simply modify the content below or replace it wholesale to meet your own needs.
{% endcomment %}
{% block hero %}
<div class="jumbotron">
  <div class="container">
      <h1>{{custom_theme.jumbotron_welcome_title|default:_("ONSDI")}}</h1>
      <p></p>
      <p>{{custom_theme.jumbotron_welcome_content|default:_("Mauritius Open Source National Spatial Data Infrastructures")}}</p>
	{% comment %}
      {% if not custom_theme.jumbotron_cta_hide %}
      <p><a class="btn btn-default btn-lg" target="_blank" href="{{custom_theme.jumbotron_cta_link|default:_("http://docs.geonode.org/en/master/usage/")}}" role="button">{{custom_theme.jumbotron_cta_text|default:_("Get Started &raquo;")}}</a></p>
      {% endif %}
	{% endcomment %}
  </div>
</div>
{% endblock hero %}

      {% block bigsearch %}
      
{% endblock bigsearch %}' >> onsdi/onsdi/templates/site_index.html

echo "uswgi configuration"
rm onsdi/uwsgi.ini
touch onsdi/uwsgi.ini
echo "[uwsgi]
socket = 0.0.0.0:8000
# http-socket = 0.0.0.0:8000
logto = /var/log/geonode.log
pidfile = /tmp/geonode.pid

chdir = /usr/src/onsdi/
module = onsdi.wsgi:application

processes = 8
threads = 8
enable-threads = true
master = true

buffer-size = 32768
max-requests = 500
harakiri = 300 # respawn processes taking more than 5 minutes (300 seconds)
max-requests = 500 # respawn processes after serving 5000 requests
# limit-as = 1024 # avoid Errno 12 cannot allocate memory
harakiri-verbose = true
cron = * * * * * /usr/local/bin/python /usr/src/onsdi/manage.py collect_metrics -n
vacuum = true
thunder-lock = true" >> onsdi/uwsgi.ini

echo "configure .env"
rm .env && touch .env
echo "COMPOSE_PROJECT_NAME=onsdi" >> onsdi/.env

echo "configure geoserver"
rm onsdi/scripts/docker/env/production/geoserver.env && touch onsdi/scripts/docker/env/production/geoserver.env
echo "DOCKERHOST
DOCKER_HOST_IP
GEONODE_LB_HOST_IP
GEONODE_LB_PORT
PUBLIC_PORT=80
NGINX_BASE_URL
GEOSERVER_JAVA_OPTS=-Djava.awt.headless=true -XX:MaxPermSize=1024m -XX:PermSize=512m -Xms1024m -Xmx4096m -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:ParallelGCThreads=8 -Dfile.encoding=UTF8 -Duser.timezone=GMT -Djavax.servlet.request.encoding=UTF-8 -Djavax.servlet.response.encoding=UTF-8 -Duser.timezone=GMT -Dorg.geotools.shapefile.datetime=true" >> onsdi/scripts/docker/env/production/geoserver.env

echo "configure docker-compose"
rm onsdi/docker-compose.yml && touch onsdi/docker-compose.yml
echo 'version: "2.2"
services:

  db:
    image: geonode/postgis:10
    restart: unless-stopped
    container_name: db4${COMPOSE_PROJECT_NAME}
    stdin_open: true
    # tty: true
    labels:
        org.geonode.component: db
        org.geonode.instance.name: geonode
    volumes:
      - ./dbdata:/var/lib/postgresql/data
      - ./dbbackups:/pg_backups
    env_file:
      - ./scripts/docker/env/production/db.env

  geoserver:
    image: geonode/geoserver:2.14.x
    restart: unless-stopped
    container_name: geoserver4${COMPOSE_PROJECT_NAME}
    stdin_open: true
    # tty: true
    labels:
        org.geonode.component: geoserver
        org.geonode.instance.name: geonode
    depends_on:
      - db
      - data-dir-conf
    volumes:
      - ./geoserver-data-dir:/geoserver_data/data
    env_file:
      - ./scripts/docker/env/production/geoserver.env

  django:
    restart: unless-stopped
    build: .
    container_name: django4${COMPOSE_PROJECT_NAME}
    stdin_open: true
    # tty: true
    labels:
      org.geonode.component: django
      org.geonode.instance.name: geonode
    depends_on:
      - db
      - data-dir-conf
    # command: paver start_django -b 0.0.0.0:8000
    # command: uwsgi --ini uwsgi.ini
    volumes:
      - ./statics:/mnt/volumes/statics
      - ./geoserver-data-dir:/geoserver_data/data
      - ./geocollections:/usr/src/onsdi/geocollections 
    env_file:
      - ./scripts/docker/env/production/django.env

  geonode:
    image: geonode/nginx:geoserver
    restart: unless-stopped
    container_name: nginx4${COMPOSE_PROJECT_NAME}
    stdin_open: true
    # tty: true
    labels:
        org.geonode.component: nginx
        org.geonode.instance.name: geonode
    depends_on:
      - django
      - geoserver
    ports:
      - "80:80"
    volumes:
      - ./statics:/mnt/volumes/statics

  data-dir-conf:
    image: geonode/geoserver_data:2.14.x
    restart: on-failure
    container_name: gsconf4${COMPOSE_PROJECT_NAME}
    labels:
        org.geonode.component: conf
        org.geonode.instance.name: geonode
    command: /bin/true
    volumes:
      - ./geoserver-data-dir:/geoserver_data/data

volumes:
  statics:
    name: ${COMPOSE_PROJECT_NAME}-statics
  geoserver-data-dir:
    name: ${COMPOSE_PROJECT_NAME}-gsdatadir
  dbdata:
    name: ${COMPOSE_PROJECT_NAME}-dbdata
  dbbackups:
    name: ${COMPOSE_PROJECT_NAME}-dbbackups
  rabbitmq:
    name: ${COMPOSE_PROJECT_NAME}-rabbitmq' >> onsdi/docker-compose.yml


echo "Installation"
cd onsdi && docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d --build
