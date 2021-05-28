# 单机K8s部署静态和动态Jenkins Slave


#### 1.  部署静态Jenkins Slave

###### 静态slave是在k8s中创建一个固定pod运行,首先需要登录Jenkins,并创建agent,获取secret信息.
![图片说明](/img/jenkins-slave-static-dynamic/添加节点-jenkins-static.png)

###### Deployment方式创建slave,挂载了Docker和kubectl方便在pod中构建镜像和使用kubectl命令,挂载本地的一个目录用于workspace.定义了环境变量JENKINS_URL,JENKINS_SECRET,JENKINS_AGENT_NAME,JENKINS_AGENT_WORKDIR.并且根据需求挂载时区和密钥配置.
```
pwd
/data/k8s-yaml/jenkins

cat jenkinsslave.yaml
---
kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    k8s-app: jenkinsagent
  name: jenkinsagent
  namespace: devops
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: jenkinsagent
  template:
    metadata:
      labels:
        k8s-app: jenkinsagent
      namespace: devops
      name: jenkinsagent
    spec:
      containers:
        - name: jenkinsagent
          image: cnych/jenkins:jnlp6
          imagePullPolicy: IfNotPresent
          tty: true
          resources:
            limits:
              cpu: 1000m
              memory: 2Gi
            requests:
              cpu: 500m
              memory: 1024Mi
          volumeMounts:
            - name: jenkinsagent-workdir
              mountPath: /home/jenkins/workspace
            - name: buildtools
              mountPath: /home/jenkins/buildtools
            - name: docker
              mountPath: /usr/bin/docker
            - name: docker-sock
              mountPath: /var/run/docker.sock
            - name: docker-config
              mountPath: /etc/docker
            - name: date
              mountPath: /etc/localtime
            - name: ssh
              mountPath: /root/.ssh
            - name: sshd
              mountPath: /etc/ssh/sshd_config
            - name: kubectlconfig
              mountPath: /home/jenkins/.kube/config
            - name: kubectlcmd
              mountPath: /usr/bin/kubectl
              
          env:
            - name: JENKINS_URL
              value: http://192.168.1.200:30080
            - name: JENKINS_SECRET
              value: 5639cac0bf16bf15735d44bc435793417365f4dfa8fc72fb12737f3787091ae8
            - name: JENKINS_AGENT_NAME
              value: build02
            - name: JENKINS_AGENT_WORKDIR
              value: /home/jenkins/workspace
      volumes:
        - name: jenkinsagent-workdir
          hostPath: 
            path: /data/devops/jenkins/workspace
            type: Directory
        - name: buildtools
          hostPath: 
            path: /usr/local/buildtools
            type: Directory
        - name: docker
          hostPath:
            path: /usr/bin/docker
        - name: docker-sock
          hostPath:
            path: /var/run/docker.sock
        - name: docker-config
          hostPath:
            path: /etc/docker
        - name: date
          hostPath:
            path: /etc/localtime
        - name: ssh
          hostPath:
            path: /root/.ssh
        - name: sshd
          hostPath:
            path: /etc/ssh/sshd_config
        - name: kubectlconfig
          hostPath: 
            path: /root/.kube/config
        - name: kubectlcmd
          hostPath: 
            path: /usr/bin/kubectl

kubectl apply -f jenkinsslave.yaml  #创建配置清单命令
```
#### 2.  部署动态Jenkins Slave

###### 动态Jenkins Slave,安装kubernetes插件（安装完成后最好重启一下）。配置插件信息 系统设置 -> 最后面 Cloud ->增加一个云.
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes插件安装-jenkins-dynamic.png)

###### 安装完毕后,点击 Manage Jenkins —> Configure System —> (拖到最下方),如果有 Add a new cloud —> 选择 Kubernetes,然后填写 Kubernetes和Jenkins配置信息即可,但是最新版本的Kubernetes插件将配置单独放置到了一个页面中
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes插件配置位置-jenkins-dynamic.png)

###### 此时需要点击 a separate configuration page这个链接,跳转到 Configure Cloud 页面
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes跳转到添加页面-jenkins-dynamic.png)

###### 在该页面我们可以点击 Add a new cloud -> 选择 Kubernetes，然后填写 Kubernetes 和 Jenkins 配置信息:
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes-配置信息1-jenkins-dynamic.png)

###### 注意namespace,这里填devops,然后点击Test Connection,如果出现Connection test successful的提示信息证明Jenkins已经可以和Kubernetes系统正常通信了,然后下方的 Jenkins URL地址: http://jenkins.devops.svc.cluster.local:30080,这里的格式为:服务名.namespace.svc.cluster.local:30080, 根据上面创建的jenkins的服务名填写.通道地址jenkins.devops.svc.cluster.local:30081是Jenkins Slave使用的端口.
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes-配置信息2-jenkins-dynamic.png)

