# K8s动态Jenkins Slave使用Pipeline发布Docker应用


#### 1. 前期环境准备及注意事项

###### 首先环境用宿主机方式、docker方式、以及kubernetes方式搭建的Jenkins都是可以的.如果用kubernetes的方式的话,可以参考本博客的搭建篇.
###### 同样如果用到的也是动态slave的方式的话,需要将宿主机的key文件、hosts文件、localtime文件都挂到容器里,后面会用到.
![图片说明](/img/dynamic-jenkins-docker-application/挂载宿主机路径-dockerapplication.png)

###### 这里用到内网hosts解析主机,方便下面写pipeline的Jenkinsfile的时候的统一命名.以及使用ssh-keygen命令生成密钥,并且拷贝到要发布更新的服务器上,实现免密登录.
![图片说明](/img/dynamic-jenkins-docker-application/hosts主机名解析-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/ssh免密登录-dockerapplication.png)

#### 2. 配置Jenkins流水线环境

###### 配置流水线,定义相关的变量,随后需要在Jenkinsfile里进行引用.看下图具体操作
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数1-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数2-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数3-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数4-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数5-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数6-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数7-dockerapplication.png)

#### 3. 编写流水线Jenkinsfile

###### 代码仓库使用Gitlab或者Gogs都可以,根据自己实际情况操作,需要先创建一个Jenkinsfile的目录,并且在目录下编写名为ci.jenkinsfile的流水线.

```
#!groovy

@Library ('jenkinslib@master') _

//func from sharelibrary
def tools = new org.devops.tools()
// 仓库地址,此处需要在主机内做hosts解析
def registryUrl = "harbor.devops.com"
// 镜像
def image = "${registryUrl}/${imageEndpoint}"
//定义时间戳
def TAG = "`date +%Y-%m-%d_%H-%M`"


//env
String srcUrl = "${env.srcUrl}"
String branchName = "${env.branchName}"
String imageEndpoint = "${env.imageEndpoint}"
String UpdateHost = "${env.UpdateHost}"
String ImageUrl = "${env.ImageUrl}"
String TestImageUrl = "${env.TestImageUrl}"


//pipeline
pipeline{
    agent { node { label "xxx-jnlp"}}

    stages{


        stage("CheckOut"){
            steps{
                script{

                    tools.PrintMes("获取代码","green")
                    checkout([$class: 'GitSCM', branches: [[name: "${branchName}"]], 
                    doGenerateSubmoduleConfigurations: false, 
                    extensions: [], 
                    submoduleCfg: [], 
                    userRemoteConfigs: [[credentialsId: 'gogs-admin-user', url: "${srcUrl}"]]])
            }
        }
    }

    
        stage("BuildMirror"){
            steps{
                script{

                    tools.PrintMes("构建镜像","green")
                    withCredentials([usernamePassword(credentialsId: 'docker-auth', 
                    passwordVariable: 'HARBOR_ACCOUNT_PSW', 
                    usernameVariable: 'HARBOR_ACCOUNT_USR')]) {
                    // some block
                    
                    

                    sh """
                        docker login  -u ${HARBOR_ACCOUNT_USR} -p ${HARBOR_ACCOUNT_PSW} ${registryUrl}
                        docker build -t "${image}:${TAG}" .
                        sleep 1
                        docker push "${image}:${TAG}"
                       """
                   } 
             }
        }
    }

    stage("UpdatedVersion"){
            steps{
                script{

                    tools.PrintMes("更新版本","green")
					echo "${TAG}"
                    sh "ssh root@${UpdateHost} 'cd /data && \\cp -rf docker-compose.yaml{,.bak} && sed  -i \"s@image: ${ImageUrl}.*@image: ${TestImageUrl}:\"${TAG}\"@\" docker-compose.yaml && cat  docker-compose.yaml && docker-compose down -v && docker-compose up -d ' && echo 发布成功,请再确认下镜像版本!;sleep 3"
              }
        }
    }

}


//构建后操作
post {
    always{
        script{
            println("always")
        }
    }
        
    success{
        script{
            currentBuild.description = "\n 构建成功!"
        }
   }

    failure{
        script{
            currentBuild.description = "\n 构建失败!"
        }
    }
        
    aborted{
        script{
            currentBuild.description = "\n 构建取消!"
            }
        }
    }
}

```

###### 上面的流水线引入了AnsiColor插件,所以需要先安装插件,然后再定义下Shared Groovy Libraries的共享库,内容如下,目录层级是(jenkinslib/src/org/devops/tools.groovy)
```
tools.groovy
package org.devops

//格式化输出
def PrintMes(value,color){
    colors = ['red'   : "\033[40;31m >>>>>>>>>>>${value}<<<<<<<<<<< \033[0m",
              'blue'  : "\033[47;34m ${value} \033[0m",
              'green' : "[1;32m>>>>>>>>>>${value}>>>>>>>>>>[m",
              'green1' : "\033[40;32m >>>>>>>>>>>${value}<<<<<<<<<<< \033[0m" ]
    ansiColor('xterm') {
        println(colors[color])
    }
}
```
###### 同样需要在Jenkins上配置下Libraries的参数,请看下面的截图.凭据的话就是自己代码仓库的账号密码信息,也需要在Jenkins上配置下.
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数8-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数9-dockerapplication.png)


#### 4. 补充docker登录harbor的pipeline语法生成

###### 需要把harbor镜像仓库的账号和密码首先同样配置到凭据当中,然后到对应的job上,点击流水线,示例步骤选择:withCredentials: Bind credentials to variables
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数10-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数12-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数11-dockerapplication.png)

#### 5. 最后流水线运行并验证流程

###### 这里只是我自己调试的流水线的最终版,生产中肯定要根据自己实际的情况进行调试的.每条流水线都是要经过充分测试和调试的,不是拿过来就可以随意使用的.最后看下最终的效果.
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数13-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数14-dockerapplication.png)
![图片说明](/img/dynamic-jenkins-docker-application/Jenkins配置参数15-dockerapplication.png)

