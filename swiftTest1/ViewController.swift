//
//  ViewController.swift
//  swiftTest1
//
//  Created by Chenyan on 2020/2/5.
//  Copyright © 2020 Chenyan. All rights reserved.
//

import UIKit

/*
 swift和oc的区别：
 代码量明显减少
 类型判断更加严格，权限控制更加精细，oc的灵活度更高，很容易无意识造成代码的不规范，swift能让程序员更加注重代码细节
 由于高度封装所以错误提示有时候感觉莫名其妙
 可选项是一个很不适应的东西
 构造函数变化大
 swift枚举更像是一个对象

 swift和oc共用一套运行时系统

 混编时：
 swift调用oc时，需要创建桥接文件targetName-Bridging-Header.h，并在其中import oc的头文件
 oc 文件中若想调用swift，需要在当前文件引入 targetName-Swift.h
 oc中无法使用swift中的特殊语法，例如 枚举
 swift中对类型判断严格，不能非0即空，所以一些用于标志位的宏定义的使用需要严格注意
 swift宏定义不能定义一个方法
 swift中尽量使用OC中的h数据类型
 swift调用oc肯定不会出问题，但是oc调用swift不一定
 */

//MARK: - runtime
extension ViewController {

    @objc func cy_viewDidLoad() {

        print("cy_viewDidLoad")

        cy_viewDidLoad()
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

//MARK: - cycle
class ViewController: UIViewController, FirstViewDelegate {

    /**
     懒加载：（swift中本质是一个闭包）

        lazy 修饰属性时，会在第一次访问属性时执行闭包代码，将闭包返回值保存在 person 属性中
        如果没有 lazy，会在init时就执行一次闭包，相当于普通成员变量的初始化
        lazy 属性一但初始化后，会无视其他修改
     */

    var lazyProperty0 : FirstView = {

         print("lazy load property0")
         return FirstView()
     }()

    lazy var lazyProperty1 : FirstView = {

        print("lazy load property1")
        return FirstView()
    } ()

    /*
     闭包变量是一段准备好的代码，调用时必须加 self.xxx，以使其在执行时准确绑定对象，是引用类型
     
     $0表示闭包中第一个参数
     
     非逃逸闭包：
     
        非逃逸闭包的生命周期：1. 将闭包作为参数传递给函数，函数中运行闭包，退出函数。
        在进入函数和退出函数的时候闭包的引用计数没有改变。
     逃逸闭包：
        
        逃逸闭包在函数退出的时候仍然被其他对象持有，声明周期长于相关函数
        swfit3.x后，如果需要使用逃逸类型的闭包，需要用 @escaping 修饰， 并且逃逸闭包中必须显式的使用self
    
        例：
        var completionHandlers: [() -> Void] = []
     
        func someFunctionWithEscapingClosure(completionHandler: @escaping () -> Void) {
     
            completionHandlers.append(completionHandler)
        }
     
     逃逸闭包的使用场景：
        1. 异步调用: 如果需要调度队列中异步调用闭包， 这个队列会持有闭包的引用，至于什么时候调用闭包，或闭包什么时候运行结束都是不可预知的。
        2. 存储: 需要存储闭包作为属性，全局变量或其他类型做稍后使用
     */
    lazy var lazyProperty2 : FirstView = self.lazyProperty2Init()
//    lazy var lazyProperty2 : FirstView = { () -> FirstView in
//
//        print("lazy load property2")
//        return FirstView()
//    } ()

    let lazyProperty2Init = { () -> FirstView in

        print("lazy load property2")
        return FirstView()
    }

    lazy var lazyProperty3 : FirstView = FirstView()

    var notLazyProperty : FirstView {

        print("noLazyProperty loaded")
        return FirstView()
    }

    /**
    getter & setter , swift 中很少使用 getter setter，getter 的替代者为计算型属性，setter 的替代者为 didSet
     */
    private var _menuView0 : FirstView?
    var menuView0 : FirstView? {

        get {

            return _menuView0
        }

        set {

            _menuView0 = newValue

        }
    }

    var menuView1 : FirstView? {

        didSet {


        }
    }

    /**
    swift 中属性分为计算型属性和存储型属性
     readonly：
        swift 中只写 getter 方法时，代表 readonly ， 什么都不写代表 readwrite
        简写方式为：花括号中只写一个 return aVar
        只提供l getter 的属性也叫做 计算型属性
     */
    weak var alertView0 : FirstView? {

        get {

            return FirstView()
        }
    }

    var alertView1 : FirstView? {

        //每次调用 getter ，都会执行 {} 中的代码，
        return FirstView()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        //代理
        let subView = FirstView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        subView.delegate = self
        self.view.addSubview(subView)

        //OC混编
        VideoTool.init()

        try! self.demo15()
    }

    //MARK: - FirstViewDelegate

    func viewDidTouch() {

        print("subView did touched")
    }

    //MARK: - touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        print(lazyProperty0)
        print(lazyProperty1)
        print(lazyProperty2)
        print(lazyProperty3)

        print(notLazyProperty)

        let aSoundTool = SoundTool.shared
        
        print(aSoundTool)

    }

    //MARK: - demo

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

        //where 条件过滤
        let url : NSURL? = NSURL(string: "https://www.baidu.com")
        if let aUrl = url, aUrl.host == "www.baidu.com" && aUrl.host == "a" {

            print("url is " + aUrl.absoluteString!)
        }
    }

