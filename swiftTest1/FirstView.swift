//
//  FirstView.swift
//  swiftTest1
//
//  Created by Chenyan on 2020/4/7.
//  Copyright © 2020 Chenyan. All rights reserved.
//

import UIKit

@objc protocol FirstViewDelegate2  {

    func viewDidTouch()
}


@objc protocol FirstViewDelegate : FirstViewDelegate2  {
    
    func viewDidTouch()
}

class FirstView: UIView {

    //弱引用时代理必须加@objc
    weak var delegate : FirstViewDelegate?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {


        self.delegate?.viewDidTouch()
    }


    /**
     对象的属性就应该是可变的
     允许变量为空时需要设置为可选项，var的默认值是nil
     */
    var color : UIColor

    /**
     构造函数：
        swift中构造函数都是init
        重写父类的函数时需要声明 override， 可以使用super.xxx调用父类的对应方法

     swift中定义了两种构造函数来保证类被正确的初始化（ designated initializers 和 convenience initializers ，方法前不加 convenience 修饰即为 designated ）

        designated：类似OC中的NS_DESIGNATED_INITIALIZER，用来指定某一个或几个初始化方法为该类初始化的必经之路
        convenience：是对类初始化方法的补充，用于为类提供一些快捷的初始化方法，可以不创建这类方法，但如果创建了，就需要遵循原则：call a designated initializer from the    same class
        required：强制子类对构造函数进行重写时，必须某个初始化方法进行重写

     可失败初始化器（Failable Initializers）：即可以返回 nil 的初始化方法， 以 init?() 的形式表示

     对于 Swift 中的构造函数，总结如下：

        没有重写或重载：
            子类如果没有重载或重写 initializer，则默认继承所有父类的 designated initializer 及  convenience initializer；

        有任意重载或重写：
            子类中 designated initializer 必须调用父类中对应的 designated initializer，以保证父类也能完成初始化；
            子类 convenience initializer 必须调用子类自身的其他初始化方法，并在最终必须调用一个 designated initializer，所以子类至少需要有一个 designated initializer；

            只有当子类中重写了父类中的某一 designated initializer 方法时，才可以在子类初始化时使用父类中依赖该 designated initializer 的 convenience initializer 或者该 designated initializer 方法本身；（所以标准写法中子类中应当重写所有父类的 designated initializer 方法）

        required：
            希望子类中必须实现的 designated initializer，可以通过添加 required 关键字强制子类重写其实现；

        属性的使用：
            在构造器完成初始化之前, 不能调用父类和子类中的任何实例方法，也不能读取任何父类中的实例属性的值，但是可以读取子类中的属性；
            designated initializer 中，子类属性使用在 super.init() 之前，父类属性的使用在 super.init()之后；
            convenience initializer 子类和父类属性的使用都在 self.init() 之后；
     */
    override init(frame: CGRect) {

        //子类属性的初始化，要在super.init()之前，因为和父类的初始化并不相关
        color = UIColor.red


        super.init(frame: frame)

        //父类中属性的初始化，要在super.init()之后
        backgroundColor = color
    }
    

    required init?(coder: NSCoder) {

        color = UIColor.red
        super.init(coder: coder)
    }

    /**
     
     析构函数：和OC中的dealloc类似
        1. 没有func；
        2. 不允许重载
     */
    deinit {


    }
}
