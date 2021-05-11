//
//  ViewController.swift
//  MultipeerConnectivityDemoApp
//
//  Created by Taku Yamada on 2021/05/11.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var connectionSwitch: UISwitch!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

private extension ViewController {}
