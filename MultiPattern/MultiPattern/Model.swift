//
//  Model.swift
//  MultiPattern
//
//  Created by guoruize on 2021/4/21.
//

import Foundation

class Model {
    static let textDidChange = Notification.Name("textDidChange")
    static let textKey = "text"
    var value: String {
        didSet {
            NotificationCenter.default.post(name: Model.textDidChange, object: self, userInfo: [Model.textKey: value])
        }
    }

    init(value: String) {
        self.value = value
    }
}
