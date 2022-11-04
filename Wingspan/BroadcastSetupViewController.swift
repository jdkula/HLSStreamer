//
//  BroadcastSetupViewController.swift
//  HLSStreamer
//
//  Provides the button that starts the system
//  broadcast from the UI
//
//  Created by @jdkula <jonathan@jdkula.dev> on 10/31/22.
//
import UIKit
import ReplayKit

@available(iOS 12.0, *)
class BroadcastSetupViewController: UIViewController {
    var broadcastPicker: RPSystemBroadcastPickerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create broadcast picker, and customize it as much as possiuble
        let broadcastPicker = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        broadcastPicker.preferredExtension = "dev.jdkula.Wingspan.ScreencapExtension"
        broadcastPicker.showsMicrophoneButton = false;
        
        // Adjust tint and move the button up a little bit to make room for the label
        if let buttonImg = broadcastPicker.subviews.first as? UIButton {
            buttonImg.imageView?.tintColor = UIColor.label
            buttonImg.center.y = 40;
        }
        
        // Centered label
        let label = UILabel(frame: CGRect(x: 400 / 2 - 100, y: 50, width: 200, height: 50))
        label.text = "Start Stream"
        label.textAlignment = .center
        broadcastPicker.addSubview(label)
        
        // Button-esque look behind it
        broadcastPicker.backgroundColor = UIColor.tertiarySystemBackground
        broadcastPicker.layer.cornerRadius = 8
        broadcastPicker.layer.masksToBounds = true
        
        view.addSubview(broadcastPicker)
        
        self.broadcastPicker = broadcastPicker;
    }
    
    /// Updates the view according to if we're currently recording or not
    func setStreaming(_ isStreaming: Bool) {
        guard let picker = broadcastPicker else {
            return
        }
        
        if let buttonImg = picker.subviews.first as? UIButton {
            buttonImg.imageView?.tintColor = isStreaming ? UIColor.red : UIColor.label
        }
        if let label = picker.subviews[1] as? UILabel {
            label.text = isStreaming ? "Streaming in progress..." : "Start Stream"
        }
    }
}
