# Hugo你的专属Blog



##### 第一章 简单说明
```
首先简单说明下,搭建过程容易,重点是主题的选择,下面也会附上我使用的主题地址.
有一点Linux基础的话,相对操作要容易一些.没有相关基础的,请认真看下搭建视频.
搭建的过程可能会遇到不少问题,希望不要放弃这个学习的过程.
```
---

##### 第二章 搭建视频连接
```
亲测可行的B站视频连接:
https://www.bilibili.com/video/BV1Yb411a7ty/?spm_id_from=333.788.videocard.0
只要正常按照此视频步骤搭建都可以轻松成功,国内的朋友可以通过码云(gitee.com)的方式也尝试下.
```
---

##### 第三章 初始化hugo到github的简单步骤:
```
初始化命令:
hugo --theme=LoveIt --baseUrl="https://currylinux.github.io/" --buildDrafts
进入到此目录下: C:\USER\XXblog\public
git init
git commit -m "Hugo第一次提交博客"
git remote add origin https://github.com/currylinux/currylinux.github.io.git
git push -u origin master

更新文章或其它内容到Github:
首先用Typora或者VScode打开要编辑的博客文章,修改完之后并保存.
使用本地预览命令: hugo server -D 进行查看本地是否变更,并将draft里的true改为false
继续在当前/目录下操作,提交git本地仓库: git add . && git commit -m "add new post :xxx"
运行hugo将修改更新到public目录: hugo
进入public目录,git一条龙(本地提交+发布到GitHub Pages上):
cd public
git add .
git commit -m "xx**xx"
git push

最后访问自己的博客地址,并且验证效果!
```
---


##### 相关参考文献
```
博客模板使用地址:     https://github.com/dillonzq/LoveIt/
参考搭建视频博主博客:  https://www.codesheep.cn
LoveIt使用手册地址:  https://hugoloveit.com/zh-cn/posts/
Hugo中文文档:        https://www.gohugo.org/
Hugo英文官方文档:    https://gohugo.io/documentation/ 
写文章同步更新GitHub: http://xmasuhai.xyz/post/hugo/hugo%E5%85%A5%E9%97%A84%E5%86%99%E6%96%87%E7%AB%A0%E5%90%8C%E6%AD%A5%E6%9B%B4%E6%96%B0github_%E5%B8%B8%E7%94%A8%E6%93%8D%E4%BD%9C%E6%B5%81%E7%A8%8B/
```
---


