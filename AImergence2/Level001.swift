//
//  Level0.swift
//  AImergence
//
//  Created by Olivier Georgeon on 31/12/15.
//  CC0 No rights reserved.
//

import Foundation
import GameplayKit

class Level001 : Level000 {
    
    override var number:Int { return 1 }
    override var gameModelString: String { return "GameModel1" }
    
    var orientationRight = false
    
    convenience required init() {
        let experiment0 = Experiment(number: 0, shapeIndex: 2)
        let experiment1 = Experiment(number: 1, shapeIndex: 1)
        let experiment2 = Experiment(number: 2, shapeIndex: 0)
        
        let experiments = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: [experiment0, experiment1, experiment2]) as! [Experiment]
        
        let experience00 = Experience(experiment: experiment0, resultNumber: 0, valence:-1, colorIndex: 2)
        let experience01 = Experience(experiment: experiment0, resultNumber: 1, valence: 1, colorIndex: 1)
        let experience10 = Experience(experiment: experiment1, resultNumber: 0, valence:-1, colorIndex: 2)
        let experience11 = Experience(experiment: experiment1, resultNumber: 1, valence: 1, colorIndex: 1)
        let experience20 = Experience(experiment: experiment2, resultNumber: 0, valence: 0, colorIndex: 4)
        let experiences = [[experience00, experience01], [experience10, experience11], [experience20]]
        
        self.init(winScore: 10, historicalDepth: 10, experiments: experiments, experiences: experiences)
    }
    
    override func play(_ experiment: Experiment) -> (Experience, Int) {
        
        var result:Int
        
        switch (experiment.number, orientationRight) {
        case (0, false):
            result = 1
        case (0, true):
            result = 0
        case (1, false):
            result = 0
        case (1, true):
            result = 1
        case (2, false), (2, true):
            orientationRight = !orientationRight
            result = 0
        default:
            result = 0
        }
        
        let experience = experiences[experiment.number][result]
        
        return (experience, score(experience))
    }
}
