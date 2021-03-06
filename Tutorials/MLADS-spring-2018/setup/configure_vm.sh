#!/bin/bash

# go ahead and download data so this step doesn't stall during the workshop
wget -O /data/cifar-10-python.tar.gz http://www.cs.toronto.edu/~kriz/cifar-10-python.tar.gz

# tell Spark to use fewer resources so several users can submit simultaneous jobs
sed -i -e 's/spark.driver.memory 5g/spark.driver.memory 1g/g' /dsvm/tools/spark/current/conf/spark-defaults.conf
echo "spark.executor.cores 1" >> /dsvm/tools/spark/current/conf/spark-defaults.conf

# configure MLS
cd /opt/microsoft/mlserver/9.2.1/o16n
sudo dotnet Microsoft.MLServer.Utils.AdminUtil/Microsoft.MLServer.Utils.AdminUtil.dll -silentoneboxinstall Dsvm@123

# download the notebooks
mkdir /etc/skel/notebooks/MLADS-spring-2018
git clone https://github.com/Azure/DataScienceVM /data/DataScienceVM
mv /data/DataScienceVM/Tutorials/MLADS-spring-2018/* /etc/skel/notebooks/MLADS-spring-2018

# copy the notebooks to the initial user's profile
for filename in /home/*; do
  dir=$filename/notebooks
  user=${filename:6}
  cp -r /etc/skel/notebooks/MLADS-spring-2018 $dir
  chown -R $user $dir/MLADS-spring-2018/*
  chown $user $dir/MLADS-spring-2018
done

# create users
# we are skipping this part now that MLADS is over, and most people using this template want
# to use it with the initial user account
## for i in $(seq 1 4);  do
##   u=`openssl rand -hex 2`;
##   # replace 1 with g
##   u=`echo $u | sed -e 's/1/g/g'`
##   # replace 0 with h
##   u=`echo $u | sed -e 's/0/h/g'`
## 
##   p=`openssl rand -hex 4`;
##   # replace 1 with g
##   p=`echo $p | sed -e 's/1/g/g'`
##   # replace 0 with h
##   p=`echo $p | sed -e 's/0/h/g'`
## 
##   useradd -m -d /home/user$u -s /bin/bash user$u
##   echo user$u:$p | chpasswd
##   echo user$u, $p >> '/data/usersinfo.csv';
##   usermod -aG docker user$u
## done

# install CNTK for ML Server's conda environment
/data/mlserver/9.2.1/runtime/python/bin/pip install https://cntk.ai/PythonWheel/GPU/cntk-2.4-cp35-cp35m-linux_x86_64.whl
