# K8s单机部署Jenkins



#### No.1 kubeadm安装单机版k8s前期准备

###### 1个节点,Centos7.7系统,在节点上添加hosts信息
```
cat /etc/hosts
10.8.8.8 kubernetes-master
```
###### 禁用防火墙,并且禁用SELINUX
```
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/'  /etc/selinux/config
```
###### 由于开启内核 ipv4 转发需加载 br_netfilter 模块,并创建文件/etc/sysctl.d/k8s.conf
```
modprobe br_netfilter

cat << EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p /etc/sysctl.d/k8s.conf
```
###### 安装 ipvs,创建脚本,保证在节点重启后能自动加载所需模块.
```
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```
###### 确保节点上已安装 ipset 软件包,为便于查看 ipvs 的代理规则,安装管理工具 ipvsadm,同步服务器时间,公有云基本都会自带此功能
```
yum install -y ipset ipvsadm
yum install chrony -y
systemctl enable chronyd
systemctl start chronyd
chronyc sources
```
###### 关闭swap分区相关操作,有的公有云同样也已经禁用,修改/etc/sysctl.d/k8s.conf添加下面一行,docker自动化安装部分参考本博客
```
swapoff -a
vm.swappiness=0
sysctl -p /etc/sysctl.d/k8s.conf
https://currylinux.github.io/docker%E5%92%8C%E5%AE%83%E5%85%84%E5%BC%9Fdockerer_compose/
```
###### cgroup 驱动以及配置Docker镜像,和指定/data/docker目录为Docker Root Dir,启动 Docker并设置开机自启
```
由于默认情况下kubelet使用的cgroupdriver是systemd,所以需要保持docker和kubelet的 cgroupdriver一致,我们这里修改docker的cgroupdriver=systemd.如果不修改docker则需要修改kubelet的启动配置,需要保证两者一致.

mkdir -p /etc/docker
cat /etc/docker/daemon.json 
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors" : [
    "https://mirror.gcr.io",                 #国外使用此仓库
    "https://ot2k4d59.mirror.aliyuncs.com/"  #国内使用此仓库
  ],
  "graph": "/data/docker"
}

systemctl start docker
systemctl enable docker
```
###### 继续来安装 Kubeadm,通过指定yum源的方式来进行安装.并且推荐国内外两种源的方式
```
国外yum源:
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
------------------------------------------------------------------------
国内yum源:
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```
###### 然后安装 kubeadm、kubelet、kubectl,查看版本是否正确,并将kubelet设置成开机启动
```
--disableexcludes 禁掉除了kubernetes之外的别的仓库
yum install -y kubelet-1.16.2 kubeadm-1.16.2 kubectl-1.16.2 --disableexcludes=kubernetes
kubeadm version
systemctl enable --now kubelet
```

#### No.2 kubeadm初始化相关步骤

###### 初始化集群,在master节点配置kubeadm初始化文件,可以通过如下命令导出默认的初始化配置,并根据需求修改配置,flannel 网络插件需要将networking.podSubnet设为10.244.0.0/16
```
 kubeadm config print init-defaults > kubeadm.yaml
 
 cat kubeadm.yaml 
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.8.8.8       #apiserver节点内网IP
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: kubernetes-master          #默认读取当前master节点的hostname
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io                               #默认为google镜像仓库
imageRepository: registry.aliyuncs.com/google_containers  #国内修改成阿里镜像源
kind: ClusterConfiguration
kubernetesVersion: v1.16.0
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16         #Pod网段,flannel插件需要使用这个网段    
  serviceSubnet: 10.96.0.0/12
scheduler: {}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs                                                #kube-proxy模式
```
###### 上面的资源清单的文档较杂,要想完整了解上面的资源对象对应的属性,可查看对应godoc文档: https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2

###### 使用上面的配置文件进行初始化,并拷贝kubeconfig文件
```
kubeadm init --config kubeadm.yaml
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
[init] Using Kubernetes version: v1.16.2
[preflight] Running pre-flight checks ........
mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
........... 

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
###### 此处我是单机k8s部署,如果是集群的话,需要添加对应的node节点
```
 kubeadm join 10.8.8.8:6443 --token abcdef.0123456789abcdef \
>     --discovery-token-ca-cert-hash sha256:a292e66049e45264f848186d2fa3582dc360f3b5006cc160f137b5d436e078c2
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.16" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```
###### join命令,如果忘记了上面的 join 命令可以使用命令kubeadm token create --print-join-command 重新获取.

###### 执行成功后运行get nodes命令查看,是NotReady状态,是因为还没有安装网络插件,下面安装网络插件.以及多网卡配置相关设置
```
kubectl get nodes
插件文档:https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
wget https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

搜索到名为kube-flannel-ds-amd64的DaemonSet,在kube-flannel容器下面
vi kube-flannel.yml
......
containers:
- name: kube-flannel
  image: quay.io/coreos/flannel:v0.11.0-amd64
  command:
  - /opt/bin/flanneld
  args:
  - --ip-masq
  - --kube-subnet-mgr
  - --iface=eth0  # 如果是多网卡的话，指定内网网卡的名称
......
kubectl apply -f kube-flannel.yml  #安装flannel网络插件
```

