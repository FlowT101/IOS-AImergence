//
//  GameModel4.swift
//  Little AI
//
//  Created by Olivier Georgeon on 03/08/16.
//  CC0 No rights reserved.
//

import Foundation
import SpriteKit

class GameModel4: GameModel0
{
    required convenience init()
    {
        let experimentRect = CGRect(x: -120, y: -120, width: 240, height: 240)
        let experimentPositions = [CGPoint(x: -180, y: 0), CGPoint(x: 180, y: 0), CGPoint(x: 0, y: 0)]
        let experienceRect = CGRect(x: -40, y: -40, width: 80, height: 80)
        let initialScale = CGFloat(120)/40
        let obsolescence = 200
        let actionScale = SKAction.scale(to: 1, duration: 0.2)
        let experimentPaths = [{UIBezierPath(ovalIn: $0)},{UIBezierPath(rect: $0)}, triangle]
        let experienceColors = [UIColor.white, UIColor(red: 0, green: 0.9, blue: 0, alpha: 1), UIColor.red, UIColor.blue, UIColor.orange]
        let sounds = [[9, 12], [11, 3], [2, 2]]
        
        self.init(experimentRect: experimentRect, experimentPositions: experimentPositions, experienceRect: experienceRect, initialScale: initialScale, obsolescence: obsolescence, actionScale: actionScale, experimentPaths: experimentPaths, experienceColors: experienceColors, sounds: sounds)
    }

}
