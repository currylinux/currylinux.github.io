# Docker Compose实现Gogs服务部署


#### 1.  Gogs简单介绍

###### Gogs简单介绍
```
什么是Gogs?
Gogs 是一款极易搭建的自助 Git 服务。
开发目的:
Gogs 的目标是打造一个最简单、最快速和最轻松的方式搭建自助Git服务.使用Go语言开发使得Gogs能够通过独立的二进制分发,
并且支持Go语言支持的所有平台,包括 Linux、Mac OS X、Windows以及ARM平台
```
![图片说明](/img/gogs/基本介绍-gogs.png)

#### 2.  Gogs的docker环境及部署流程

###### docker和compose的安装此处就省略,基于以上环境的基础上,直接部署
```
pwd
/root/gogs-project

配置docker-compose
cat docker-compose.yaml 
version: '2.3'
services:

  mysql-gogs:
    container_name: mysql-gogs
    image: mysql:5.7
    restart: always
    volumes:
        - /data/mysql:/var/lib/mysql
        - /data/conf:/etc/mysql/conf.d
    environment:
        MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
        MYSQL_DATABASE: ${MYSQL_DATABASE}
        MYSQL_USER: ${MYSQL_USER}
        MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    ports:
        - "${MYSQL_PORT}:3306"
    networks:
        - gogs
  gogs:
    container_name: gogs
    image: gogs/gogs:0.11.91
    restart: always
    depends_on:
        - mysql-gogs
    ports:
        - "${SSH_PORT}:22"
        - "${GOGS_PORT}:3000"
    volumes:
        - /data/gogs-data:/data
    links:
       - mysql-gogs
    environment:
        - "RUN_CROUD=true"
        - SSH_PORT=${SSH_PORT}
    networks:
        - gogs

networks:
    gogs:
      driver: bridge

volumes:
    gogs-data:
      driver: local
    mysql-data:
      driver: local
```
###### 上面用到的环境变量需放在文件名为.env的文件,并保证与docker-compose.yaml文件在同一目录下,内容如下:
```
cat .env
MYSQL_ROOT_PASSWORD=mysql_root_password
MYSQL_DATABASE=gogs
MYSQL_USER=gogs
MYSQL_PASSWORD=gogs_password


GOGS_PORT=3000
SSH_PORT=10022
MYSQL_PORT=3306
```
###### 执行命令启动,并且验证是否启动成功
```
docker-compose up -d
docker ps -a 
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                           NAMES
bc08f4a4a4cc        gogs/gogs:0.11.91   "/app/gogs/docker/st…"   12 days ago         Up 12 days          0.0.0.0:3000->3000/tcp, 0.0.0.0:10022->22/tcp   gogs
b8ed2f175889        mysql:5.7           "docker-entrypoint.s…"   2 weeks ago         Up 12 days          0.0.0.0:3306->3306/tcp, 33060/tcp               mysql-gogs
```

#### 2.  HTTP运行Gogs

###### 第一次在浏览器运行Gogs会需要填写一些初始化数据库配置等参数. 如下图:
![图片说明](/img/gogs/数据库设置-gogs.png)
![图片说明](/img/gogs/应用设置-gogs.png)
![图片说明](/img/gogs/可选设置-gogs.png)

###### yum安装nginx并且配置实现反代
```
两套配置自己根据需求做调整,也可以自定义
#server {
#    listen      80; ## listen for ipv4
#    server_name   gogs.domain.com;
#    return      301 https://$server_name$request_uri;
#}
server {
    charset utf-8;
    client_max_body_size 300M;

    listen 80; # 或者 443，如果你使用 HTTPS 的话

    # SSL support
    # ssl on;
    # ssl_certificate      ./ssl/fullchain.cer;
    # ssl_certificate_key  ./ssl/domain.com.key;

    server_name gogs.domain.com;

    location / { # 如果你希望通过子路径访问，此处修改为子路径，注意以 / 开头并以 / 结束
        proxy_pass http://127.0.0.1:3000/;
    }
}


server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
           proxy_pass http://127.0.0.1:3000/;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
```

#### 3.  部署过程参考文档

```
参考文档如下,向各位大佬学习
https://curder.gitbooks.io/blog/others/user-docker-deploy-gogs.html?q=
https://github.com/Unknwon/wuwen.org/issues/12
https://blog.csdn.net/lcr_happy/article/details/103193958
https://clonote.com/archives/1552356953819
https://my.oschina.net/xsh1208/blog/3019458

#官方及其它使用文档如下:
https://gogs.io/docs/installation/install_from_binary
https://www.cnblogs.com/Sungeek/p/9203038.html
```





