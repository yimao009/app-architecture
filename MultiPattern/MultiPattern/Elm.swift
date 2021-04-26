//
//  Elm.swift
//  MultiPattern
//
//  Created by guoruize on 2021/4/22.
//

import UIKit

enum ElmView<Action> {
    case textFiled(String, onChange: ((String) -> Action)?)
    case button(title: String, onTap: Action?)
}

enum Command<Action> {
    case changeModelText(String)

    func execute(_ model: Model, _ handle: @escaping (Action) -> ()) {
        switch self {
        case .changeModelText(let t):
            model.value = t
        }
    }
}

enum Subscription<Action> {
    case notification(name: Notification.Name, (Notification) -> Action)
}

class DisposeBag {
    var disposeBag: [Any] = []
    func append(_ value: Any) {
        disposeBag.append(value)
    }
}

class Driver<State, Action> {
    var state: State {
        didSet {
            updateForChangeState()
        }
    }

    var disposeBag: DisposeBag
    let update: (inout State, Action) -> Command<Action>?
    let view: (State) -> [ElmView<Action>]
    let subscriptions: (State) -> [Subscription<Action>]
    let rootView: UIStackView
    let model: Model
    var notifications: [NotificationSubscription<Action>] = []

    init(_ initial: State,
         update: @escaping (inout State, Action) -> Command<Action>?,
         view: @escaping (State) -> [ElmView<Action>],
         subscriptions: @escaping (State) -> [Subscription<Action>],
         rootView: UIStackView,
         model: Model) {
        self.state = initial
        self.update = update
        self.view = view
        self.rootView = rootView
        self.disposeBag = DisposeBag()
        self.subscriptions = subscriptions
        self.model = model
        rootView.backgroundColor = .white
        updateForChangeState()
    }

    func updateForChangeState() {
        let d = DisposeBag()
        rootView.updateSubviwes(virtualViews: view(state), sendAction: { [unowned self] in
            self.receive($0)
        }, disposeBag: d)
        self.disposeBag = d
        self.updateSubscriptions()
    }

    func updateSubscriptions() {
        let all = subscriptions(state)
        if all.count != notifications.count {
            notifications = []
            for s in all {
                switch s {
                case let .notification(name: name, action):
                    notifications.append(NotificationSubscription(name, handle: action, send: { [unowned self] in
                        self.receive($0)
                    }))
                }
            }
        } else {
            for i in 0 ..< all.count {
                switch all[i] {
                case let .notification(name: name, action):
                    assert(notifications[i].name == name) // todo
                    notifications[i].action = action
                }
            }
        }
    }

    func receive(_ action: Action) {
        if let command = update(&state, action) {
            command.execute(model) { [unowned self] in
                self.receive($0)
            }
        }
    }
}

class NotificationSubscription<Action> {
    let name: (Notification.Name)
    var action: (Notification) -> Action
    let send: (Action) -> ()

    init(_ name: NSNotification.Name,
         handle: @escaping (Notification) -> Action,
         send: @escaping (Action) -> ()) {
        self.name = name
        self.action = handle
        self.send = send
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { [unowned self] (notification) in
            self.send(self.action(notification))
        }
    }
}

fileprivate final class TA: NSObject {
    let execute: () -> ()

    init(_ action: @escaping () -> ()) {
        self.execute = action
    }

    @objc func action(_ sender: Any) {
        self.execute()
    }
}

extension UIStackView {
    func updateSubviwes<Action>(virtualViews: [ElmView<Action>],
                                sendAction: @escaping (Action) -> (),
                                disposeBag: DisposeBag) {
        let diff = subviews.count - virtualViews.count
        if diff > 0 {
            for s in subviews.suffix(diff) {
                removeArrangedSubview(s)
                s.removeFromSuperview()
            }
        } else if diff < 0 {
            for _ in 0 ..< (-diff) {
                insertArrangedSubview(UIView(), at: subviews.count)
            }
        }

        assert(arrangedSubviews.count == virtualViews.count, "\((subviews.count, virtualViews.count))")

        for index in 0 ..< arrangedSubviews.endIndex {
            let view = arrangedSubviews[index]
            let virtualView = virtualViews[index]
            switch virtualView {
            case let .button(title: title, onTap: action):
                let button: UIButton
                if let b = view as? UIButton {
                    button = b
                } else {
                    button = UIButton(type: .roundedRect)
                    button.translatesAutoresizingMaskIntoConstraints = false
                    insertArrangedSubview(button, at: index)
                    removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
                button.setTitle(title, for: .normal)
                button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                button.removeTarget(nil, action: nil, for: .touchUpInside)
                if let a = action {
                    let ta = TA {
                        sendAction(a)
                    }
                    disposeBag.append(ta)
                    button.addTarget(ta, action: #selector(TA.action), for: .touchUpInside)
                }
            case let .textFiled(title, onChange: onChange):
                let textField: UITextField
                if let b = view as? UITextField {
                    textField = b
                } else {
                    textField = UITextField()
                    textField.translatesAutoresizingMaskIntoConstraints = false
                    textField.font = UIFont.systemFont(ofSize: 14)
                    insertArrangedSubview(textField, at: index)
                    removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
                if textField.text != title {
                    textField.text = title
                }
                textField.borderStyle = .roundedRect
                textField.removeTarget(nil, action: nil, for: .editingChanged)
                if let o = onChange {
                    let ta = TA { [unowned textField] in
                        sendAction(o(textField.text ?? ""))
                    }
                    disposeBag.append(ta)
                    textField.addTarget(ta, action: #selector(TA.action), for: .editingChanged)
                }
            }
        }
    }
}
