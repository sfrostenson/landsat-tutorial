#!/bin/bash

source globals.sh

echo "WORKING ON LANDSAT7 FILE"
cd $LANDSAT7

# land7 tif id is different than uncompressed file id
LAND7="L71160043_04320000519"

echo "Reprojecting bands to Web Mercator"
for BAND in {30,20,10}; do
gdalwarp -t_srs EPSG:3857 $LAND7"_B"$BAND.tif $BAND-projected.tif;done

echo "Merge reprojected bands into one composite RGB image"
gdal_merge.py -v -separate -of GTiff -co PHOTOMETRIC=RGB -o $LAND7-RGB.tif 30-projected.tif 20-projected.tif 10-projected.tif

echo "Modulate default brightness & increase saturation with ImageMagick"
convert -channel RGB -modulate 100,150 -sigmoidal-contrast 4x50% $LAND7-RGB.tif $LAND7-RGB-cc.tif

# the gdaladdo process inserts reduced resolution image versions inside original image
# file, which are used in place of full resolution data at low zoom levels
# impt step for optimization
echo "Building overviews"
gdaladdo -r cubic $LAND7-RGB-cc.tif 2 4 8 10 12

echo "Reattaching geodata"
# first, create a TIFF worldfile from the requested image
listgeo -tfw 30-projected.tif
# next, rename the requested TIFF worldfile w/ the same filename as the non-georeferenced
mv 30-projected.tfw $LAND7-RGB-cc.tfw
# last, apply spatial reference system to non-georeferenced file
gdal_edit.py -a_srs EPSG:3857 $LAND7-RGB-cc.tif

echo "Remove black background"
gdalwarp -srcnodata 0 -dstalpha $LAND7-RGB-cc.tif $LAND7-RGB-cc-2.tif

cd ../$LANDSAT8
echo "WORKING ON LANDSAT8 FILE"

echo "Reprojecting bands to Web Mercator"
for BAND in {4,3,2}; do
 gdalwarp -t_srs EPSG:3857 $LANDSAT8"_B"$BAND.tif $BAND-projected.tif;done

echo "Translating bands into 8-bit format with default settings of -ot and -scale"
gdal_translate -ot Byte -scale 0 65535 0 255 4-projected{,-scaled}.tif
gdal_translate -ot Byte -scale 0 65535 0 255 3-projected{,-scaled}.tif
gdal_translate -ot Byte -scale 0 65535 0 255 2-projected{,-scaled}.tif

echo "Merge reprojected bands into one composite RGB image"
gdal_merge.py -v -ot Byte -separate -of GTiff -co PHOTOMETRIC=RGB -o $LANDSAT8-RGB-scaled.tif 4-projected-scaled.tif 3-projected-scaled.tif 2-projected-scaled.tif

echo "Modulate default brightness & increase saturation with ImageMagick"
convert -channel B -gamma 1.05 -channel RGB -sigmoidal-contrast 20,20% -modulate 100,150 $LANDSAT8-RGB-scaled.tif $LANDSAT8-RGB-scaled-cc.tif

echo "Building overviews"
gdaladdo -r cubic $LANDSAT8-RGB-scaled-cc.tif 2 4 8 10 12

echo "Reattaching geodata"
listgeo -tfw 3-projected.tif
mv 3-projected.tfw $LANDSAT8-RGB-scaled-cc.tfw
gdal_edit.py -a_srs EPSG:3857 $LANDSAT8-RGB-scaled-cc.tif

echo "Remove black background"
gdalwarp -srcnodata 0 -dstalpha $LANDSAT8-RGB-scaled-cc.tif $LANDSAT8-RGB-scaled-cc-2.tif