###### 配置Pod Template,其实就是配置Jenkins Slave运行的Pod模板,命名空间我们同样使用devops,Labels这里也非常重要,对于后面执行Job的时候需要用到该值,然后我们这里使用的是cnych/jenkins:jnlp6这个镜像,这个镜像是在官方的jnlp镜像基础上定制的,有docker、kubectl等一些实用的工具
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes-配置信息3-jenkins-dynamic.png)
###### ⚠注意⚠  容器的名称必须是jnlp,这是默认拉起的容器,另外需要将Command to run和Arguments to pass to the command的值都删除掉,否则会失败.

###### 然后我们这里需要在下面挂载几个主机目录,一个是 /var/run/docker.sock,该文件是用于Pod中的容器能够共享宿主机的Docker,这就是大家说的docker in docker的方式，Docker二进制文件已经打包到上面的镜像中了,另外一个目录下/root/.kube目录,我们将这个目录挂载到容器的/root/.kube目录下面这是为了让我们能够在Pod的容器中能够使用 kubectl工具来访问我们的Kubernetes服务,方便我们后面在Slave Pod部署Kubernetes应用.另外根据自己实际情况需求,也可以挂载时区,hosts等主机目录,权限最好更改为1000.
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes-配置信息5-jenkins-dynamic.png)
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes-配置信息6-jenkins-dynamic.png)

###### 另外如果在配置了后运行Slave Pod的时候出现了权限问题,这是因为Jenkins Slave Pod中没有配置权限,所以需要配置上ServiceAccount,在Slave Pod配置的地方点击下面的高级,添加上对应的ServiceAccount即可,以及顺便指定下工作卷所在的空间,应该是保存job的构建数据的.
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes-配置信息7-jenkins-dynamic.png)

#### 3.  动态Jenkins Slave测试

###### Kubernetes插件的配置工作完成了,接下来我们就来添加一个Job任务,看是否能够在 Slave Pod中执行,任务执行完成后看Pod是否会被销毁

###### 在Jenkins首页点击create new jobs,创建一个测试的任务,输入任务名称,然后我们选择Freestyle project类型的任务,注意在下面的Label Expression这里要填入ydzs-jnlp,就是前面我们配置的Slave Pod中的Label,这两个地方必须保持一致
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes-配置信息8-jenkins-dynamic.png)

###### 然后往下拉,在 Build区域选择Execute shell
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes-配置信息9-jenkins-dynamic.png)

###### 然后输入要测试用的命令,最后点保存.
```
echo "测试 Kubernetes 动态生成 jenkins slave"
echo "==============docker in docker==========="
docker info

echo "=============kubectl============="
kubectl get pods
```
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes-配置信息10-jenkins-dynamic.png)

###### 现在直接在页面点击左侧的Build now触发构建,然后观察Kubernetes集群中Pod的变化:
```
$ kubectl get pods -n kube-ops                        
NAME                                           READY   STATUS              RESTARTS   AGE
jenkins-68ccff445c-dk24f                       1/1     Running             0          12h
jnlp-1g893                                     0/1     ContainerCreating   0          83s
```

###### 此时可以看到一个新的Pod:jnlp-1g893被创建,这是我们的Jenkins Slave.到这里证明任务已经构建完成,这个时候再去集群查看下Pod列表,发现kube-ops这个namespace下面已经没有之前的Slave这个Pod了.如果有部署Dashboard的话,也可以通过它更方便的查看.
```
$ kubectl get pods -n kube-ops                        
NAME                                           READY   STATUS              RESTARTS   AGE
jenkins-68ccff445c-dk24f                       1/1     Running             0          12h
```

###### 到这里为止,就完成了使用Kubernetes动态生成Jenkins Slave的过程.

#### 4. 补充内容
###### 最后补充下自己部署过程遇到的Jenkins构建job的时间不正确,并且解决的办法---解决:打开jenkins的【系统管理】---> 【脚本命令行】,在命令框中输入一下命令【时间时区设为亚洲上海】:
```
System.setProperty('org.apache.commons.jelly.tags.fmt.timeZone', 'Asia/Shanghai')
```
###### 点击【运行】,可以看到时间已正常,如图
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes-时区修改-jenkins-dynamic.png)
![图片说明](/img/jenkins-slave-static-dynamic/kubernetes-时区修改2-jenkins-dynamic.png)

#### 5. 参考资料
```
https://www.qikqiak.com/k8s-book/
https://www.k8stech.net/jenkins-docs/pipelineintegrated/chapter07/
https://blog.csdn.net/qq_40168110/article/details/90755684
```






