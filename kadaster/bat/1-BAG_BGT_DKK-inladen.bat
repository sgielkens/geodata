rem BAG inladen
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" bag-light.gpkg -overwrite -progress

rem BGT inladen
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" bgt_scheiding.gml -overwrite -progress
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" bgt_kunstwerkdeel.gml -overwrite -progress
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" bgt_waterdeel.gml -overwrite -progress
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" bgt_wegdeel.gml -overwrite -progress
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" bgt_ondersteunendwaterdeel.gml -overwrite -progress
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" bgt_openbareruimtelabel.gml -overwrite -progress
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" bgt_ondersteunendwegdeel.gml -overwrite -progress

rem DKK inladen
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" kadastralekaart_perceel.gml -overwrite -progress -sql @sql.txt
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" kadastralekaart_openbareruimtelabel.gml -overwrite -progress
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" kadastralekaart_kadastralegrens.gml -overwrite -progress
"C:\Program Files\QGIS 3.36.2\bin\ogr2ogr" -f "PostgreSQL" PG:"host=localhost port=5432 dbname=kadastraal user=postgres password=postgres" kadastralekaart_pand.gml -overwrite -progress
