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
        broadcastPicker.showsMicrophoneButton = false;
        if let buttonImg = broadcastPicker.subviews.first as? UIButton {
            buttonImg.imageView?.tintColor = UIColor.label
            buttonImg.center.y = 40;
        }
        let label = UILabel(frame: CGRect(x: 400 / 2 - 100, y: 50, width: 200, height: 50))
        label.text = "Start Stream"
        label.textAlignment = .center
        broadcastPicker.addSubview(label)
        broadcastPicker.backgroundColor = UIColor.tertiarySystemBackground
        broadcastPicker.layer.cornerRadius = 8
        broadcastPicker.layer.masksToBounds = true
        view.addSubview(broadcastPicker)
        
        self.broadcastPicker = broadcastPicker;
        
    }
    
    func setRecording(_ isRecording: Bool) {
        guard let bc = broadcastPicker else {
            return
        }
        
        if (isRecording) {
            if let buttonImg = bc.subviews.first as? UIButton {
                buttonImg.imageView?.tintColor = UIColor.red
            }
            if let label = bc.subviews[1] as? UILabel {
                label.text = "Streaming in progress..."
            }
        } else {
            if let buttonImg = bc.subviews.first as? UIButton {
                buttonImg.imageView?.tintColor = UIColor.systemFill
            }
            if let label = bc.subviews[1] as? UILabel {
                label.text = "Start Stream"
            }
        }
    }
}
