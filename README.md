landsat-tutorial
================

BASH scripts for working through Mapbox's excellent [satellite imageary guide](https://www.mapbox.com/guides/processing-satellite-imagery/)


## Requirements

You must already have the following dependencies in order to run this project.

* Python 2.7
* virtualenv
* virtualenvwrapper
* GDAL
* libgeotiff
* ImageMagick

## Sources

Using Development Seed's [landsat-util](https://github.com/developmentseed/landsat-util), we download Landsat imagery from NASA and USGS Earth Explorer hosted by Google Earth Engine servers (which are and offered to the public for free). For this specific tutorial, we are downloading two images of Dubai--one from 2000 and one from 2014.

## Setup
To setup this project run `bash setup.sh` from the root directory.

## Process
To process images for true color, run `bash process.sh` from the root directory.
