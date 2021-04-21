//
//  ViewController.swift
//  MultiPattern
//
//  Created by guoruize on 2021/4/18.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    let model = Model(value: "initial value")

    @IBOutlet weak var mvcTextField: UITextField!
    
    @IBOutlet weak var mvcButton: UIButton!

    // Strong references
    var mvcObserver: NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        mvcDidLoad()

    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//    }

}

extension ViewController {

    func mvcDidLoad() {
        mvcTextField.text = model.value
        mvcObserver = NotificationCenter.default.addObserver(forName: Model.textDidChange, object: nil, queue: nil) { [mvcTextField] (notif) in
            mvcTextField?.text = notif.userInfo?[Model.textKey] as? String
        }
    }

    @IBAction func mvcButtonPressed() {
        model.value = mvcTextField?.text ?? "non"
    }
}



extension ViewController {
    func recoard() {
        //        let label = UILabel()
        //        label.text = "UILabel"
        //        view.addSubview(label)
        //
        //        let testView = UIView()
        //        testView.backgroundColor = UIColor.cyan
        //        view.addSubview(testView)
        //
        //        let container = UILayoutGuide()
        //        view.addLayoutGuide(container)
        //
        //        label.snp.makeConstraints { (make) in
        //            make.left.equalTo(container)
        //            make.centerY.equalTo(container)
        //        }
        //
        //        testView.snp.makeConstraints { (make) in
        //            make.left.equalTo(label.snp.right).offset(20)
        //            make.height.equalTo(40)
        //            make.width.equalTo(120)
        //            make.right.equalTo(container)
        //            make.centerY.equalTo(container)
        //        }
        //
        //        container.snp.makeConstraints { (make) in
        //            make.height.equalTo(5)
        //            make.center.equalTo(view)
        //        }
    }
}
