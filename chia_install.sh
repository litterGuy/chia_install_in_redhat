#! /bin/bash

# 记录执行的目录
curdir=`pwd`

sudo yum install epel-release -y
sudo yum update -y

# Compiling python 3.7 is generally required on CentOS 7.7 and newer
sudo yum install gcc openssl-devel bzip2-devel zlib-devel libffi libffi-devel -y
sudo yum install libsqlite3x-devel -y
# possible that on some RHEL based you also need to install
sudo yum groupinstall "Development Tools" -y
sudo yum install python3-devel gmp-devel  boost-devel libsodium-devel -y

sudo yum install wget -y
sudo wget https://www.python.org/ftp/python/3.7.7/Python-3.7.7.tgz
sudo tar -zxvf Python-3.7.7.tgz ; cd Python-3.7.7
./configure --enable-optimizations; sudo make -j$(nproc) altinstall; cd ..

# Download and install the source version
git clone https://github.com/Chia-Network/chia-blockchain.git -b latest

pipconf_path=/root/.pip/pip.conf
if [ -f "$pipconf_path" ]; then
sudo rm -rf $pipconf_path
fi

echo "
[global]
index-url=http://mirrors.aliyun.com/pypi/simple/
extra-index-url=
	https://pypi.tuna.tsinghua.edu.cn/simple

[install]
trusted-host=mirrors.aliyun.com
" > /root/.pip/pip.conf

# python默认版本是否正确
python_version=`python -V 2>&1`
echo "python version is: $python_version"

python_path=`which python`
echo "python path is: $python_path"

python_bin_home=${python_path%/*}
echo "python bin home path is: $python_bin_home"

if [[ $python_version =~ "Python 3.7.7" ]]
then
    echo "default python is 3.7.7"
else
    echo "set default python is 3.7.7"
    sudo rm -rf $python_path
    ln -s "$curdir/Python-3.7.7/python" $python_path
    ln -s "$python_bin_home/python" "$python_bin_home/python3.7"
fi

echo "set python done"

cd chia-blockchain

sh install.sh
. ./activate

chia init

#chia keys generate

sed -i "s/self_hostname: localhost/self_hostname: 0.0.0.0/g" /root/.chia/mainnet/config/config.yaml

chia start wallet

# 
chia wallet show