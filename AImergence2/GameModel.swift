//
//  SceneStruct.swift
//  AImergence2
//
//  Created by Olivier Georgeon on 13/01/16.
//  Copyright © 2016 Olivier Georgeon. All rights reserved.
//

import SpriteKit

class GameModel
{
    let backgroundColor     = SKColor.lightGrayColor()
    let color               = UIColor.whiteColor()
    let titleFont           = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)

    let actionMoveTrace     = SKAction.moveBy(CGVector(dx:0, dy:50), duration: 0.3)
    
    let colorNodeRect       = CGRect(x: -30, y:-30, width: 60, height: 60)
    
    func moveByVect(point: CGPoint) -> CGVector { return CGVector(dx: -point.x, dy: 90 - point.y) }
    
    func createScoreLabel() -> SKLabelNode {
        let scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontName = titleFont.fontName
        scoreLabel.fontSize = titleFont.pointSize
        scoreLabel.verticalAlignmentMode = .Center
        scoreLabel.fontColor = UIColor.darkGrayColor()// blackColor()
        return scoreLabel
    }
    
    func createScoreBackground() -> SKShapeNode {
        let scoreBackground = SKShapeNode(rect: CGRect(x: -30, y: -30, width: 60, height: 60), cornerRadius: 20)
        scoreBackground.position = CGPoint(x: -117, y: 480)
        scoreBackground.lineWidth = 0
        scoreBackground.name = "scoreBackground"
        scoreBackground.fillColor = UIColor.whiteColor()
        return scoreBackground
    }
    
    func createShapePopup() -> SKShapeNode {
        let popupBackground = SKShapeNode(rect: CGRect(x: -160, y: -70, width: 320, height: 140), cornerRadius: 10)
        popupBackground.position = CGPoint(x: 0, y: 150)
        popupBackground.lineWidth = 0
        popupBackground.fillColor = UIColor.whiteColor()
        popupBackground.zPosition = 10
        popupBackground.name = "shapePopup"
        return popupBackground
    }

    func createColorPopup() -> SKShapeNode {
        let popupBackground = SKShapeNode(rect: CGRect(x: -50, y: -230, width: 100, height: 460), cornerRadius: 10)
        popupBackground.position = CGPoint(x: -100, y: 300)
        popupBackground.lineWidth = 0
        popupBackground.fillColor = UIColor.whiteColor()
        popupBackground.zPosition = 10
        popupBackground.name = "colorPopup"
        return popupBackground
    }
    
    func createRobotNode() -> SKSpriteNode {
        let robotNode = SKSpriteNode(imageNamed: "happy1.png")
        robotNode.size = CGSize(width: 100, height: 100)
        robotNode.position = CGPoint(x: 120, y: 180)
        return robotNode
    }

    func createBackroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode(imageNamed: "fond.png")
        backgroundNode.size = CGSize(width: 1188 , height: 1188)
        backgroundNode.position = CGPoint(x: 400, y: 0)
        backgroundNode.zPosition = -20
        backgroundNode.name = "background"
        return backgroundNode
    }
    
    class func createGameModel(levelNumber: Int) -> GameModel2 {
        var level = Level0()
        let bundleName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        let aClass:AnyClass? =  NSClassFromString(bundleName + ".Level\(levelNumber)")
        if let levelType = aClass as? Level0.Type { level = levelType.init() }

        var gameModel = GameModel2()
        let gameModelString = level.gameModelString
        let aClass2:AnyClass? =  NSClassFromString(bundleName + "." + gameModelString)
        if let gameModelType = aClass2 as? GameModel2.Type {
            gameModel = gameModelType.init()
        }
        gameModel.level = level
        return gameModel
    }
}
