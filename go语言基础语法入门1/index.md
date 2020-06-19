# Go语言基础语法入门(1)


#### 1. 基础语法介绍(1)

###### 首先演示操作在go语言中注释的用法,注释在编译的时候不会现实,因为都是给人看的.所以注释对编译是没有影响的,可以直接在vscode的控制台进行编译等操作.
```
// 这里是main包
package main

import "fmt"

/*
	这里是main函数
	是程序的启动的入口
*/
func main() 
	// 我这里是输出Hello Wirld到控制台
	fmt.Println("Hello World!!!")
}


PS C:\htgolang\chapter01> go build main.go   
PS C:\htgolang\chapter01> .\main.exe
Hello World!!!
PS C:\htgolang\chapter01>
```

#### 基本组成元素1-标识符
###### ⭐标识符是编程时所使用的名字,用于给变量、常量、函数、类型、 接口、包名等进行命名,以建立名称和使用之间的关系.
###### ⭐Go语言标识符的命令规则:
- 1. 只能由非字母(Unicode)、数字、下划线组成
- 2. 只能以字母或下划线开
- 3. 不能Go语言关键字
- 4. 避免使用Go语言预定义标识符
- 5. 建议使用驼峰式
- 6. 标识符号区分大小写 

#### 基本组成元素2-关键字
###### ⭐关键字用于特性的语法结构
###### ⭐Go语言定义25关键字:
- 声明: import、package
- 实体声明和定义:  chan、const、func、interface、map、struct、type、var
- 流程控制: break、case、continue、default、defer、else、fallthrough、for、go、goto、if、range、return、select、switch

#### 基本组成元素3-字面量
###### ⭐字面量是值得表示方法、常用与对变量/变量进行初始化/
###### ⭐主要分为:
- 标识基础数据类型值得字面量,例如: 0, 1.1, true, 3 + 4i, 'a', "我爱中国"
- 构造自定义的复合数据类型的类型字面量,例如: type Interval int
- 用于表示符合数据类型值的复合字面量,用来构造array、slice、map、struct的值,例如:{1,2,3}

#### 基本组成元素4-操作符
###### ⭐算术运算符:  +、-、*、/、%、++、--
###### ⭐关系运算符:  >、>=、<、<=、==、!=
###### ⭐逻辑运算符:  &&、||、!
###### ⭐位运算符: &、|、^、<<、>>、&^
###### ⭐赋值运算符: =、+=、-=、*=、/=、%=、&=、|=、^=、<<=、>>=
###### ⭐其他运算符: &(单目)、*(单目)、.(点)、-(单目)、...、<-
#### 分隔符
###### ⭐小括号(), 中括号[], 大括号{}, 分号;, 逗号,

#### 2. 基础知识点
###### 基础知识点(一) -- 声明
###### 声明语句用于定义程序的各种实体对象,主要有:
- 声明变量的var
- 声明常量的const
- 声明函数的func
- 声明类型的type

###### 基础知识点(一) -- 变量
###### 变量是指对一块存储空间定义名称,通过名称对存储空间的内容进行访问或修改,使用var进行变量声明,常用的语法为:
###### 1. var 变量名 变量类型 = 值      (定义变量并进行初始化,例如: var name string = "silence")
###### 2. var 变量名 变量类型      (定义变量使用零值进行初始化.例如: var age int)
###### 3. var 变量名 = 值      (定义变量,变量类型通过值类型进行推导,例如:var isBoy = true)
###### 4. var变量名1,变量名2, ...,变量名n 变量类型      (定义多个相同类型的变量并使用零值进行初始化,例如: var prefix, suffix string)
###### 5. var变量名1,变量名2, ..., 变量名n 变量类型 = 值1,值2, ..., 值n      (定义多个相同类型的变量并使用对应的值进行初始化,例如: var prev, next int = 3,4)
###### 6. var变量名1,变量名2, ..., 变量名n = 值1,值2, ..., 值n      (定义多个变量并使用对应的值进行初始化,变量的类型使用值类型进行推导,类型可不相同,例如: var name, age = "silence", 30)

#### 3.变量语法
###### 变量语法演示1
```
package main

import "fmt"

func main() {
	// 定义一个string类型的变量me
	/*
		变量名需要满足标识符命名规则
		1. 必须由非空的unicode字符串组成、数字、_
		2. 不能以数字开头
		3. 不能为go的关键字(25个)

		4. 避免和go预定义标识符冲突, true/false/nul/bool/string
		5. 驼峰
		6. 标识符区分大小写
	*/
	var me string

	me = "kk"
	fmt.Println(me)
}
```
###### 写完之后,可以通过vscode的终端运行操作 go run vars.go,另外须知的是在函数内定义的变量,必须是要使用的.

