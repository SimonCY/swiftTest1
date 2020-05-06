//
//  SoundTool.swift
//  swiftTest1
//
//  Created by Chenyan on 2020/4/12.
//  Copyright © 2020 Chenyan. All rights reserved.
//

import UIKit

class SoundTool: NSObject {
 
    class ImageTool: NSObject {
        
        
    }

    let name = "张三"

    //写单例时，记得屏蔽调外部的init方法调用，以避免其他途径创建
    private override init() { }

    //方式1：静态常量 swift 中 static 修饰 func，等价于 class final ，表示禁止被重写的类函数
    //oc中 static变量 分为全局static变量和局部static变量，而 swift 中没有局部 static变量 的概念（不允许在函数内部声明static变量，但是可以在结构体内部声明），且 static 既可修饰计算型属性也可以修饰存储型属性
    static let shared = SoundTool()

    /* 下面的代码等效于上面，这种方法其实就是懒加载的内部实现
    static let shared : SoundTool = {

        return SoundTool()
     }()
     */

    /*
    //方式1的变种写法
    static var shared: SoundTool {

        struct Static {

            static let sharedInstance = SoundTool()
        }

        return Static.sharedInstance;
    }
     */

    //方式2：结构体静态变量（或者private变量） + class属性getter + 加锁
    /*
    class var shared: SoundTool {

        struct Singleton {

            static var instance : SoundTool?
        }

        DispatchQueue.once(NSUUID().uuidString) {

            print("SoundTool init")
            Singleton.instance = SoundTool.init()
        }

        return Singleton.instance!
    }
     */

    //方式3：结构体j静态变量(或者private变量) + class方法 + 加锁
    /*
    class func shared() -> SoundTool {

        struct Singleton {

            static var instance : SoundTool?
        }

        DispatchQueue.once(NSUUID().uuidString) {

            print("SoundTool init")
            Singleton.instance = SoundTool.init()
        }

        return Singleton.instance!
    }
     */
    private var instance0 : SoundTool?

    static func play() {

        print("play")
    }
}

/**
 1、private
 private访问级别所修饰的属性或者方法只能在当前类里访问。

 2、fileprivate
 fileprivate访问级别所修饰的属性或者方法在当前的Swift源文件里可以访问，类似oc中的 全局static变量。

 3、internal（默认访问级别，internal修饰符可写可不写）
 internal访问级别所修饰的属性或方法在源代码所在的整个模块都可以访问。
 如果是框架或者库代码，则在整个框架内部都可以访问，框架由外部代码所引用时，则不可以访问。
 如果是App代码，也是在整个App代码，也是在整个App内部可以访问。

 4、public
 可以被任何人访问。但其他module中不可以被override和继承，而在module内可以被override和继承。

 5，open
 可以被任何人使用，包括override和继承。
 */
fileprivate var instance1 : SoundTool?



/**
    swift 中的 dispatch_once 被弃用了，可以如下 extension 实现
    extension中只能扩展计算属性，不能拓展存储性属性
    extension中可以向类添加新的便利构造器，但是它们不能向类添加新的指定构造器或析构器
 */
public extension DispatchQueue {

    private static var onceToken = [String]()
    
    class func once(_ token: String, _ block: () -> Void) {

        objc_sync_enter(self)

        //swift 中 defer 类似oc中的try-catch-finally的finally，此处在once函数中代码最后执行完毕会执行defer中代码，常用作回收或清理工作
        defer {

            objc_sync_exit(self)
        }

        if onceToken.contains(token) {

            return
        }

        onceToken.append(token)
        block()
    }
}


