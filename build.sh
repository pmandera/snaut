#!/bin/bash
VERSION=0.1.5
DIST_NAME="snaut-$VERSION"

coffee -c -o snaut/static/js/snaut snaut/coffee

rm -r ./dist

pyinstaller snaut_linux.spec

cp -r ./snaut/static ./dist
cp -r ./snaut/templates ./dist
cp -r ./doc ./dist

mkdir ./dist/data

cp ./config.ini ./dist

cp -r dist $DIST_NAME

tar -zcvf ${DIST_NAME}.tar.gz $DIST_NAME

rm -r $DIST_NAME

mkdir -p ./dist-linux

mv ${DIST_NAME}.tar.gz ./dist-linux
