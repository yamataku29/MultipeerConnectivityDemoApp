//
//  ViewController.swift
//  MultipeerConnectivityDemoApp
//
//  Created by Taku Yamada on 2021/05/11.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {
    @IBOutlet private weak var connectingSwitch: UISwitch!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var logTextView: UITextView!
    
    private let serviceName = "p2ptest"
    private var peerId: MCPeerID!
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension ViewController {
    func configure() {
        peerId = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerId,
            discoveryInfo: nil,
            serviceType: serviceName
        )
        advertiser.delegate = self
        browser = MCNearbyServiceBrowser(
            peer: peerId,
            serviceType: serviceName
        )
        browser.delegate = self
        connectingSwitch.addTarget(
            self,
            action: #selector(connectingSwitchAction(sender:)),
            for: .touchUpInside
        )
        connectingSwitch.isOn = false
        submitButton.addTarget(
            self,
            action: #selector(submitButtonAction(sender:)),
            for: .touchUpInside
        )
        let viewTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(tapped(_:))
        )
        view.addGestureRecognizer(viewTapGesture)
        inputTextField.delegate = self
    }
    
    func outputLog(with text: String) {
        DispatchQueue.main.async {
            let logText = self.logTextView.text ?? ""
            self.logTextView.text = logText + "\n" + text
        }
    }
    
    @objc func connectingSwitchAction(sender: UISwitch) {
        outputLog(with: "searchSwitchAction isOn: \(sender.isOn)")
        if sender.isOn {
            advertiser.startAdvertisingPeer()
            browser.startBrowsingForPeers()
        } else {
            advertiser.stopAdvertisingPeer()
            browser.stopBrowsingForPeers()
        }
    }
    
    @objc func submitButtonAction(sender: UIButton) {
        outputLog(with: "submitButtonAction")
        defer { inputTextField.text = nil }
        guard let text = inputTextField.text,
              let data = text.data else { return }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)  
        } catch {
            outputLog(with: "Failure send text")
        }
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func showAlert(with message: String) {
        let title = "Date received!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case MCSessionState.connected:
                self.statusLabel.text = "Connected"
                self.outputLog(with: "Connected: \(peerID.displayName)")
            case MCSessionState.connecting:
                self.statusLabel.text = "Connecting"
                self.outputLog(with: "Connecting: \(peerID.displayName)")
            case MCSessionState.notConnected:
                self.statusLabel.text = "notConnected"
                self.outputLog(with: "notConnected: \(peerID.displayName)")
            @unknown default:
                fatalError()
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let receiveText = data.string ?? "none"
        outputLog(with: "didReceive data: \(receiveText)")
        DispatchQueue.main.async {
            self.showAlert(with: receiveText)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        outputLog(with: "didReceive stream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        outputLog(with: "didStartReceivingResourceWithName resourceName: \(resourceName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        outputLog(with: "didFinishReceivingResourceWithName resourceName: \(resourceName)")
    }
}

extension ViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        outputLog(with: "didReceiveInvitationFromPeer peerID: \(peerID)")
        invitationHandler(true, session)
    }
}

extension ViewController: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        outputLog(with: "foundPeer peerID: \(peerID)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: .zero)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        outputLog(with: "lostPeer peerID: \(peerID)")
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