    /** guard let  */
    func demo5() {

        let name : String? = "老王"

        if name == nil {

            print("no name")
        }

        guard let aName = name else {

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


    /**
     for循环和范围定义
     */
    func demo7() {

        //0 ~ 8
        for i in 0..<9 {

            print(i)
        }

        //0 ~ 9
        for i in 0...9 {

            print(i)
        }

    }

    /**
        字符串
        swift中的字符串是结构体，oc中的字符串是继承自NSObject的对象
        swift字符串支持直接遍历
     */
    func demo8() {

        //声明
        let str0 : String = "hello"
        let str1 : String = "world"

        //c字符长度
        print("\(str0) 长度为 \(str0.lengthOfBytes(using: String.Encoding.utf8))")

        //遍历
        for c in str0 {

            print(c)
        }

        //简单拼接
        let str2 = str0 + str1
        print(str2)
        print(str0 + str1)
        print(str0, str1)
        print("\(str0) \(str1)")

        //format
        let h = 8, m = 5, s = 6
        let str3 : String = String(format: "%02d:%02d:%02d", h, m, s)
        let str4 : String = String(format: "%02d:%02d:%02d", arguments: [h, m, s])
        print(str3)
        print(str4)

        //swift中字符串取子串、包含判断等处理建议转成nsstring再处理
        let str5 = (str0 as NSString)
        print(str5.substring(with: NSMakeRange(0, str5.length)))

        //截取
        let str6 : String = str0
        let startIndex = str6.index(str6.startIndex, offsetBy: 2)
        let endIndex = str6.endIndex
        let range0 = startIndex..<endIndex

        let compare = startIndex < endIndex

        if compare == true {

            print("\(startIndex) < \(endIndex)")
        }

        print(str6.substring(with: range0))  //旧方法
        print(String(str6[range0]))      //新方法

        //包含判断
        let subStr = "ll"
        if str6.contains(subStr) {

            let range1 = str6.range(of: subStr)!
            print(String(str6[range1]))
        }
        let equel = (str6 == "ll")

        //替换
        let str7 = str6.replacingOccurrences(of: "ll", with: "aa")
        print(str7)

        //拆分
        let str8 : String = "a,d,c,d,v,f,,d,"
        let subStrs0 = str8.components(separatedBy: ",,")
        print(subStrs0)

        let str9 : NSString  = str8 as NSString
        let subStrs1 = str9.components(separatedBy: ",,")
        print(subStrs1)
    }

    /**
     数组
     */
    func demo9() {

        //oc中数组使用@[]，swift数组同样使用[]
        let array0 = Array<Any>(arrayLiteral: "a", "b")
        let array1 = [Any](arrayLiteral: "a", "b")
        let array2 = ["a", "b"] as [Any]
        print(array0, array1, array2)

        //为数组设置容量
        var array3 = [Any].init()
        array3.reserveCapacity(5)
        print(array3, array3.capacity)

        //数组中可以直接存基本数据类型
        let arr0 = ["a", "b", 10] as [Any]
        print(arr0)

        //数组中可以直接存结构体
        let arr1 = ["a", "b", CGPoint.init(x: 0, y: 1), NSMakeRange(0, 1)] as [Any]
        print(arr1)

        //数组中存不同类型时需要强转为 [any], 存相同类型时不需要，系统会自动识别 [String], [Int]
        let arr2 = [1, 2]
        let arr3 = ["a", "b", "c"]
        let arr4 = ["a", "b", CGPoint.init(x: 0, y: 1)] as [Any]
        print(arr2, arr3, arr4)

        //下标遍历
        for index in 0..<arr4.count {

            print(arr4[index])
        }

        //快速遍历
        for obj in arr4 {

            print(obj)
        }

        //枚举器遍历
        for (index, obj) in arr4.enumerated() {

            print("\(index) : '\(obj)'")
        }


        //声明：let声明的数组为不可变数组，var声明的数组为可变数组
        let arr5 = ["a", "b", "c"] as [AnyObject]
        var arr6 = [1, 2, 3] as [Any]
        var arr7 = arr5 + arr6
        print(arr5, arr6, arr7)

        //读取，first、last读取方式读取的为一个可选项，不会造成数组越界，arr[index]可能造成数组越界
        let obj0 = arr7[0]
        let obj1 = arr7.first
        print(obj0, obj1)

        //包含判断(相同类型元素的数组判断比较容易) （自定义对象要想使用 ==判断 ，需要该对象遵循Equatable协议，所以[Any]类型的数组不能直接用contains）
        if arr3.contains("a") {

            print("\(arr3) contains \("a")")
        }

        //插入（swift数组中允许插入可选项）
        arr7.insert(0, at: 3)
        print(arr7)

        arr7.append(4)
        print(arr7)

        let obj2 = URL(string: "a")
        arr7.append(obj2)
        print(arr7)

        //修改
        arr7[3] = "d"
        print(arr7)

        //删除
        arr6.removeAll()
        arr7.remove(at: arr7.endIndex - 1)
        arr7.removeLast()
        print(arr6, arr7)
        arr7.removeAll(keepingCapacity: true)
        print(arr7, arr7.capacity)

        //交换
        var arr8 = ["a", "b"]
        arr8.swapAt(0, 1)
        print(arr8)

        var arr9 = ["a", "b"]
        (arr9[0],arr9[1]) = (arr9[1],arr9[0])
        print(arr9)
    }

    /** 字典 */
    func demo10() {

        //OC字典使用@{}，swift字典仍然使用[]
        //OC字典只能存对象类型，swift字典可以存储任意类型
        //OC字典可以在同一字典中使用多种类型的对象作为key，swift中这种情况需要使用anyhashable结构体
        let dict0 = ["name" : "张三", "age" : 26, "location" : CGPoint(x: 10, y: 11), 50 : "num"] as [AnyHashable : Any]
        print(dict0)

        //可变字典为var，不可变字典为let
        let dict1 = ["name" : "张三"]
        let dict2 = ["sex" : "男"]
        var dict3 = dict1
        print(dict3)

        //遍历
        for (key, value) in dict0 {

            print("\(key) : \(value)")
        }

        for (key, value) in dict0.reversed() {

            print("\(key) : \(value)")
        }

        //读取
        print("name : \(dict0["name"] ?? "no name")")

        //包含判断，字典读出来的是可选项
        if dict0.keys.contains("name") {

            print(dict0["name"]!)
        }

        //合并只能通过遍历
        for (key, value) in dict2 {

            dict3[key] = value
        }
        print(dict3)

        //插入、修改 (swift字典中允许插入可选项)
        dict3["name"] = "李四"
        print(dict3)

        dict3["age"] = "18"
        print(dict3)
        dict3["age"] = nil
        print(dict3)

        //删除
        dict3.removeValue(forKey: "sex")
        print(dict3)

        dict3.removeAll()
        print(dict3)
    }

    /** 函数 */
    func demo11() -> Void {

        /*
         函数返回值类型为空时，可以为：

         func demo11() -> Void { }
         func demo12() { }
         func demo13() -> () { }
         */
    }

    /** 类、对象*/
    func demo12 () {

        view.backgroundColor = UIColor.blue

        let subView = FirstView.init(frame: CGRect.zero)
        subView.frame = CGRect(x: 20, y: 20, width: 50, height: 50)
        view.addSubview(subView)

        let stu = Student.init(dict: ["name" : "张三", "age" : 20, "grade" : "三年级", "number" : 436134])
        print(stu.name, stu.age, stu.grade!, stu.number)
        let stu0 = Student()
        print("name of stu0 is \(stu0.name)")

        let stu1 = Student(name : "张三", block: {})
        print("name of stu1 is \(stu1.name)")
    }
    /**
     枚举:
        swift枚举支持声明整型(Integer)、浮点数(Float Point)、字符串(String)、布尔类型(Boolean)、嵌套枚举
        swfit枚举支持像对象一样扩充 方法、计算型属性、静态方法
        swift支持为枚举添加拓展，一般用于将枚举中的case和func分离，提高可读性
        swift支持为枚举绑定Protocol
        swift支持声明枚举时使用泛型
     
     类和结构体和枚举的区别
     
        相同点：
        1. 都可以有属性和方法. 枚举enum只能有计算属性,没存储属性
        2. 都可以有函数
        3. 类和结构体可以有构造函数
     
        不同点：
        1. 类可以继承
        2. 类方法可以使用class关键字，枚举和结构体只能使用static关键字
        3. 类是引用类型，枚举和结构体是值类型
     
     嵌套类型：
       
        swift   可以在枚举类型、类和结构体中定义支持嵌套的类型，可以定义多级嵌套。
        意义：以枚举为例，枚举通常是为了支持特定的类或结构体的功能而创建的，嵌套类型从编译的角度约束使得结构体、枚举等和对应类的关联性更高，提高代码可读性。
     */

    enum Direction: String {
        case top = "top"
        case left = "left"
        case right = "right"
        case bottom = "bottom"
        
        func introduced() -> String {

            switch self {
            case .top: return "top"
            case .left: return "left"
            case .right: return "right"
            case .bottom: return "bottom"
            }
        }

        static func introduced(name: Direction) -> String? {

            if name == Direction.left {

                return "left"
            }
            return nil
        }
    }
    func demo13() {
        
        var aDirection = ViewController.Direction.left
        aDirection = Direction.right
        
        switch aDirection {

        case Direction.left:
            print("left")
        case Direction.right:
            print("right")

        default: ()
        }
    }

    /**
     网络请求和异常处理
     */
    func demo14() throws {

        let url = URL(string: "http://www.weather.com.cn/data/sk/101010100.html")

        URLSession.shared.dataTask(with: url!) { (data, _, error) in

            /*
             1、throw异常，这表示这个函数可能会抛出异常，无论作为参数的闭包是否抛出异常
             2、rethrow异常，这表示这个函数本身不会抛出异常，但如果作为参数的闭包抛出了异常，那么它会把异常继续抛上去。
             3、对throw函数，调用时需要加 try
             */

            //强行 try! 时程序员要负责，如果数据格式不正确，会崩溃
            let result0 = try!JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)

            //普通 try  异常代码需要用 do{  try func() }catch{} 包起来
            do {

                let result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)

                //类型判读用 xx is xx
                if result is Dictionary<String, Any> {

                    print(result)
                }
            } catch {

                print("error")
            }

            //尝试 try? ，如果失败会返回nil，u不会崩
            let result1 = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)

        }.resume()
    }

    var completion: ((_ finished: Bool)->())?
    /**
     循环引用
     */
    func demo15() {

        //方式一：使用weakself
        weak var weakSelf = self

        self.completion = { finished in

            //闭包中对weakSelf进行强引用，？表示一但weakSelf为nil，则不再访问
            print(weakSelf?.view as Any)
        }


        //方式二：使用[weak self]，表示闭包中对self的引用都是弱引用，与 __weak 类似，如果self被释放，则什么也不做，更安全
        self.completion = {[weak self] finished in

            print(self?.view as Any)
        }

        //方式d三：unowned 与 __unsafe__unretained 类似，如果sefl 被释放，同样会出现野指针
        self.completion = {[unowned self] (finished: Bool) in

            print(self.view as Any)
        }

        self.completion!(true)
    }

    /**
     多线程
     */
    func demo16() {

        DispatchQueue.global().async {

        }

        DispatchQueue.main.async {
            
        }
    }
}

