# Docker Compose部署Nexus


######  No.1 Nexus 基本概念之组件

```
简单说明下Nexus,理解为私服仓库:本地maven私服加快构建速度
代理仓库:将公网等第三方提供的仓库代理到本地.

组件的相关概念,组件通常是各种文件的存放,具体见下图1和图2的文字介绍.
```
![图片说明](/img/nexus/components-组件1.png)
![图片说明](/img/nexus/components-组件2.png)

######  No.2 Nexus 基本概念之资产
```
Assets-资产:
简单理解Maven当中的pom算是资产的一部分,包含元数据的重要补充.
pom存档文件是与jar/war包组件相关联的资产.
具体了解请见下图的文字介绍.
```
![图片说明](/img/nexus/assets-资产.png)

######  No.3 Nexus 仓库管理
```
仓库格式简单介绍,详细内容见下图1文字介绍.
下载机制,Maven从存储库下载组件同时,也会下载该组件的POM.参考下图2文字介绍.
中央仓库相关概念总结:组件元数据,释放稳定性,组件安全,性能.参考下图3文字介绍.
```
![图片说明](/img/nexus/仓库格式.png)
![图片说明](/img/nexus/下载机制.png)
![图片说明](/img/nexus/中央仓库.png)

######  No.4  准备Nexus compose文件
```
参考docker官方的compose的相关说明,并且辅助相关nexus博客进行操作.
此步骤操作前,需要安装docker和docker_compose,可以参考我博客里的安装步骤.
compose相关内容一并附上:
[root@xxx nexus]# cat docker-compose.yml 
version: "3.8"
services:
  nexus3:
    restart: always
    image: sonatype/nexus3
    container_name: nexus3
    ports:
      - "80:8081"
    volumes:
      - data:/nexus-data    
    logging:
      driver: "json-file"
      options:
        max-size: "200k"
        max-file: "10"
volumes:
  data:
```

######  No.5  启动Nexus,并验证成功与否
```
[root@xxx nexus]# docker-compose up -d
[root@xxx nexus]# docker ps -a 
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
eeb6a8633273        sonatype/nexus3     "sh -c ${SONATYPE_DI…"   About an hour ago   Up About an hour    0.0.0.0:80->8081/tcp   nexus3

验证安装是否成功:
地址:http://ip:port/
用户名: admin
密码: admin123
新版本查看密码命令,并且将拿到的密码改为上面的密码:
[root@sonarqube nexus]# cat /var/lib/docker/volumes/nexus_data/_data/admin.password
de5bf74d-6340-43f8-8361-0f861833ccd2
```
![图片说明](/img/nexus/Nexus修改密码.png)
![图片说明](/img/nexus/nexus登录完成.png)

######   参考文档
```
docker_compose官方文档: https://docs.docker.com/compose/compose-file/
nexus搭建maven私服: https://www.jianshu.com/p/62483b0505a5
Compose部署Nexus: https://blog.csdn.net/tiancxz/article/details/104197060
```



