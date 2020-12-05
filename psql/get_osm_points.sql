COPY (
select
"osm_id",
"name",
"natural",
"religion",
"shop",
"tourism",
"water",
"waterway",
ST_Astext(ST_Simplify(way,10))
from planet_osm_polygon
)
TO '/tmp/osm_polygons.csv' with CSV DELIMITER ',';

