//
//  BroadcastSetupViewController.swift
//  HLSStreamerContentUploadExtensionSetupUI
//
//  Created by Jonathan Kula on 10/31/22.
//
import UIKit
import ReplayKit

@available(iOS 12.0, *)
class BroadcastSetupViewController: UIViewController {
    var broadcastPicker: RPSystemBroadcastPickerView?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let broadcastPicker = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        broadcastPicker.preferredExtension = "dev.jdkula.HLSStreamer.HLSStreamerContentUploadExtension"
        if let buttonImg = broadcastPicker.subviews.first as? UIButton {
            buttonImg.imageView?.tintColor = UIColor.red
        }
        let label = UILabel(frame: CGRect(x: 400 / 2 - 80, y: 55, width: 160, height: 50))
        label.text = "Start Broadcast"
        label.textAlignment = .center
        broadcastPicker.addSubview(label)
        broadcastPicker.backgroundColor = UIColor.tertiarySystemBackground
        broadcastPicker.layer.cornerRadius = 8
        broadcastPicker.layer.masksToBounds = true
        view.addSubview(broadcastPicker)
    }
}
