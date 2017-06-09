//
//  WorldScene1.swift
//  AImergence
//
//  Created by Olivier Georgeon on 11/02/16.
//  CC0 No rights reserved.
//

import SceneKit

class ImagineModel015: ImagineModel014
{
    override func imagine(experience: Experience) {
        constraint.influenceFactor = 0.5
        switch experience.experiment.number {
        case 0:
            robotNode.turnLeft()
            spawnExperienceNode(experience, position: robotNode.position)
        case 1:
            switch experience.resultNumber {
            case 1:
                robotNode.moveForward()
                spawnExperienceNode(experience, position: robotNode.position)
            default:
                constraint.influenceFactor = 0
                robotNode.bump()
                if robotNode.knownCells.updateValue(Phenomenon.tile, forKey: robotNode.robot.cellFront()) == nil {
                    createTileNode(tileColor(experience), position: robotNode.positionForward() + SCNVector3(0, -0.5 * scale, 0), delay: 0.1)
                }
                spawnExperienceNode(experience, position: robotNode.position + robotNode.forwardVector() / 2, delay: 0.1)
            }
        case 2:
            robotNode.turnRight()
            spawnExperienceNode(experience, position: robotNode.position)
        case 3:
            robotNode.feelFront()
            spawnExperienceNode(experience, position: robotNode.position + robotNode.forwardVector() / 2, delay: 0.2)
            if experience.resultNumber == 1 {
                if robotNode.knownCells.updateValue(Phenomenon.tile, forKey: robotNode.robot.cellFront()) == nil {
                    createTileNode(tileColor(experience), position: robotNode.positionForward() + SCNVector3(0, -0.5 * scale, 0), delay: 0.2)
                }
            }
        case 4:
            robotNode.feelLeft()
            spawnExperienceNode(experience, position: (robotNode.position + robotNode.positionLeft()) / 2, delay: 0.2)
            if experience.resultNumber == 1 {
                if robotNode.knownCells.updateValue(Phenomenon.tile, forKey: robotNode.robot.cellLeft()) == nil {
                    createTileNode(tileColor(experience), position: robotNode.positionLeft() + SCNVector3(0, -0.5 * scale, 0), delay: 0.2)
                }
            }
        default:
            robotNode.feelRight()
            spawnExperienceNode(experience, position: (robotNode.position + robotNode.positionRight()) / 2, delay: 0.2)
            if experience.resultNumber == 1 {
                if robotNode.knownCells.updateValue(Phenomenon.tile, forKey: robotNode.robot.cellRight()) == nil {
                    createTileNode(tileColor(experience), position: robotNode.positionRight() + SCNVector3(0, -0.5 * scale, 0), delay: 0.2)
                }
            }
        }
    }
}
