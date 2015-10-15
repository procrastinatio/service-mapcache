<?xml version="1.0" encoding="UTF-8"?>
<!-- see the accompanying mapcache.xml.sample for a fully commented configuration file -->
<mapcache>
    <cache name="disk" type="disk" layout="template">
        <symlink_blank/>
        <template>/var/www/vhosts/default/htdocs/data/1.0.0/{tileset}/default/current/{grid}/{z}/{x}/{y}.{ext}</template>
    </cache>
    <cache name="s3" type="s3">
        <url>http://abcd-tiles-cache.s3.amazonaws.com/1.0.0/{tileset}/default/{dim}/{grid}/{z}/{x}/{y}.{ext}</url>
        <detect_blank/>
        <headers>
            <Host>abcd-tiles-cache.s3.amazonaws.com</Host>
        </headers>
         <id>******************</id>
        <secret>****************************************</secret>  
        <region>eu-west-1</region>
        <operation type="put">
            <headers>
                <x-amz-storage-class>REDUCED_REDUNDANCY</x-amz-storage-class>
                <x-amz-acl>public-read</x-amz-acl>
            </headers>
        </operation>
    </cache>
    <grid name="21781">
        <metadata>
            <title>geo.admin.ch grid LV03</title>
        </metadata>
        <extent>420000 30000 900000 350000</extent>
        <srs>EPSG:21781</srs>
        <resolutions>4000 3750 3500 3250 3000 2750 2500 2250 2000 1750 1500 1250 1000 750 650 500 250 100 50 20 10 5 2.5 2 1.5 1 0.5 0.25</resolutions>
        <units>m</units>
        <size>256 256</size>
    </grid>
    <grid name="2056">
        <metadata>
            <title>geo.admin.ch grid LV95</title>
        </metadata>
        <extent>2420000.0 1030000.0 2900000.0 1350000.0</extent>
        <srs>EPSG:2056</srs>
        <resolutions>4000 3750 3500 3250 3000 2750 2500 2250 2000 1750 1500 1250 1000 750 650 500 250 100 50 20 10 5 2.5 2 1.5 1 0.5 0.25</resolutions>
        <units>m</units>
        <size>256 256</size>
    </grid>
    <grid name="3857">
        <metadata>
          <title>GoogleMapsCompatible</title>
          <WellKnownScaleSet>urn:ogc:def:wkss:OGC:1.0:GoogleMapsCompatible</WellKnownScaleSet>
       </metadata>
       <extent>-20037508.3427892480 -20037508.3427892480 20037508.3427892480 20037508.3427892480</extent>
       <srs>EPSG:3857</srs>
       <srsalias>EPSG:900913</srsalias>
       <units>m</units>
       <size>256 256</size>
       <resolutions>156543.0339280410 78271.51696402048 39135.75848201023 19567.87924100512 9783.939620502561 4891.969810251280 2445.984905125640 1222.992452562820 611.4962262814100 305.7481131407048 152.8740565703525 76.43702828517624 38.21851414258813 19.10925707129406 9.554628535647032 4.777314267823516 2.388657133911758 1.194328566955879 0.5971642834779395 0.29858214173896974 0.14929107086948487 0.07464553543474244 0.03732276771737122</resolutions>
    </grid>
    <grid name="4326">
        <metadata>
            <title>GoogleCRS84Quad</title>
        </metadata>
        <extent>-180 -90 180 90</extent>
        <srs>EPSG:4326</srs>
        <units>dd</units>
        <size>256 256</size>
        <resolutions>0.703125000000000 0.351562500000000 0.175781250000000 8.78906250000000e-2 4.39453125000000e-2 2.19726562500000e-2 1.09863281250000e-2 5.49316406250000e-3 2.74658203125000e-3 1.37329101562500e-3 6.86645507812500e-4 3.43322753906250e-4 1.71661376953125e-4 8.58306884765625e-5 4.29153442382812e-5 2.14576721191406e-5 1.07288360595703e-5 5.36441802978516e-6</resolutions>
    </grid>

    <default_format>JPEG</default_format>
    <format name="png8" type="PNG">
       <compression>fast</compression>
       <colors>256</colors>
    </format>
   <format name="pngjpeg" type="MIXED">
       <opaque>JPEG</opaque>
       <transparent>PNG</transparent>
   </format>

    <service type="wms" enabled="true">
        <full_wms>assemble</full_wms>
        <resample_mode>bilinear</resample_mode>
        <format>JPEG</format>
        <maxsize>4096</maxsize>
    </service>
    <service type="wmts" enabled="true"/>
    <service type="tms" enabled="true"/>
    <service type="kml" enabled="true"/>
    <service type="gmaps" enabled="true"/>
    <service type="ve" enabled="true"/>
    <service type="mapguide" enabled="true"/>
    <service type="demo" enabled="true"/>
    <errors>report</errors>
    <lock_dir>/tmp</lock_dir>
</mapcache>
