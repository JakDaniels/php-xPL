#!/bin/bash

outfile="xPL.i"

if [ ! -f xPLLib.tgz ]; then
	echo "Downloading xPLLib Source...."
	wget -O xPLLib.tgz "http://xpl4java.org/xPL4Linux/downloads/xPLLib.tgz"
fi

if [ ! -d xPLLib ]; then
	echo "Unpacking Source...."
	tar -zxf xPLLib.tgz
fi

cd xPLLib
echo "Compiling and installing xPLLib...."
make
sudo make install
cd examples
echo "Compiling xPLLib examples and xPL_Hub...."
make

cd ..

echo "Fixing up header files for SWIG...."
cat xPLLib/xPL.h |grep -v "xPL_setTimelyHeartbeats()" >xPL.h
cat xPLLib/xPL_priv.h |grep -v "xPL_releaseServiceConfig(xPL_ServicePtr)" >xPL_priv.h

echo "Using SWIG to create PHP module source...."
swig -php $outfile

echo "Compiling PHP module source...."
gcc `php-config --includes` -fpic -c xPL_wrap.c

gcc -shared xPL_wrap.o -lxPL -o xPL.so

echo "Copying xPL.so to PHP extensions dir..."
echo "extension=`php-config --extension-dir`/xPL.so" >xPL.ini

sudo cp -f xPL.so `php-config --extension-dir`/
sudo cp -f xPL.ini /etc/php5/conf.d/91-xPL.ini
sudo chown root:root `php-config --extension-dir`/xPL.so /etc/php5/conf.d/91-xPL.ini

echo "There is a xPL.php include file that loads the module and provides a xPL class."
echo "DONE!"

