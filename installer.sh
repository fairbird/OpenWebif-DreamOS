#!/bin/bash
##setup command=wget https://raw.githubusercontent.com/fairbird/OpenWebif-DreamOS/main/installer.sh -O - | /bin/sh

version=1.6

if [ -d /usr/lib/python2.6 ]; then
if [ ! -d /usr/lib/python2.7 ]; then
echo "**********************************************************"
echo "*                         SORRY                          *"
echo "*                Not Compatible with (OE1.6)             *"
echo "*                     RAED - Fairbird                    *"
echo "**********************************************************"
exit 1
fi
fi

if [ ! -f /var/lib/dpkg/status ]; then
echo "**********************************************************"
echo "*                         SORRY                          *"
echo "*              Plugin only for DreamOs Image             *"
echo "*                     RAED - Fairbird                    *"
echo "**********************************************************"
exit 1
fi

echo ""
# Find name of device
STATUS=/var/lib/dpkg/status
# check depends packges if installed
if grep -q aio-grab $STATUS ; then
	aio_grab="True"
else
	aio_grab="False"
fi
if grep -q python-shell $STATUS ; then
	python_shell="True"
else
	python_shell="False"
fi
if grep -q python-json $STATUS ; then
	python_json="True"
else
	python_json="False"
fi
if grep -q python-compression $STATUS ; then
	python_compression="True"
else
	python_compression="False"
fi
if grep -q python-misc $STATUS ; then
	python_misc="True"
else
	python_misc="False"
fi
if grep -q python-pyopenssl $STATUS ; then
	python_pyopenssl="True"
else
	python_pyopenssl="False"
fi
if grep -q python-numbers $STATUS ; then
	 python_numbers="True"
else
	 python_numbers="False"
fi
# install depend packges if need it
if [ $aio_grab = 'True' -a $python_shell = 'True' -a $python_json = 'True' -a $python_compression = 'True' -a $python_misc = 'True' -a $python_pyopenssl = 'True' -a $python_numbers = 'True' ]; then
	echo "All depend packages Installed"
else
	echo "Download and install depend packages ....."
	dpkg --configure -a;
	apt-get update;
	apt-get install aio_grab python-shell python-json python-compression python-misc python-pyopenssl python-numbers -y;
	apt-get install -f -y;
fi
# Make more check depend packges
if grep -q aio-grab $STATUS ; then
     echo ""
else
     echo "Missing (aio_grab) package"
exit 1
fi
if grep -q python-shell $STATUS ; then
     echo ""
else
     echo "Missing (python-shell) package"
exit 1
fi
if grep -q python-json $STATUS ; then
     echo ""
else
     echo "Missing (python-json) package"
exit 1
fi
if grep -q python-compression $STATUS ; then
     echo ""
else
     echo "Missing (python-compression) package"
exit 1
fi
if grep -q python-misc $STATUS ; then
     echo ""
else
     echo "Missing (python-misc) package"
exit 1
fi
if grep -q python-pyopenssl $STATUS ; then
     echo ""
else
     echo "Missing (python-pyopenssl) package"
exit 1
fi
if grep -q python-numbers $STATUS ; then
     echo ""
else
     echo "Missing (python-numbers) package"
exit 1
fi

# Download and install plugin
cd /tmp 
set -e
rm -rf *OpenWebif-DreamOS* > /dev/null 2>&1
rm -rf *main* > /dev/null 2>&1
wget https://github.com/fairbird/OpenWebif-DreamOS/archive/refs/heads/main.tar.gz
tar -xzf main.tar.gz
cp -r OpenWebif-DreamOS-main/usr /
cp -r OpenWebif-DreamOS-main/tmp /
# check if missing packges and send it to device
if [ ! -f /usr/bin/cheetah ]; then
cp -rf /tmp/RAED/bin/* /usr/bin > /dev/null 2>&1
fi
if [ ! -f /usr/lib/python2.7/getpass.pyo ]; then
cp -rf /tmp/RAED/python/getpass.py /usr/lib/python2.7 > /dev/null 2>&1
fi
if [ ! -f /usr/lib/python2.7/lib-dynload/grp.so ]; then
cp -rf /tmp/RAED/python/lib-dynload/grp.so /usr/lib/python2.7/lib-dynload > /dev/null 2>&1
fi
if [ ! -f /usr/lib/python2.7/lib-dynload/nis.so ]; then
cp -rf /tmp/RAED/python/lib-dynload/nis.so /usr/lib/python2.7/lib-dynload > /dev/null 2>&1
fi
if [ ! -f /usr/lib/python2.7/site-packages/Cheetah ]; then
cp -rf /tmp/RAED/python/site-packages/Cheetah /usr/lib/python2.7/site-packages > /dev/null 2>&1
fi
# clean /tmp directory
rm -rf *OpenWebif-DreamOS* > /dev/null 2>&1
rm -rf *main* > /dev/null 2>&1
##
set +e
cd ..
sync
echo "#########################################################"
echo "#           OpenWebif INSTALLED SUCCESSFULLY            #"
echo "#                   Edit by Raed                        #"              
echo "#                     support                           #"
echo "#   https://www.tunisia-sat.com/forums/threads/3902353/ #"
echo "#########################################################"
sleep 2
# Disable Webinterface before restart enigma2 to active enable of openwebif
systemctl stop enigma2
sed -i 's/config.plugins.Webinterface.enabled=true/config.plugins.Webinterface.enabled=false/g' '/etc/enigma2/settings' > /dev/null 2>&1
systemctl start enigma2
exit 0