###### 间隔一会查看Pod运行状态,并且查看node状态,并且单节点务必去掉master不允许调度的设置
```
kubectl get pods -n kube-system
NAME                                        READY   STATUS    RESTARTS   AGE
coredns-5644d7b6d9-gmq7s                    1/1     Running   0          129m
coredns-5644d7b6d9-slqc7                    1/1     Running   0          129m
etcd-kubernetes-master                      1/1     Running   0          128m
kube-apiserver-kubernetes-master            1/1     Running   0          128m
kube-controller-manager-kubernetes-master   1/1     Running   0          128m
kube-flannel-ds-amd64-7vk94                 1/1     Running   0          125m
kube-proxy-fsf7k                            1/1     Running   0          129m
kube-scheduler-kubernetes-master            1/1     Running   0          128m

kubectl get nodes
NAME                STATUS   ROLES    AGE    VERSION
kubernetes-master   Ready    master   130m   v1.16.2

kubectl taint nodes --all node-role.kubernetes.io/master-  #去掉master不能调度的操作.
```

#### No.3 基于单机版k8s基础之上,部署Jenkins

###### 部署jenkins
```
创建一个Deployment部署jenkins,保留1个副本.使用镜像jenkins/jenkins:lts,开放端口30080,
开发slave通信端口30081.volume以hostPath方式挂载到了容器中JENKINS_HOME
为方便后期管理,单独创建目录如下:/data/k8s-yaml/jenkins
pwd
/data/k8s-yaml/jenkins

cat deployment.yaml 
---
kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    k8s-app: jenkins
  name: jenkins
  namespace: devops
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: jenkins
  template:
    metadata:
      labels:
        k8s-app: jenkins
      namespace: devops
      name: jenkins
    spec:
      containers:
        - name: jenkins
          image: jenkins/jenkins:lts
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 30080
              name: web
              protocol: TCP
            - containerPort: 30081
              name: agent
              protocol: TCP
          resources:
            limits:
              cpu: 1000m
              memory: 2Gi
            requests:
              cpu: 500m
              memory: 1024Mi
          livenessProbe:
            httpGet:
              path: /login
              port: 30080
            initialDelaySeconds: 60
            timeoutSeconds: 5
            failureThreshold: 12
          readinessProbe:
            httpGet:
              path: /login
              port: 30080
            initialDelaySeconds: 60
            timeoutSeconds: 5
            failureThreshold: 12
          volumeMounts:
            - name: jenkins-home
              mountPath: /var/lib/jenkins
          env:
            - name: JENKINS_HOME
              value: /var/lib/jenkins
            - name: JENKINS_OPTS 
              value: --httpPort=30080
            - name: JENKINS_SLAVE_AGENT_PORT
              value: "30081"
      volumes:
        - name: jenkins-home
          hostPath: 
            path: /data/devops/jenkins
            type: Directory
      serviceAccountName: jenkins
```

###### 创建一个service,使用nodePort方式暴露端口
```
cat service.yaml 
---
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: jenkins
  name: jenkins
  namespace: devops
spec:
  type: NodePort
  ports:
    - name: web
      port: 30080
      targetPort: 30080
      nodePort: 30080
    - name: slave
      port: 30081
      targetPort: 30081
      nodePort: 30081
  selector:
    k8s-app: jenkins
```
###### 创建RBAC,授权
```
cat rbac.yaml 
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: jenkins
  name: jenkins
  namespace: devops
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
 name: jenkins
 namespace: devops
rules:
 - apiGroups: [""]
   resources: ["pods","configmaps","namespaces"]
   verbs: ["create","delete","get","list","patch","update","watch"]
 - apiGroups: [""]
   resources: ["pods/exec"]
   verbs: ["create","delete","get","list","patch","update","watch"]
 - apiGroups: [""]
   resources: ["pods/log"]
   verbs: ["get","list","watch"]
 - apiGroups: [""]
   resources: ["secrets"]
   verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
 name: jenkins
 namespace: devops
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: Role
 name: jenkins
subjects:
 - kind: ServiceAccount
   name: jenkins
   namespace: devops
```

###### 创建namespace,名称空间,并且做关键的授权,否则会失败
```
cat devops-ns.yaml 
---
apiVersion: v1
kind: Namespace
metadata:
  name: devops
  
chown 1000.1000 /data/devops/ -R    
#挂载到宿主机的目录,修改权限为1000,k8s务必加此步骤,否则无法正常启动.
由于我们这里使用的镜像内部运行的用户id=1000
```

###### 最后执行命令,创建当前目录下所有yaml清单,并且解锁Jenkins后,完成插件安装等步骤
```
kubectl apply -f .         #要先创建出namespace,否则就要执行2次命令
cat /data/devops/jenkins/secrets/initialAdminPassword  #拿到jenkins密码解锁

[root@kubernetes-master jenkins]# kubectl get pods -n devops
NAME                      READY   STATUS    RESTARTS   AGE
jenkins-6774fc995-pmg9x   1/1     Running   0          153m
```
![图片说明](/img/k8s-jenkins/解锁jenkins.png)
![图片说明](/img/k8s-jenkins/安装插件jenkins.png)
![图片说明](/img/k8s-jenkins/默认页面jenkins.png)




