# service-mapcache


MapCache configuration and service for 'geo.admin.ch'!


## Getting started

Checkout the source code:

    git clone https://github.com/procrastinatio/service-mapcache.git

or when you're using ssh key (see https://help.github.com/articles/generating-ssh-keys):

    git clone git@github.com:procrastinatio/service-mapcache.git

## Build:

    $ make all

    Use `make help` to know about the possible `make` targets and the currently set variables:

    $ make help


## Using S3 cache:

    You have to define the following environmental variable to configure mapcache:

    * MAPCACHE_ACCESS_KEY
    * MAPCACHE_SECRET_KEY
    * MAPCACHE_BUCKET_NAME

    And optionaly, the source for the native WMTS tiles (default using the internal ELB bucket)

    * WMTS_BASE_URL

    Then generate the `mapcache.xml` with:

    $ make config


## Testing:

   The WMTS GetCapabilities is accessible through:

    http://<myhost>/wmts/1.0.0/WMTSCapabilities.xml  or

    http://<myhost>/wmts?service=wmts&request=getcapabilities&version=1.0.0

    A small internal demo is usually available at:

    http://<myhost>/demo/

    but it crashes due to insance number of layers, projections and timestamps configured.

