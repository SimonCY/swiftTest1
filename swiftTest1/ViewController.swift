//
//  ViewController.swift
//  swiftTest1
//
//  Created by Chenyan on 2020/2/5.
//  Copyright © 2020 Chenyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = 15
        var a = 15.0

        a = 14.3

        var name : String? = "张三"

        name = "李四"

        var sex : String? = nil


        Int(a) > 5 ? print("成人") : print("小孩")

        if name != nil {

            print("name is " + name!)
        }

        if let aSex = sex {

            print("sex is " + aSex)
        }

        guard name != nil else {

            print("name is nil")
            return

        }
    }


}

