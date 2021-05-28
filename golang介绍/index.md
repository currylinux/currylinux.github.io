# Golang介绍


#### 1. 初识GO语言
###### Go是一门开放源码的编程语言,可容易的构建简单,可靠和高效的软件
###### ⭐ 开发者使用编程语言的三大分类(执行速度、简易程度、开发难度):
	执行速度快、编译速度慢(编译型): C,C++
	执行速度较慢、编译速度快(解释型): JAVA,.NET
	执行速度慢、开发难度小(动态脚本): Python,PHP

###### Go语言在3个条件做了平衡: 易于开发、快速编译、高效执行

#### 特性
- 静态类型并具有丰富的内置类型
- 函数多返回值
- 错误处理机制
- 语言层并发
- 面向对象: 使用类型、组合、接口来实现面向对象思想
- 反射
- CGO: 用于调用C语言实现的模块
- 自动垃圾回收
- 静态编译
- 交叉编译
- 交易部署
- 基于BSD协议完全开放

#### 落地场景
###### ⭐ Go语言主要用于服务端开发,其定位是开发大型软件,长用于:
- 服务器编程: 日志处理、虚拟机处理、文件系统、分布式系统等
- 网络编程: Web应用、API应用、下载应用等
- 内存数据库
- 云平台
- 机器学习
- 区块链
###### ⭐使用Go开发的项目:
- Go
- Docker
- Kubernetes
- Prometheus
- ............ 

#### 常用的go的学习网站:
- https://github.com/golang/go/wiki/Projects
- https://godoc.org/
- https://gowalker.org/

#### 2. 环境安装
###### ⭐下载地址:
- https://golang.org/dl/
- https://golang.google.cn/dl/
- https://golang.org/dl/#unstable


![图片说明](/img/chushi-golang/安装windows包-golang.png)
![图片说明](/img/chushi-golang/安装windows包-2-golang.png)
![图片说明](/img/chushi-golang/安装windows包-3-golang.png)

###### 还需要单独装git工具以及VSCode编辑器,根据自己的操作系统进行安装.

#### 3.  vscode-go相关插件,不是必选,但是有一定的便利性
###### 首先需要到GOPATH路径下创建目录,拉取GitHub上的相关代码进行部署,因为国内访问不到golang.org地址. 
```
https://github.com/golang?q=mirror&type=&language=  #插件的github地址
git clone https://github.com/golang/net.git
git clone https://github.com/golang/text.git
git clone https://github.com/golang/sys.git
git clone https://github.com/golang/sync.git
git clone https://github.com/golang/crypto.git
git clone https://github.com/golang/tools.git
git clone https://github.com/golang/lint.git
```
![图片说明](/img/chushi-golang/安装插件-1-golang.png)

###### 此时安装其它插件,在国内可直接访问到的,下载完会自动在GOPATH路径下生成github.com目录
```
go get -d github.com/ramya-rao-a/go-outline
go get -d github.com/acroca/go-symbols
go get -d github.com/mdempsky/gocode
go get -d github.com/rogpeppe/godef
go get -d github.com/zmb3/gogetdoc
go get -d github.com/fatih/gomodifytags
go get -d sourcegraph.com/sqs/goreturns
go get -d github.com/cweill/gotests/...
go get -d github.com/josharian/impl
go get -d github.com/haya14busa/goplay/cmd/goplay
go get -d github.com/uudashr/gopkgs/cmd/gopkgs
go get -d github.com/davidrjenni/reftools/cmd/fillstruct
go get -d github.com/alecthomas/gometalinter
go get -d  github.com/go-delve/delve/cmd/dlv
```

###### 下载完之后,去掉-d的参数,开始安装下载好的插件,会在电脑上生成二进制文件
```
go get  github.com/ramya-rao-a/go-outline
go get  github.com/acroca/go-symbols
go get  github.com/mdempsky/gocode
go get  github.com/rogpeppe/godef
go get  github.com/zmb3/gogetdoc
go get  github.com/fatih/gomodifytags
go get  sourcegraph.com/sqs/goreturns
go get  github.com/cweill/gotests/...
go get  github.com/josharian/impl
go get  github.com/haya14busa/goplay/cmd/goplay
go get  github.com/uudashr/gopkgs/cmd/gopkgs
go get  github.com/davidrjenni/reftools/cmd/fillstruct
go get  github.com/alecthomas/gometalinter
go get  github.com/go-delve/delve/cmd/dlv

gometalinter --install  #安装完之后最后执行此命令安装其它工具
```
![图片说明](/img/chushi-golang/安装插件-2-golang.png)

#### 4. 创建目录,通过Go编写Hello World

###### 代码内容如下
```
package main

import "fmt"

func main() {
	fmt.Println("Hello World!!!")
}
```
![图片说明](/img/chushi-golang/代码练习-helloworld-1-golang.png)
![图片说明](/img/chushi-golang/代码练习-helloworld-2-golang.png)

###### 对代码进行编译,到go代码的所在目录下操作
```
pwd
C:\htgolang\chapter01
ls
go build main.go
ls
main.exe*  main.go
```
![图片说明](/img/chushi-golang/代码练习-helloworld-3-golang.png)

###### 编译完之后的二进制程序可以直接运行,另外编译的时候不加main.go的话,会编译整个文件夹下的所有文件,多个文件的话,只能有一个是main函数.补充构建时候的可选参数.
```
main.exe
Hello World!!!

go build
ls
chapter01.exe*  main.exe*  main.go
chapter01.exe
Hello World!!!

go build -x main.go  #记录整个编译过程.
go build -x -o helloworld.exe main.go  #自定义名称-o参数
go run main.go  #直接运行源码,会创建临时目录,进行编译并且运行
```

###### 最后通过下图了解下go的程序结构.
![图片说明](/img/chushi-golang/代码练习-helloworld-5-golang.png)


