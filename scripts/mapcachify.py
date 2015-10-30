#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, sys
import xml.etree.ElementTree as ET
from  xml.dom.minidom  import parseString
from mapproxify import *



## Default (do not change)
DEFAULT_WMTS_BASE_URL = 'http://internal-vpc-lb-internal-wmts-infra-1291171036.eu-west-1.elb.amazonaws.com'
DEFAULT_WMS_SOURCE = 'http://wmts10.geo.admin.ch/mapproxy/service'

## Bucket and credentials where tiles are goigin to be stored
## You have to define these 3 VARIABLES....

MAPCACHE_BUCKET_NAME = os.environ.get('MAPCACHE_BUCKET_NAME', None)
MAPCACHE_ACCESS_KEY = os.environ.get('MAPCACHE_ACCESS_KEY', None)
MAPCACHE_SECRET_KEY = os.environ.get('MAPCACHE_SECRET_KEY', None)

## WMS source (Complete URL able to answer a GetCapabilities request)
WMS_SOURCE = os.environ.get('WMS_SOURCE', DEFAULT_WMS_SOURCE)

## Projection to server. The WMS_SOURCE has to provide them
EPSGS = ['4326','21781','2056', '3857']

## Where the new source/tileindex are going to be added in the mappcache.tpl
INDEX = 5

if MAPCACHE_ACCESS_KEY is None or MAPCACHE_SECRET_KEY is None or MAPCACHE_BUCKET_NAME is None:
    print "You must provide S3 credentials"
    sys.exit(3)


def prettify(elem):
    """Return a pretty-printed XML string for the Element.
    """
    rough_string = ET.tostring(elem, 'utf-8')
    reparsed = parseString(rough_string)
    return reparsed.toprettyxml(indent="\t")

http_str='''<http>
            <url>http://wmts10.geo.admin.ch/mapproxy/service</url>
            <headers>
                <User-Agent>mod-mapcache/r175</User-Agent>
                <Referer>http://mapcache.geo.admin.ch</Referer>
            </headers>
        </http>'''



topics = getTopics()

layers_nb, timestamps_nb, layersConfig = getLayersConfigs(topics=topics)


tree = ET.parse('scripts/mapcache.tpl')
root = tree.getroot()

#for el in root.getchildren():
#    print root.getchildren().index(el), el

    

# set secret stuff

s3 = tree.find(".//cache[@name='s3']")

url = s3.find('./url')
url.text = "http://" + MAPCACHE_BUCKET_NAME + ".s3.amazonaws.com/1.0.0/{tileset}/default/{dim}/{grid}/{z}/{x}/{y}.{ext}"
host=s3.find('./headers/Host')
host.text=MAPCACHE_BUCKET_NAME
id = s3.find('./id')
id.text=MAPCACHE_ACCESS_KEY
secret = s3.find('./secret')
secret.text=MAPCACHE_SECRET_KEY
 


def get_tileset(cfg):

    tileset = ET.Element('tileset')
    tileset.set('name', lyr.bodLayerId)
    source = ET.SubElement(tileset, 'source')
    source.text = lyr.bodLayerId
    cache = ET.SubElement(tileset, 'cache')
    cache.text = 's3'
    for epsg in EPSGS:
        grid = ET.SubElement(tileset, 'grid')
        grid.text = str(epsg)
        tileset.append(grid)
    format = ET.SubElement(tileset, 'format')
    format.text = lyr.format.upper() if lyr.format.upper() in ['PNG', 'JPEG'] else 'PNG'
    metatile = ET.SubElement(tileset, 'metatile')
    metatile.text = '5 5'
    dimensions =  ET.SubElement(tileset, 'dimensions')
    dimension =  ET.SubElement(dimensions, 'dimension')
    dimension.set('type', 'values')
    dimension.set('name', 'timestamp')
    default = lyr.timestamps[0]
    dimension.set('default', default)
    dimension.text = ",".join(lyr.timestamps) 

    return tileset
    

for lyr in layersConfig:
    if lyr.bodLayerId == "ch.swisstopo.zeitreihen":
        lyr.format = "png"

    #print lyr.bodLayerId, lyr.timestamps
    
    source = ET.Element('source')
    source.set('name', lyr.bodLayerId)
    source.set('type', 'wms')
    getmap = ET.SubElement(source, 'getmap')
    params = ET.SubElement(getmap,'params')
    format = ET.SubElement(params,'FORMAT')
    format.text = "image/"+ lyr.format
    layers = ET.SubElement(params,'LAYERS')
    layers.text = lyr.bodLayerId
    http = ET.fromstring(http_str)
    url = http.find('./url')
    url.text = WMS_SOURCE

    

    source.append(http)
    

    tileset = get_tileset(lyr)

    root.insert(INDEX, source)
    root.insert(INDEX, tileset)


ET.dump(tree)
