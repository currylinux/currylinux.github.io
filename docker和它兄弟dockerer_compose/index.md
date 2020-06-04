# Docker和它兄弟Dockerer_Compose




######  No.1 脚本化部署安装docker
```
[root@xxx ~]# cat docker.sh 
#!/bin/bash

DOCKER_VERSION=docker-ce-18.09.9
DOCKER_CLIENT=docker-ce-cli-18.09.9
# remove old version
sudo yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

#remove all docker data 
sudo rm -rf /var/lib/docker

#preinstall utils 
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

# add repository
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# make cache
sudo yum makecache fast

# install the latest stable version of docker
yum list docker-ce --showduplicates | sort -r
yum install -y ${DOCKER_VERSION} ${DOCKER_CLIENT} containerd.io

# start deamon and enable auto start when power on
sudo systemctl enable docker --now
if [ $? = 0 ];then
    echo "docker部署成功,请开始你的表演!"
else
    echo "docker部署失败,请检查配置!" && exit 2
fi

 使用说明:直接将此脚本复制到Linux服务器上运行.
 最后输入命令systemctl status docker,进行验证!
```

###### No.2 手动安装Docker_Compose

```
参考docker官方文档步骤进行:
https://docs.docker.com/compose/install/

下载docker-compose稳定版本:
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

将可执行权限应用于二进制文件:
sudo chmod +x /usr/local/bin/docker-compose

做软链接进行路径指向:
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

测试安装是否成功:
docker-compose -v
docker-compose -h
```