###### 变量语法演示2
```
#1
package main

import "fmt"

var version string = "1.0"

func main() {
	// 定义一个string类型的变量me
	/*
		变量名需要满足标识符命名规则
		1. 必须由非空的unicode字符串组成、数字、_
		2. 不能以数字开头
		3. 不能为go的关键字(25个)

		4. 避免和go预定义标识符冲突, true/false/nul/bool/string
		5. 驼峰
		6. 标识符区分大小写
	*/
	var me string

	me = "kk"
	fmt.Println(me)
}

#2
package main

import "fmt"

var version string = "1.0"

func main() {
	// 定义一个string类型的变量me
	/*
		变量名需要满足标识符命名规则
		1. 必须由非空的unicode字符串组成、数字、_
		2. 不能以数字开头
		3. 不能为go的关键字(25个)

		4. 避免和go预定义标识符冲突, true/false/nul/bool/string
		5. 驼峰
		6. 标识符区分大小写
	*/
	var me string

	me = "kk"
	fmt.Println(me)
	fmt.Println(version)
}

#3-赋值不使用,打印出来是为空的,每个类型的为空值都是不一样的
package main

import "fmt"

var version string = "1.0"

func main() {
	// 定义一个string类型的变量me
	/*
		变量名需要满足标识符命名规则
		1. 必须由非空的unicode字符串组成、数字、_
		2. 不能以数字开头
		3. 不能为go的关键字(25个)

		4. 避免和go预定义标识符冲突, true/false/nul/bool/string
		5. 驼峰
		6. 标识符区分大小写
	*/
	var me string
	fmt.Println(me)

	me = "kk"
	fmt.Println(me)
	fmt.Println(version)

	var name, user string
	fmt.Println(name, user)
}

#4-定义多个值,并且赋值到多个值
package main

import "fmt"

var version string = "1.0"

func main() {
	// 定义一个string类型的变量me
	/*
		变量名需要满足标识符命名规则
		1. 必须由非空的unicode字符串组成、数字、_
		2. 不能以数字开头
		3. 不能为go的关键字(25个)

		4. 避免和go预定义标识符冲突, true/false/nul/bool/string
		5. 驼峰
		6. 标识符区分大小写
	*/
	var me string
	fmt.Println(me)

	me = "kk"
	fmt.Println(me)
	fmt.Println(version)

	var name, user string = "kk", "woniu"
	fmt.Println(name, user)
}

#5-定义多个变量,并且类型是不相同的,不赋值的话打印默认会打印出两个0来.
package main

import "fmt"

var version string = "1.0"

func main() {
	// 定义一个string类型的变量me
	/*
		变量名需要满足标识符命名规则
		1. 必须由非空的unicode字符串组成、数字、_
		2. 不能以数字开头
		3. 不能为go的关键字(25个)

		4. 避免和go预定义标识符冲突, true/false/nul/bool/string
		5. 驼峰
		6. 标识符区分大小写
	*/
	var me string
	fmt.Println(me)

	me = "kk"
	fmt.Println(me)
	fmt.Println(version)

	var name, user string = "kk", "woniu"
	fmt.Println(name, user)

	var (
		age    int
		height float64
	)

	fmt.Println(age, height)
}

#6-定义多个变量并且赋值
package main

import "fmt"

var version string = "1.0"

func main() {
	// 定义一个string类型的变量me
	/*
		变量名需要满足标识符命名规则
		1. 必须由非空的unicode字符串组成、数字、_
		2. 不能以数字开头
		3. 不能为go的关键字(25个)

		4. 避免和go预定义标识符冲突, true/false/nul/bool/string
		5. 驼峰
		6. 标识符区分大小写
	*/
	var me string
	fmt.Println(me)

	me = "kk"
	fmt.Println(me)
	fmt.Println(version)

	var name, user string = "kk", "woniu"
	fmt.Println(name, user)

	var (
		age    int     = 31
		height float64 = 1.68
	)

	fmt.Println(age, height)
}

#7-定义多个变量不定义类型,通过设定的值推导类型,两种写法 
package main

import "fmt"

var version string = "1.0"

func main() {
	// 定义一个string类型的变量me
	/*
		变量名需要满足标识符命名规则
		1. 必须由非空的unicode字符串组成、数字、_
		2. 不能以数字开头
		3. 不能为go的关键字(25个)

		4. 避免和go预定义标识符冲突, true/false/nul/bool/string
		5. 驼峰
		6. 标识符区分大小写
	*/
	var me string
	fmt.Println(me)

	me = "kk"
	fmt.Println(me)
	fmt.Println(version)

	var name, user string = "kk", "woniu"
	fmt.Println(name, user)

	var (
		age    int     = 31
		height float64 = 1.68
	)

	fmt.Println(age, height)

	var (
		s = "kk"
		a = 31
	)

	fmt.Println(s, a)

	var ss, aa = "kk", 32
	fmt.Println(ss, aa)

}
```

