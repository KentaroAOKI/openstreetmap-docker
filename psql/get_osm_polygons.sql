COPY (
select
"osm_id",
"access",
"addr:housename",
"addr:housenumber",
"admin_level",
"aerialway",
"aeroway",
"amenity",
"barrier",
"boundary",
"building",
"highway",
"historic",
"junction",
"landuse",
"layer",
"leisure",
"lock",
"man_made",
"military",
"name",
"natural",
"oneway",
"place",
"power",
"railway",
"ref",
"religion",
"shop",
"tourism",
"water",
"waterway",
"tags",
ST_Astext(ST_Transform(way,4326))
from planet_osm_point
)
TO '/tmp/osm_points.csv' with CSV DELIMITER ',';
