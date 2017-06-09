//
//  ColorPopupSKNode.swift
//  Little AI
//
//  Created by Olivier Georgeon on 25/07/16.
//  CC0 No rights reserved.
//

import SpriteKit

class ColorPopupSKNode: SKNode {
    
    let colorNodeRect = CGRect(x: -60, y:-60, width: 120, height: 120)
    let colorsNode = SKNode()
    let actionAppear: SKAction
    let disappearScale = SKAction.scale(to: 0, duration: 0.1)
    
    var colorNodes = [SKShapeNode]()
    var colorIndex = 0

    override init() {
        let appearMove = SKAction.move(to: CGPoint(x: -200, y: 600), duration: 0.1)
        let appearScale = SKAction.scale(to: 1, duration: 0.1)
        actionAppear = SKAction.sequence([SKAction.unhide(), SKAction.group([appearMove, appearScale])])
        actionAppear.timingMode = .easeOut
        
        super.init()

        zPosition = 10
        setScale(0)
        addChild(colorsNode)

        let backgroundNode = SKShapeNode(rect: CGRect(x: -90, y: -410, width: 180, height: 820), cornerRadius: 0)
        backgroundNode.lineWidth = 0
        backgroundNode.fillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        backgroundNode.name = "colorPopup"
        addChild(backgroundNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func appear() {
        run(actionAppear)
    }
    
    func disappear(_ position: CGPoint) {
        let disappearMove = SKAction.move(to: position, duration: 0.1)
        let actionDisappear = SKAction.sequence([SKAction.group([disappearMove, disappearScale]), SKAction.hide()])
        actionDisappear.timingMode = .easeIn
        run(actionDisappear)
    }
    
    func createColorNodes(_ pathFunc: (CGRect) -> UIBezierPath, experienceColors: [UIColor], colorIndex: Int) {
        self.colorIndex = colorIndex
        colorsNode.removeAllChildren()
        colorNodes = [SKShapeNode]()
        for i in 0..<5 {
            let colorNode = SKShapeNode(path: pathFunc(colorNodeRect).cgPath)
            colorNode.fillColor = experienceColors[i]
            colorNode.strokeColor = UIColor.gray
            if i == colorIndex {
                colorNode.lineWidth = 12
            } else {
                colorNode.lineWidth = 4
            }
            colorNode.lineJoin = .round
            colorNode.zPosition = 1
            colorNode.position = CGPoint(x:0, y: i * 160 - 320)
            colorsNode.addChild(colorNode)
            colorNodes.append(colorNode)
        }
    }
    
    func revolve() {
        colorNodes[colorIndex].lineWidth = 4
        colorIndex += 1
        if colorIndex >= colorNodes.count {
            colorIndex = 0
        }
        colorNodes[colorIndex].lineWidth = 12
    }
}
