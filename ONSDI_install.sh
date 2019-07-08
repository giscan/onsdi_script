#!/bin/bash
DOMAIN_name = 
echo "Install prerequisite"
apt install docker docker-compose python-django 
echo "Cloning GeoNode Project"
git clone git://github.com/GeoNode/geonode-project.git
echo "Create Custom Project"
django-admin startproject --template=./geonode-project -e py,rst,json,yml,ini,env,sample -n Dockerfile onsdi
cd onsdi
echo " Modify domain name in docker-compose.override"
sed -i -e 's/localhost/$DOMAINE_name/g' docker-compose.override.yml
echo "Create custom local settings"
touch onsdi/local_settings.py
echo '' >> 
echo "Configuring Mosaic and CSW Catalog"
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
' >> onsdi/local_settings.py

echo "Add beta banner"
echo 'body:after{
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
}' >> onsdi/static/css/site_base.css

echo "Custom logo copy"
cp -rf logo_onsdi.png onsdi/static/img/
echo "Custom logo configuration"


echo "Installation"
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d --build