###### 变量语法演示2-2
```
#8-省略var定义变量的方式,叫做简短声明,简短声明必须在函数内使用,不能在函数外.
package main

import "fmt"

var version string = "1.0"

func main() {
	// 定义一个string类型的变量me
	/*
		变量名需要满足标识符命名规则
		1. 必须由非空的unicode字符串组成、数字、_
		2. 不能以数字开头
		3. 不能为go的关键字(25个)

		4. 避免和go预定义标识符冲突, true/false/nul/bool/string
		5. 驼峰
		6. 标识符区分大小写
	*/
	var me string
	fmt.Println(me)

	me = "kk"
	fmt.Println(me)
	fmt.Println(version)

	var name, user string = "kk", "woniu"
	fmt.Println(name, user)

	var (
		age    int     = 31
		height float64 = 1.68
	)

	fmt.Println(age, height)

	var (
		s = "kk"
		a = 31
	)

	fmt.Println(s, a)

	var ss, aa = "kk", 32
	fmt.Println(ss, aa)

	// 这是一个简短声明,只能在函数内部使用
	isBoy := true
	fmt.Println(isBoy)

}

#9-定义完之后,同样也可以再赋值多个值
package main

import "fmt"

var version string = "1.0"

func main() {
	// 定义一个string类型的变量me
	/*
		变量名需要满足标识符命名规则
		1. 必须由非空的unicode字符串组成、数字、_
		2. 不能以数字开头
		3. 不能为go的关键字(25个)

		4. 避免和go预定义标识符冲突, true/false/nul/bool/string
		5. 驼峰
		6. 标识符区分大小写
	*/
	var me string
	fmt.Println(me)

	me = "kk"
	fmt.Println(me)
	fmt.Println(version)

	var name, user string = "kk", "woniu"
	fmt.Println(name, user)

	var (
		age    int     = 31
		height float64 = 1.68
	)

	fmt.Println(age, height)

	var (
		s = "kk"
		a = 31
	)

	fmt.Println(s, a)

	var ss, aa = "kk", 32
	fmt.Println(ss, aa)

	// 这是一个简短声明,只能在函数内部使用
	isBoy := true
	fmt.Println(isBoy)

	ss, aa, isBoy = "silence", 33, false
	fmt.Println(ss, aa, isBoy)

}

#10-交换两个变量的值,和python的多变量解包有些类似
package main

import "fmt"

var version string = "1.0"

func main() {
	// 定义一个string类型的变量me
	/*
		变量名需要满足标识符命名规则
		1. 必须由非空的unicode字符串组成、数字、_
		2. 不能以数字开头
		3. 不能为go的关键字(25个)

		4. 避免和go预定义标识符冲突, true/false/nul/bool/string
		5. 驼峰
		6. 标识符区分大小写
	*/
	var me string
	fmt.Println(me)

	me = "kk"
	fmt.Println(me)
	fmt.Println(version)

	var name, user string = "kk", "woniu"
	fmt.Println(name, user)

	var (
		age    int     = 31
		height float64 = 1.68
	)

	fmt.Println(age, height)

	var (
		s = "kk"
		a = 31
	)

	fmt.Println(s, a)

	var ss, aa = "kk", 32
	fmt.Println(ss, aa)

	// 这是一个简短声明,只能在函数内部使用
	isBoy := true
	fmt.Println(isBoy)

	ss, aa, isBoy = "silence", 33, false
	fmt.Println(ss, aa, isBoy)

	fmt.Println(s, ss)
	s, ss = ss, s
	fmt.Println(s, ss)

}

```

