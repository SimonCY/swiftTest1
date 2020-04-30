//
//  Person.swift
//  swiftTest1
//
//  Created by Chenyan on 2020/4/7.
//  Copyright © 2020 Chenyan. All rights reserved.
//

import UIKit




class Person : NSObject {

    @objc var name : String
    @objc var age : Int
    var sex : String

    init(name : String, age : Int, sex : String) {

        self.name = name
        self.age = age
        self.sex = sex

        print("Person init")
    }

    /**
     重载：
     子类重写父类中的某一方法，但参数表不相同
     */
    convenience init(name : String, block : () throws -> ()  ) {

        //convenience initializer 必须调用自身类中的其他初始化方法，并在最终必须调用一个 designated initializer；
        self.init(name : name, age : 0, sex : "unknown")

    }
    
    /**
     重写：
     子类重写父类中的某一方法，参数表和参数名完全相同
     */
    convenience override init() {
        
        self.init(name : "no name", age : 0, sex : "unknown")
    }

    convenience init(name : String, age : Int) {

        self.init(name : name, age : age, sex : "unknown")

        print("Person init")
    }

    convenience init(dict : [String : Any]) {

        self.init()

        /**
         swift中kvc：
            1. 使用 KVC 时必须在对象已经初始化完毕之后（ self.init() 或者 super.init() 之后）
            2. 使用 KVC 赋值的成员变量必须加 @objc 修饰，否则崩溃
            3. Swift 中 KVC 对 Int 等基本数据类型同样适用
            4. KVC能对当前类和父类和子类中的所有属性赋值
            5. setValuesForKeys() 会遍历调用 setValue(forKey:)
         */
        setValuesForKeys(dict)

//        setValue(18, forKey: "age")
    }

    override func setValue(_ value: Any?, forKey key: String) {

        super.setValue(value, forKey: key)
    }

    //重写此方法后，当对象不存在名为 key 的属性时，会走到这个方法，防止程序crash
    override func setValue(_ value: Any?, forUndefinedKey key: String) {

        print("set undefined var for \(key) : \(value ?? "nil")")
    }
}


class Student : Person {

    //class 修饰的类属性只用是计算型属性，不能为存储型属性
    class var teacher : Person {

        return Person()
    }

    @objc var grade : String?

    //在声明属性的时候默认初始化
    var number : Int = 0

    //返回一个可选项的构造函数
    init?(grade : String) {

        super.init(name: "no name", age: 0, sex: "unknown")

        self.grade = grade

        return nil
    }
    
    //
    override init(name : String, age : Int, sex : String) {

//       try self.run(3)
        print(self.number)

        super.init(name: name, age: age, sex: sex)

        print("Student init")
    }

    //让基本数据类型以以指针方式传递，而不是进行值拷贝，从而在函数内部可以修改外部的该变量
    func run(_ count: inout Int) throws -> Void {


    }

   
}
