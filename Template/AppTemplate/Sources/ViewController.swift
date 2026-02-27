//
//  ViewController.swift
//  AppTemplate
//
//  主视图控制器
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "首页"
        view.backgroundColor = .systemBackground

        // 添加基础 UI
        setupUI()
    }

    private func setupUI() {
        // 创建一个标签
        let label = UILabel()
        label.text = "欢迎使用 Tuist 模板"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
