### NOTE: This should only be ran once upon initial installation of Snort.
## If you need to redo the installation, just run the following command to remove the directory:
#   sudo rm -r ~/snort_src

## Author: Joshua Stevens

## This is a shell script to install Snort 3 and all prerequisites/dependencies on Ubuntu Server 18.04.
# Snort is a Network Intrusion Detection and Prevention System

## References : https://snort-org-site.s3.amazonaws.com/production/document_files/files/000/012/147/original/Snort_3.1.8.0_on_Ubuntu_18_and_20.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7AK5ITMJQBJPARJ%2F20230513%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230513T220257Z&X-Amz-Expires=172800&X-Amz-SignedHeaders=host&X-Amz-Signature=5d20eed82c0693da53e517d387ac851d5673eceae7e74f631364bd386cffbaf1

## Instructions:
# Run the script using the following command:
#  sudo sh snort-3-installation.sh

echo "------ Installation of Snort 3 Starting! ------\n"
# Update system and install prerequisites for snort
echo "\n\n------ Updating system ------"
sudo apt-get update && sudo apt-get dist-upgrade -y

# Set timezone for Splunk
sudo dpkg-reconfigure tzdata

# Create a folder for source files and navigate into it
mkdir ~/snort_src
cd ~/snort_src

# install prerequisites for Snort 3
echo "\n\n------ Installing Snort Prereqs ------"
sudo apt-get install -y build-essential autotools-dev libdumbnet-dev libluajit-5.1-dev libpcap-dev zlib1g-dev pkg-config libhwloc-dev cmake liblzma-dev openssl libssl-dev cpputest libsqlite3-dev libtool uuid-dev git autoconf bison flex libcmocka-dev libnetfilter-queue-dev libunwind-dev libmnl-dev ethtool libjemalloc-dev

# Install safec
echo "\n\n------ Installing safec ------"
cd ~/snort_src
wget https://github.com/rurban/safeclib/releases/download/v02092020/libsafec-02092020.tar.gz
tar -xzvf libsafec-02092020.tar.gz
cd libsafec-02092020.0-g6d921f
./configure
make
sudo make install
echo "\n\n------ safec installed! ------"

# Install PCRE
cd ~/snort_src/
wget https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz
tar -xzvf pcre-8.45.tar.gz
cd pcre-8.45
./configure
make
sudo make install
echo "\n\n------ PCRE installed! ------"

# Download and install gperftools 2.9
cd ~/snort_src
wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz
tar xzvf gperftools-2.9.1.tar.gz
cd gperftools-2.9.1
./configure
make
sudo make install
echo "\n\n------ gperftools 2.9 installed! ------"

# Download and install Ragel
cd ~/snort_src
wget http://www.colm.net/files/ragel/ragel-6.10.tar.gz
tar -xzvf ragel-6.10.tar.gz
cd ragel-6.10
./configure
make
sudo make install
echo "\n\n------ ragel-6.10 installed! ------"

# Download but do not install the Boost C++ Libraries
# Install Hyperscan 5.4 from location of the Boost directory
cd ~/snort_src
wget https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.tar.gz
tar -xvzf boost_1_77_0.tar.gz
cd ~/snort_src
wget https://github.com/intel/hyperscan/archive/refs/tags/v5.4.0.tar.gz
tar -xvzf v5.4.0.tar.gz
mkdir ~/snort_src/hyperscan-5.4.0-build
cd hyperscan-5.4.0-build/
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DBOOST_ROOT=~/snort_src/boost_1_77_0/ ../hyperscan-5.4.0
make
sudo make install
echo "\n\n------ Hyperscan installed! ------"

# Install flatbuffers
cd ~/snort_src
wget https://github.com/google/flatbuffers/archive/refs/tags/v2.0.0.tar.gz -O flatbuffers-v2.0.0.tar.gz
tar -xzvf flatbuffers-v2.0.0.tar.gz
mkdir flatbuffers-build
cd flatbuffers-build
cmake ../flatbuffers-2.0.0
make
sudo make install
echo "\n\n------ flatbuffers installed! ------"

# Install Data Aquisition Library - DAQ
cd ~/snort_src
wget https://github.com/snort3/libdaq/archive/refs/tags/v3.0.11.tar.gz -O libdaq-3.0.11.tar.gz
tar -xzvf libdaq-3.0.11.tar.gz
cd libdaq-3.0.11
./bootstrap
./configure
make
sudo make install

# Update shared libraries
sudo ldconfig

# Download and install Snort 3 with default settings
cd ~/snort_src
wget https://github.com/snort3/snort3/archive/refs/tags/3.1.18.0.tar.gz -O snort3-3.1.18.0.tar.gz
tar -xzvf snort3-3.1.18.0.tar.gz
cd snort3-3.1.18.0
./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc --enable-jemalloc
cd build
make
sudo make install

# Verify Snort is running correctly
/usr/local/bin/snort -V

# Validate the config file
snort -c /usr/local/etc/snort/snort.lua

# Configure network card
cd ~
# My VM interface is eth0, yours might be different
sudo ethtool -k eth0 | grep receive-offload
# At this point you need to manually turn off gro and lro for eth0
