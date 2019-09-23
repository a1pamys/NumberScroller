//
//  ViewController.swift
//  SlotMachine
//
//  Created by a1pamys on 9/21/19.
//  Copyright © 2019 Алпамыс. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var slotMachine: SlotMachine!
    var _slotItems: [UIImage?] = [UIImage(named: "Doraemon"), UIImage(named: "Mario"), UIImage(named: "Nobi Nobita"), UIImage(named: "Batman")]

    var startButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .blue
        b.layer.cornerRadius = 24
        b.addTarget(self, action: #selector(startScrolling), for: .touchUpInside)
        b.setImage(UIImage(named: "Mario"), for: .normal)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        slotMachine = SlotMachine(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        slotMachine.dataSource = self
        
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        view.addSubview(slotMachine)
        view.addSubview(startButton)
    }
    
    func setupConstraints() {
        slotMachine.center = CGPoint(x: self.view.frame.size.width/2, y: 120)
        
        startButton.anchor(bottom: view.bottomAnchor, paddingBottom: 24, width: 48, height: 48)
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    @objc func startScrolling() {
        let slotCount = slotItems.count
        for _ in 0..<numberOfSlots {
            slotMachine.slotResults.append(Int(arc4random()) % slotCount)
        }
        slotMachine.startSliding()
    }
}

extension ViewController: SlotMachineDataSource {
    var numberOfSlots: Int {
        get {
            return 3
        }
    }
    
    var slotItems: [UIImage?] {
        get {
            return _slotItems
        }
    }
}
