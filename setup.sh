#!/bin/bash

source globals.sh
source `which virtualenvwrapper.sh`

echo "Creating virtualenv"
mkvirtualenv $PROJECT_NAME

echo "Installing requirements"
pip install -r requirements.txt

echo "Downloading landsat files to Users/{HOME}/landsat/downloads"
landsat download $LANDSAT7
landsat download $LANDSAT8

echo "Decompressing landsat files to sceneID directories in project directory"
mkdir $LANDSAT7 && cd $_
tar xfvz ../../../landsat/downloads/$LANDSAT7.tar.bz

mkdir $LANDSAT8 && cd $_
tar xfvz ../../../landsat/downloads/$LANDSAT8.tar.bz