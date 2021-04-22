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
    @IBOutlet weak var mvpTextField: UITextField!
    @IBOutlet weak var mvvmMinimalTextField: UITextField!

    @IBOutlet weak var mvcButton: UIButton!
    @IBOutlet weak var mvpButton: UIButton!
    @IBOutlet weak var mvvmMinimalButton: UIButton!

    // Strong references
    var mvcObserver: NSObjectProtocol?
    var presenter: ViewPresenter?

    var minimalViewModel: MinimalViewModel?
    var minimalObserval: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        mvcDidLoad()
        mvpDidLoad()
        mvvmMinimalDidLoad()
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

protocol ViewProtocol: class {
    var textFiledValue: String { get set }
}

class ViewPresenter {
    let model: Model
    weak var view: ViewProtocol?
    let observer: NSObjectProtocol

    init(model: Model, view: ViewProtocol) {
        self.model = model
        self.view = view

        view.textFiledValue = model.value
        observer = NotificationCenter.default.addObserver(forName: Model.textDidChange, object: nil, queue: nil, using: { [view] (notif) in
            view.textFiledValue = notif.userInfo?[Model.textKey] as? String ?? ""
        })
    }

    func commit() {
        model.value = view?.textFiledValue ?? ""
    }
}

extension ViewController: ViewProtocol {

    func mvpDidLoad() {
        presenter = ViewPresenter(model: model, view: self)
    }

    @IBAction func mvpButtonPressed() {
        presenter?.commit()
    }

    var textFiledValue: String {
        get {
            mvpTextField.text ?? ""
        }
        set {
            mvpTextField.text = newValue
        }
    }

}

// Minimal MVVM ---------------------------------------------------------

class MinimalViewModel: NSObject {
    let model: Model
    var observer: NSObjectProtocol?
    @objc dynamic var textFieldValue: String

    init(model: Model) {
        self.model = model
        textFieldValue = model.value
        super.init()
        observer = NotificationCenter.default.addObserver(forName: Model.textDidChange, object: nil, queue: nil, using: { [weak self] (note) in
            self?.textFieldValue = note.userInfo?[Model.textKey] as? String ?? ""
        })
    }

    func commit(value: String) {
        model.value = value
    }
}

extension ViewController {
    func mvvmMinimalDidLoad() {
        minimalViewModel = MinimalViewModel(model: model)

        minimalObserval = minimalViewModel?.observe(\.textFieldValue, options: [.initial, .new], changeHandler: { [weak self] (_, change) in
            self?.mvvmMinimalTextField.text = change.newValue
        })
    }

    @IBAction func mvvmMinimalPressed() {
        minimalViewModel?.commit(value: mvvmMinimalTextField.text ?? "")
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
