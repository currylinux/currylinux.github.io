# Kubernetes部署Dashboard--并支持Chrome浏览器


#### 1.  Dashboard前期部署

###### v1.16.2版本的k8s需要安装最新的2.0+ 版本Dashboard
```
pwd
/data/k8s-yaml/dashboard
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta5/aio/deploy/recommended.yaml
修改Service为NodePort类型,并且固定端口.
vim recommended.yaml
......
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 31666  #固定端口为31666,外部访问的.
  selector:
    k8s-app: kubernetes-dashboard
  type: NodePort   #加上type=NodePort变成NodePort类型的服务
  ......  
```

###### 直接创建,新版的Dashboard默认安装在kubernetes-dashboard命名空间
```
kubectl apply -f recommended.yaml
kubectl get pods -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard
NAME                                    READY   STATUS    RESTARTS   AGE
kubernetes-dashboard-6b86b44f87-xhktr   1/1     Running   0          9h
get svc -n kubernetes-dashboard
NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
dashboard-metrics-scraper   ClusterIP   10.96.150.213   <none>        8000/TCP        9h
kubernetes-dashboard        NodePort    10.103.188.75   <none>        443:31666/TCP   9h
```

#### 2.  Dashboard修改并支持chrome浏览器访问

###### 要使用https方式,Chrome正常是不生效,下面修改,使其支持Chrome
```
pwd
/data/k8s-yaml/dashboard
mkdir key && cd key
#生成证书
openssl genrsa -out dashboard.key 2048 
openssl req -new -out dashboard.csr -key dashboard.key -subj '/CN=10.8.8.8'
openssl x509 -req -in dashboard.csr -signkey dashboard.key -out dashboard.crt 
#删除原有的证书secret,提供新老两种命名空间操作.
kubectl delete secret kubernetes-dashboard-certs -n kube-system
kubectl delete secret kubernetes-dashboard-certs -n kubernetes-dashboard
#创建新的证书secret
kubectl create secret generic kubernetes-dashboard-certs --from-file=dashboard.key --from-file=dashboard.crt -n kube-system
#创建新的证书secret
kubectl create secret generic kubernetes-dashboard-certs --from-file=dashboard.key --from-file=dashboard.crt -n kubernetes-dashboard
#查看pod
kubectl get pod -n kube-system
kubectl get pod -n kubernetes-dashboard
#重启pod,记得要重启两个pod.
kubectl delete pod <pod name> -n kube-system
kubectl delete pod <pod name> -n kubernetes-dashboard
kubectl delete pod dashboard-metrics-scraper-xxx -n xx
kubectl delete pod kubernetes-dashboard-xxx -n xxx
#最后验证重启成功
[root@kubernetes-master dashboard]# kubectl get pods -n kubernetes-dashboard
NAME                                         READY   STATUS    RESTARTS   AGE
dashboard-metrics-scraper-76585494d8-wlnrm   1/1     Running   0          9h
kubernetes-dashboard-6b86b44f87-xhktr        1/1     Running   0          9h
```
![图片说明](/img/k8s-dashboard/初次登录-dashboard.png)

#### 3.  创建全局所有权用户

###### 创建一个具有全局所有权限的用户来登录Dashboard: (admin.yaml)
```
pwd
/data/k8s-yaml/dashboard

cat admin.yaml 
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: admin
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: admin
  namespace: kubernetes-dashboard

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kubernetes-dashboard
```

###### 执行创建操作,用base64解码后的字符串作为 token 登录Dashboard,新版本新增了暗黑模式
```
kubectl apply -f admin.yaml
kubectl get secret -n kubernetes-dashboard|grep admin-token
admin-token-p28x5                  kubernetes.io/service-account-token   3      10h
kubectl get secret admin-token-p28x5 -o jsonpath={.data.token} -n kubernetes-dashboard |base64 -d  #会生成一串很长的base64后的字符串
```
![图片说明](/img/k8s-dashboard/token登录-dashboard.png)
![图片说明](/img/k8s-dashboard/登录后-dashboard.png)



