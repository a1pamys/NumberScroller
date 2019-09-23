//
//  SlotMachine.swift
//  SlotMachine
//
//  Created by a1pamys on 9/21/19.
//  Copyright © 2019 Алпамыс. All rights reserved.
//

import UIKit

class SlotMachine: UIView {
    
    var isSliding = false
    var minTurn = 3
    
    var slotScrollLayerArray = [CALayer]()
    var slotResults = Array<Int?>()
    var currentSlotResults = Array<Int?>()
    var singleUnitDuration: CGFloat = 0.14
    
    var contentView = UIView()
    
    var dataSource: SlotMachineDataSource? {
        didSet {
            reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView = UIView(frame: frame)
        addSubview(contentView)
        contentView.backgroundColor = .lightGray
    }
    
    func reloadData() {
        if let dataSource = dataSource {
            if let sublayers = contentView.layer.sublayers {
                for l in sublayers {
                    l.removeFromSuperlayer()
                }
            }
            
            slotScrollLayerArray = [CALayer]()
            
            let slotItems = dataSource.slotItems
            let numberOfSlots = dataSource.numberOfSlots
            let slotWidth = contentView.frame.self.width / CGFloat(numberOfSlots)
            let singleUnitHeight = contentView.frame.size.height/3
            let itemsCount = slotItems.count
            
            for i in 0..<numberOfSlots {
                let slotContainerLayer = CALayer()
                slotContainerLayer.frame = CGRect(x: CGFloat(i) * slotWidth, y: 0, width: slotWidth, height: contentView.frame.size.height)
                slotContainerLayer.masksToBounds = true
                
                let slotScrollLayer = CALayer()
                slotScrollLayer.frame = CGRect(x: 0, y: 0, width: slotWidth, height: slotContainerLayer.frame.size.height)
                
                slotContainerLayer.addSublayer(slotScrollLayer)
                slotScrollLayerArray.append(slotScrollLayer)
                contentView.layer.addSublayer(slotContainerLayer)
            }
            
            for i in 0..<numberOfSlots {
                let slotScrollLayer: CALayer = slotScrollLayerArray[i]
                let scrollLayerTopIndex = -(i + minTurn + 3) * itemsCount
                
                var j = 0
                while(j > scrollLayerTopIndex) {
                    let item = (slotItems[abs(j) % itemsCount])!
                    let itemLayer = CALayer()
                    
                    let offsetYUnit = j + 1 + itemsCount
                    itemLayer.frame = CGRect(x: 0, y: CGFloat(offsetYUnit) * singleUnitHeight, width: slotScrollLayer.frame.size.width, height: singleUnitHeight)
                    
                    itemLayer.contents = item.cgImage
                    itemLayer.contentsScale = item.scale
                    itemLayer.contentsGravity = CALayerContentsGravity.center
                    slotScrollLayer.addSublayer(itemLayer)
                    j -= 1
                }
            }
        }
    }
    
    func startSliding() {
        if isSliding {
            return
        }
        
        isSliding = true
        
        let slotItems = dataSource!.slotItems
        let itemsCount = slotItems.count
        
        var completePositionArray = NSMutableArray()
        
        CATransaction.begin()
        
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock {
            self.isSliding = false
            
            for i in 0..<self.slotScrollLayerArray.count {
                let slotScrollLayer = self.slotScrollLayerArray[i]
                slotScrollLayer.position = CGPoint(x: slotScrollLayer.position.x, y: CGFloat(truncating: completePositionArray[i] as! NSNumber))
                
                var toBeDeletedLayerArray = NSMutableArray()
                
                let resultIndex = self.slotResults[i]!
                var currentIndex = 0
                if self.currentSlotResults.count > 0 {
                    currentIndex = self.currentSlotResults[i]!
                }
                
                for j in 0..<(itemsCount * (self.minTurn + i) + resultIndex - currentIndex) {
                    let iconLayer = slotScrollLayer.sublayers![j]
                    toBeDeletedLayerArray.add(iconLayer)
                }
                
                for toBeDeletedLayer in toBeDeletedLayerArray {
                    let toBeAddedLayer = CALayer()
                    toBeAddedLayer.frame = (toBeDeletedLayer as! CALayer).frame
                    toBeAddedLayer.contents = (toBeDeletedLayer as! CALayer).contents
                    toBeAddedLayer.contentsScale = (toBeDeletedLayer as! CALayer).contentsScale
                    toBeAddedLayer.contentsGravity = (toBeDeletedLayer as! CALayer).contentsGravity
                    
                    let shiftY = CGFloat(itemsCount) * toBeAddedLayer.frame.size.height * CGFloat(self.minTurn + i + 3)
                    toBeAddedLayer.position = CGPoint(x: toBeAddedLayer.position.x, y: toBeAddedLayer.position.y - shiftY)
                    
                    (toBeDeletedLayer as! CALayer).removeFromSuperlayer()
                    slotScrollLayer.addSublayer(toBeAddedLayer)
                }
                toBeDeletedLayerArray = NSMutableArray()
            }
            
            self.currentSlotResults = self.slotResults
            completePositionArray = NSMutableArray()
        }
        
        for i in 0..<slotScrollLayerArray.count {
            let slotScrollLayer = slotScrollLayerArray[i]
            
            let resultIndex = slotResults[i]!
            var currentIndex = 0
            if currentSlotResults.count > 0 {
                currentIndex = currentSlotResults[i]!
            }
            
            let howManyUnits = (i + minTurn) * itemsCount + resultIndex - currentIndex
            let slideY = CGFloat(howManyUnits) * contentView.frame.size.height/3
            
            let slideAnimation = CABasicAnimation(keyPath: "position.y")
            slideAnimation.fillMode = CAMediaTimingFillMode.forwards
            slideAnimation.duration = CFTimeInterval(CGFloat(howManyUnits) * singleUnitDuration)
            slideAnimation.toValue = slotScrollLayer.position.y + slideY
            slideAnimation.isRemovedOnCompletion = false
            
            slotScrollLayer.add(slideAnimation, forKey: "slideAnimation")
            completePositionArray.add(slideAnimation.toValue!)
        }
        
        CATransaction.commit()
    }
}