#### 4.常量演示
###### 常量语法演示1
```
#1
package main

import "fmt"

func main() {
	const NAME string = "kk"

	fmt.Println(NAME)
}

#2-常量const一般后面名字都是全部大写的,不希望更改.多类型多方式常量定义如下:
package main

import "fmt"

func main() {
	const NAME string = "kk"

	// 省略类型
	const PI = "3.1415962"
	//定义多个常量(类型相同)
	const C1, C2 int = 1, 2
	//定义多个常量(类型不相同)
	const (
		C3 string = "silence"
		C4 int    = 1
	)
	//定义多个常量,省略类型
	const C5, C6 = "silence", 1

	fmt.Println(NAME)
	fmt.Println(PI)
	fmt.Println(C1, C2)
	fmt.Println(C3, C4)
	fmt.Println(C5, C6)

}

#3-常量如果类型和值一样,可以通过下面的方式省略实现
package main

import "fmt"

func main() {
	const NAME string = "kk"

	// 省略类型
	const PI = "3.1415962"
	//定义多个常量(类型相同)
	const C1, C2 int = 1, 2
	//定义多个常量(类型不相同)
	const (
		C3 string = "silence"
		C4 int    = 1
	)
	//定义多个常量,省略类型
	const C5, C6 = "silence", 1

	fmt.Println(NAME)
	fmt.Println(PI)
	fmt.Println(C1, C2)
	fmt.Println(C3, C4)
	fmt.Println(C5, C6)

	const (
		C7 int = 1
		C8
		C9
	)
	fmt.Println(C7, C8, C9)

}

#3-v2 常量如果类型和值一样,可以通过下面的方式省略实现
package main

import "fmt"

func main() {
	const NAME string = "kk"

	// 省略类型
	const PI = "3.1415962"
	//定义多个常量(类型相同)
	const C1, C2 int = 1, 2
	//定义多个常量(类型不相同)
	const (
		C3 string = "silence"
		C4 int    = 1
	)
	//定义多个常量,省略类型
	const C5, C6 = "silence", 1

	fmt.Println(NAME)
	fmt.Println(PI)
	fmt.Println(C1, C2)
	fmt.Println(C3, C4)
	fmt.Println(C5, C6)

	const (
		C7 int = 1
		C8
		C9
		C10 float64 = 3.14
		C11
		C12
		C13 string = "kk"
	)
	fmt.Println(C7, C8, C9)
	fmt.Println(C11, C12, C13)

}


#4-常量枚举的操作方法,只在括const的括号内生效,出括号重新计算,从0开始计算.
package main

import "fmt"

func main() {
	const NAME string = "kk"

	// 省略类型
	const PI = "3.1415962"
	//定义多个常量(类型相同)
	const C1, C2 int = 1, 2
	//定义多个常量(类型不相同)
	const (
		C3 string = "silence"
		C4 int    = 1
	)
	//定义多个常量,省略类型
	const C5, C6 = "silence", 1

	fmt.Println(NAME)
	fmt.Println(PI)
	fmt.Println(C1, C2)
	fmt.Println(C3, C4)
	fmt.Println(C5, C6)

	const (
		C7 int = 1
		C8
		C9
		C10 float64 = 3.14
		C11
		C12
		C13 string = "kk"
	)
	fmt.Println(C7, C8, C9)
	fmt.Println(C11, C12, C13)

	//枚举,const+iota
	const (
		E1 int = iota
		E2
		E3
	)
	fmt.Println(E1, E2, E3)

}

```

#### 5.作用域演示
###### 作用域语法演示1
```
#1-引用作用域外部定义的变量,下级语句块可以使用上级语句块的变量
package main

import "fmt"

func main() {
	// 作用域: 定义标识符可以使用的范围
	// 在Go中用{}来定义作用域的范围
	//

	outer := 1
	{
		fmt.Println(outer)
	}
	
#2-语句块父子引用的关系说明:
package main

import "fmt"

func main() {
	// 作用域: 定义标识符可以使用的范围
	// 在Go中用{}来定义作用域的范围
	// 使用原则: 子语句块可以使用父语句块中的标识符,父不能使用子的

	outer := 1
	{
		inner := 2
		fmt.Println(outer)
		fmt.Println(inner)
		{
			inner2 := 3
			fmt.Println(outer, inner, inner2)
		}
	}
	//fmt.Println(inner)

}

#3-子父域同时定义变量,并验证效果
package main

import "fmt"

func main() {
	// 作用域: 定义标识符可以使用的范围
	// 在Go中用{}来定义作用域的范围
	// 使用原则: 子语句块可以使用父语句块中的标识符,父不能使用子的

	outer := 1
	{
		inner := 2
		fmt.Println(outer)
		fmt.Println(inner)
		outer := 31
		{
			inner2 := 3
			fmt.Println(outer, inner, inner2)
		}
	}
	//fmt.Println(inner)

}

```

#### 6.Debug调式用法
###### 通常需要多使用Println的方式做输出查看,下面代码介绍Println和Print的区别,以及Printf的用法.
```
package main

import "fmt"

func main() {
	var age = 30
	age = age + 1
	fmt.Println("明年: ", age)
	age = age + 1
	fmt.Println("后年: ", age)

	fmt.Println("打印第一行")
	fmt.Println("打印第2行")
	fmt.Print("打印第一行")
	fmt.Print("打印第2行")
	fmt.Printf("\n%T, %s, %T, %d\n", "KK", "KK", age, age)

}

```



