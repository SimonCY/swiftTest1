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

    /* inout: 让基本数据类型以以指针方式传递，而不是进行值拷贝，从而在函数内部可以修改外部的该变量 */
    
    /*
     泛型：类型滞后确定的编程模式，可以减少沟通成本
        
        泛型函数：函数的参数或返回值类型使用泛型，而不是具体的类型
            
            func 函数名<泛型1, 泛型2, …>(形参1, 形参2, ...) -> 返回类型 {
                函数体
            }
     
        泛型类型：这些自定义类、结构体和枚举可以适用于任何类型，类似于Array和Dictionary
     
            // Array 的使用
            let a1: Array<String> = ["a", "b"]
            let a2: Array<Int>    = [1, 2]

            // Dictionary 的使用
            let d1: Dictionary<String, String> = ["a": "b"]
            let d2: Dictionary<String, Int>    = ["a": 1]
     
        泛型约束：类型约束可以指定一个类型参数必须继承自指定类，或者符合一个特定的协议或协议组合，或者符合一些什么条件
     
            // 函数的协议、继承约束简单例子
            func f1<T: Equatable, U: Hashable>(p1: T, p2: U) -> U {
                return p2
            }
     
            // 类或结构体中的泛型约束，
            //写法1.1
            struct CustomIterator<Element: Equatable> {
                // ...
            }
            // 写法1.2
            struct CustomIterator<Element> where Element: Equatable {
                 // ...
            }

            // 写法2
            extension CustomIterator where Element: Equatable {
                func isExist(element: Element) -> Bool {
                    return elements.contains(element)
                }
            }
     
        泛型下标：
            
            下标能够是泛型的，他们能够包含泛型where子句。你可以把占位符类型的名称写在 subscript后面的尖括号里，在下标代码体开始的标志的花括号之前写下泛型where子句
     
             extension CustomIterator {
                 subscript<Indices: Sequence>(indices: Indices) -> [Element]
                     where Indices.Iterator.Element == Int {
                         var result = [Element]()
                         for index in indices {
                             result.append(self[index])
                         }
                         return result
                 }
             }
             
             let subIte = CustomIterator(elements: [1, 2, 3, 4])
             // 打印结果：[1, 3]
             print(subIte[[0, 2]])
     
     */
    func run<A>(_ count: inout A) throws -> A {

        return count
    }

   
}
