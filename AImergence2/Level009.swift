//
//  Level0.swift
//  AImergence
//
//  Created by Olivier Georgeon on 31/12/15.
//  CC0 No rights reserved.
//

import GameplayKit
import Foundation

class Level009: Level005 {
    
    override var number:Int { return 9 }

    var env = [false, true, false, true, false, true, false, true, false, true]
    var p = 0
    
    convenience required init() {
        let experiment0 = Experiment(number: 0, shapeIndex: 1)
        let experiment1 = Experiment(number: 1, shapeIndex: 2)
        let experiment2 = Experiment(number: 2, shapeIndex: 0)
        let experiments = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: [experiment0, experiment1, experiment2]) as! [Experiment]
        
        let experience00 = Experience(experiment: experiment0, resultNumber: 0, valence:0, colorIndex: 2)
        let experience01 = Experience(experiment: experiment0, resultNumber: 1, valence:0, colorIndex: 1)
        let experience10 = Experience(experiment: experiment1, resultNumber: 0, valence:0, colorIndex: 2)
        let experience11 = Experience(experiment: experiment1, resultNumber: 1, valence:1, colorIndex: 1)
        let experience20 = Experience(experiment: experiment2, resultNumber: 0, valence:0, colorIndex: 0)//2)
        let experience21 = Experience(experiment: experiment2, resultNumber: 1, valence:0, colorIndex: 1)
        let experiences = [[experience00, experience01], [experience10, experience11], [experience20, experience21]]
        
        self.init(winScore: 10, historicalDepth: 10, experiments: experiments, experiences: experiences)
    }

    override func play(_ experiment: Experiment) -> (Experience, Int) {
        
        var result = 0
        
        switch experiment.number {
        case 0: // touch
            if currentPhenomenon { result = 1 }
        case 1: // eat
            if currentPhenomenon { result = 1 }
            env[p] = currentPhenomenon
            p += 1; if p >= env.count { p = 0 }
            currentPhenomenon = env[p]
        case 2: //swap
            currentPhenomenon = !currentPhenomenon
        default:
            break
        }
        
        let experience = experiences[experiment.number][result]
        
        return (experience, score(experience))
    }
}
