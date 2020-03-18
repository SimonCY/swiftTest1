//
//  ViewController.swift
//  swiftTest1
//
//  Created by Chenyan on 2020/2/5.
//  Copyright © 2020 Chenyan. All rights reserved.
//

import UIKit


extension ViewController {

    @objc func cy_viewDidLoad() {
        print(self.description)

        demo7()

        self.cy_viewDidLoad()
    }

    /** runtime */
    public class func loadMethodSwizzing() {

        /*
         swift中方法交换只能在分类中使用，否则会循环调用
         Swift代码中已经没有了Objective-C的运行时消息机制, 在代码编译时即确定了其实际调用的方法. 所以纯粹的Swift类和对象没有办法使用runtime, 更不存在method swizzling.
         为了兼容Objective-C, 凡是继承NSObject的类都会保留其动态性, 依然遵循Objective-C的�运行时消息机制, 因此可以通过runtime获取其属性和方法, 实现method swizzling等功能.
         但是新版swift已经无法再重写load方法，所以需要声明一个只会执行一次的类方法，在程序启动后手动调用来替代load方案
         */

        //动态绑定
        objc_setAssociatedObject(self, &cy_associatedKeys.key0, "value0", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let value0 = objc_getAssociatedObject(self, &cy_associatedKeys.key0)
        print("value0 is", (value0 ?? "nil"))

        //方法拦截
        let originalSelector = #selector(ViewController.viewDidLoad)
        let swizzledSelector = #selector(ViewController.cy_viewDidLoad)

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
        let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        //如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing

        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }

    }

    private struct cy_associatedKeys {

        static var key0  = "cy_key0"
        static var key1  = "cy_key1"

    }
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        demo7()
    }

    /** 常量和变量 */
    func demo0() {

        /*
         let 定义常量  一旦设置数值 不允许修改
         var 定义变量 可以修改
         使用时尽量使用let，必须修改再改为var
         */
        let name = "老王"
        var sex = "男"
        sex = "女"

        print(name + sex)

        /*
         任意两个不同数据类型的常量或变量不允许直接计算，系统不会做任何隐式转换
         */
        let a = 18
        let b = 1.5

        let c = a + Int(b)
        print(a, b, c)

        /*
         定义变量和常量时可以指定类型   变量名: 类型
         */
        let age: Int = 20
        print("age is",age)
    }

    /** 可选项和解包 */
    func demo1() {

        /*
         可选项，在类型后加 ? 来定义
         age可以为nil  也可能是一个证书
         可选项变量不能直接用来计算
         强行解包，变量后加!，如果为nil则程序崩溃
         */
        let age: Int? = 18
        let realAge: Int? = nil

        print(age! + 10, (realAge ?? 18))

        /*
         创建对象时，如果构造函数返回值有'?'，表示不一定能创建出对象，返回的是一个可选项
         */
        let urlStr = "www.baidu.com"
        let url = NSURL(string: urlStr)
        print(url ?? "url is nil")  // 变量 ?? <#defaultValue#> 表示如果变量为nil则给他一个defaultValue
        print(url!)

        /*
         创建对象时，如果构造参数中没有'?'，表示必须要有值，如果为nil，则崩溃
         */
        let request = NSURLRequest(url: url! as URL)
        print(request)
    }

    /** 三目运算 */
    func demo2() {

        var age = 18

        age = 18

        Int(age) > 5 ? print("成人") : print("小孩")

        /*
         一种特殊的三目运算：
         变量 ?? defaultValue 表示如果变量为nil则给他一个defaultValue
         ??的运算优先级低于'+'，所以使用时一定使用()包起来
         */
        let name: String? = nil
        print(name ?? "no" + "name")
        print((name ?? "no") + "name")
    }

    /** if else */
    func demo3() {

        let name : String? = "老王"
        if name != nil {
            
            print("name is " + name!)
        } else {

            print("no name")
        }
    }

    /** if let */
    func demo4() {

        let name : String? = "老王"

        if name != nil {

            print("name is " + name!)
        }

        if let aName = name {

            print("name is " + aName)
        }
    }

    /** guard let */
    func demo5() {

        let name : String? = "老王"

        if name == nil {

            print("no name")
        }

        guard name != nil else {

            print("no name")
            return

        }
    }

    /** switch */
    func demo6() {

        /*
         1. 每个case后必须有至少一行代码
         2. 不需要break,break只用来做代码填充
         3. OC中switch只针对int类型，而swift中的switch可以对任意类型变量进行检测
         4. 多个case之间不加break也不会穿透，判断多个值时用逗号分隔
         5. 某个分支中定义变量时，不需要使用{}来分隔这个变量的作用域
         */
        let type = "11"

        switch type {
        case "9" : print("好的")
        case "10", "11" :
            let name = "老王"
            print(name,"你好")
            print("\(name)你好")
            print(name + "你好")
        case "12" : break
        default : break
        }
    }

    /** 字符串 */
    func demo7() {

        let str = "hello world"

        for c in str {

            print(c)
        }
    }
}

