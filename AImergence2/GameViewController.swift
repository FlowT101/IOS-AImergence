//
//  GameViewController.swift
//  AImergence2
//
//  Created by Olivier Georgeon on 09/01/16.
//  Copyright (c) 2016 Olivier Georgeon. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import StoreKit
import AVFoundation

enum INTERFACE: Int { case instruction, imagine, leaderboard, level}

class GameViewController: UIViewController, GameSceneDelegate, MenuSceneDelegate, HelpViewControllerDelegate, ImagineViewControllerDelegate, GKGameCenterControllerDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, GameViewDelegate //, GKMatchmakerViewControllerDelegate,  GKMatchDelegate
{
    @IBOutlet weak var sceneView: GameView!
    @IBOutlet weak var helpViewControllerContainer: UIView!
    @IBOutlet weak var imagineViewControllerContainer: UIView!
    @IBOutlet weak var levelButton: UIButton!
    @IBAction func levelButton(_ sender: UIButton) { showLevelWindow() }
    
    static let maxLevelNumber = 17
    
    let unlockDefaultKey = "unlockDefaultKey"
    let paidTipKey = "paidTipKey"
    let soundKey = "soundKey"
    let userDefaults = UserDefaults.standard
    let gcLoginMessage = NSLocalizedString("Please login to Game Center", comment: "Alert message that shows when the user tries to access the leaderboard without being logged in.")
    
    var instructionPortraitBottomConstraint = NSLayoutConstraint()
    var imaginePortraitBottomConstraint = NSLayoutConstraint()
    var gcEnabled = Bool() // Stores if the user has Game Center enabled
    var helpViewController:  HelpViewController?
    var imagineViewController: ImagineViewController?
    var interfaceLocks = [[Bool]](repeating: [true, true, true, true], count: GameViewController.maxLevelNumber + 1)
    var paidTip = false
    var validProducts = [SKProduct]()
    var match: GKMatch?
    var soundDisabled = false
    var sounds = [SKAction]()
    
    var level = 0 {
        didSet {
            levelButton.setTitle(NSLocalizedString("Level", comment: "") + " \(level)", for: UIControlState())
            if !helpViewControllerContainer.isHidden {
                helpViewController?.displayLevel(level)
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.authenticateLocalPlayer()
 
        paidTip = userDefaults.bool(forKey: paidTipKey)
        soundDisabled = userDefaults.bool(forKey: soundKey)
        if !soundDisabled {
            loadSounds()
        }
        
        let userInterfaceLocksWrapped = userDefaults.array(forKey: unlockDefaultKey)
        if let userInterfaceLocks = userInterfaceLocksWrapped as? [[Bool]] {
            for i in 0...(userInterfaceLocks.count - 1) {
                if interfaceLocks[i].count == userInterfaceLocks[i].count {
                    interfaceLocks[i] = userInterfaceLocks[i]
                }
            }
        }
        if CommandLine.arguments.count > 1 {
            if CommandLine.arguments[1] == "unlocked" {
                interfaceLocks = [[Bool]](repeating: [false, false, false, false], count: GameViewController.maxLevelNumber + 1)
            }
            if CommandLine.arguments[1] == "locked" {
                interfaceLocks = [[Bool]](repeating: [true, true, true, true], count: GameViewController.maxLevelNumber + 1)
            }
        }
        let gameScene = GameSKScene(levelNumber: 0)
        gameScene.gameSceneDelegate = self
        gameScene.scaleMode = SKSceneScaleMode.aspectFill
        sceneView.gameViewDelegate = self //Swift 3
        sceneView.showsFPS = false
        sceneView.showsNodeCount = false
        sceneView.ignoresSiblingOrder = true
        sceneView.presentScene(gameScene)
    
        instructionPortraitBottomConstraint = NSLayoutConstraint(item: helpViewControllerContainer, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: bottomLayoutGuide, attribute: NSLayoutAttribute.bottom, multiplier: 0.67, constant: 0)
        instructionPortraitBottomConstraint.isActive = false
        view.addConstraint(instructionPortraitBottomConstraint)

        imaginePortraitBottomConstraint = NSLayoutConstraint(item: imagineViewControllerContainer, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: bottomLayoutGuide, attribute: NSLayoutAttribute.bottom, multiplier: 0.67, constant: 0) // 120
        imaginePortraitBottomConstraint.isActive = false
        view.addConstraint(imaginePortraitBottomConstraint)
        
        SKPaymentQueue.default().add(self)
        requestProducts()
    }
    
    func leaveTip(_ product: SKProduct) {
        buyProduct(product);
    }

    func requestProducts() {
        if SKPaymentQueue.canMakePayments() {
            let productID: Set = ["com.oliviergeorgeon.little_ai.tip1", "com.oliviergeorgeon.little_ai.tip2", "com.oliviergeorgeon.little_ai.tip3"]
            let productRequest = SKProductsRequest(productIdentifiers: productID )
            productRequest.delegate = self
            productRequest.start()
            print("Fetching product")
        } else {
            print("Can't make purchase")
        }
    }
    
    func buyProduct(_ product: SKProduct) {
        print("sending the payment request to Apple")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        validProducts = response.products
        if let scene  = sceneView.scene as? MenuSKScene {
            scene.displayProducts(validProducts, isPaidTip: paidTip)
        }
        print("Recieved \(validProducts.count) products from Apple.")
    }
    /*
    func getProducts() -> [SKProduct] {
        return validProducts
    }
    */
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error fetching product information")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received payment transaction reponse from apple")
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    //print("Product purchased")
                    paidTip = true
                    userDefaults.set(true, forKey: paidTipKey)
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if let scene = sceneView.scene as? MenuSKScene {
                        scene.shortTipInvit = scene.thankYou
                        scene.longTipInvit = scene.thankYou
                        scene.tipInviteNode.text = scene.shortTipInvit
                    }
                case .failed:
                    //print("Purchased failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                case .restored:
                    //print("Already purchased")
                    paidTip = true
                    userDefaults.set(true, forKey: paidTipKey)
                    SKPaymentQueue.default().restoreCompletedTransactions()
                    //SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                default:
                    break
                }
            }
        }
    }
/*
    func isPaidTip() -> Bool {
        return paidTip
    }
  */
    func nextLevelScene() -> GameSKScene? {
        var nextGameScene:GameSKScene? = nil
        if !interfaceLocks[level][INTERFACE.level.rawValue] && level < GameViewController.maxLevelNumber {
            level += 1
            nextGameScene = GameSKScene(levelNumber: level)
            nextGameScene!.gameSceneDelegate = self
            closeImagineWindow()
        }
        return nextGameScene
    }
    
    func previousLevelScene() -> GameSKScene? {
        var previousGameScene:GameSKScene? = nil
        if level > 0 {
            level -= 1
            previousGameScene = GameSKScene(levelNumber: level)
            previousGameScene!.gameSceneDelegate = self
            closeImagineWindow()
        }
        return previousGameScene
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "ShowHelp":
                helpViewController = segue.destination as? HelpViewController
                helpViewController!.delegate = self
            case "ShowWorld":
                imagineViewController = segue.destination as? ImagineViewController
                imagineViewController!.delegate = self
            default:
                break
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let positionedScene = sceneView.scene as? PositionedSKScene {
            positionedScene.positionInFrame(size)
        }
        
        if size.width < size.height {
            instructionPortraitBottomConstraint.isActive = true
            imaginePortraitBottomConstraint.isActive = true
        } else {
            instructionPortraitBottomConstraint.isActive = false
            imaginePortraitBottomConstraint.isActive = false
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // Implement GameSceneDelegate
    func isGameCenterEnabled() -> Bool {
        return gcEnabled
    }
    
    func playExperience(_ experience: Experience) {
        if !imagineViewControllerContainer.isHidden {
            imagineViewController?.playExperience(experience)
        }
    }
    
    func showInstructionWindow() {
        imagineViewControllerContainer.isHidden = true
        imagineViewController?.sceneView.scene = nil
        helpViewController?.displayLevel(level)
        helpViewControllerContainer.isHidden = false
    }
    
    func isInterfaceLocked(_ interface: INTERFACE) -> Bool {
        return interfaceLocks[level][interface.rawValue]
    }

    func showImagineWindow(_ gameModel: GameModel0) {
        helpViewControllerContainer.isHidden = true
        if isInterfaceLocked(INTERFACE.level) {
            imagineViewController?.displayLevel(nil, okEnabled: true)
        } else {
            imagineViewController?.displayLevel(gameModel, okEnabled: !isInterfaceLocked(INTERFACE.imagine))
        }
        imagineViewControllerContainer.isHidden = false
    }
    
    func updateImagineWindow(_ gameModel: GameModel0) {
        if imagineViewController != nil {
            if !imagineViewControllerContainer.isHidden && imagineViewController!.imagineModel == nil {
                imagineViewController!.displayLevel(gameModel, okEnabled: !isInterfaceLocked(INTERFACE.imagine))
            }
        }
     }
    
    func showGameCenter() {
        if gcEnabled {
            let gcVC: GKGameCenterViewController = GKGameCenterViewController()
            gcVC.gameCenterDelegate = self
            gcVC.viewState = GKGameCenterViewControllerState.leaderboards
            gcVC.leaderboardIdentifier = "Level\(level)" // GameCenter bug: it must be repeted in completion otherwise it is not working
            self.present(gcVC, animated: true, completion: {gcVC.leaderboardIdentifier = "Levels";gcVC.leaderboardIdentifier = "Level\(self.level)"})
        } else {
            let alert = UIAlertController(title: "", message: gcLoginMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> () in
                if !self.isInterfaceLocked(INTERFACE.level) {
                    if let scene = self.sceneView.scene as? GameSKScene {
                        scene.tutorNode.gameCenterOk(scene.robotNode, level17ParentNode: scene.topRightNode)
                        if scene.robotNode.recommendation == RECOMMEND.leaderboard {
                            scene.robotNode.recommend(RECOMMEND.done)
                        }
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showLevelWindow() {
        helpViewControllerContainer.isHidden = true
        closeImagineWindow()
        if let scene  = sceneView.scene as? GameSKScene {
            if validProducts.count == 0 {
                requestProducts()
            }
            let menuScene = MenuSKScene()
            menuScene.previousGameScene = scene
            menuScene.userDelegate = self
            menuScene.scaleMode = SKSceneScaleMode.aspectFill
            menuScene.displayProducts(validProducts, isPaidTip: paidTip)
            sceneView.presentScene(menuScene, transition: scene.transitionUp)
        }
        if let menuScene  = sceneView.scene as? MenuSKScene {
            sceneView.presentScene(menuScene.previousGameScene!, transition: menuScene.transitionDown)
        }
    }
    /*
    func presentMatchMakingViewController(mmvc: GKMatchmakerViewController) {
        mmvc.matchmakerDelegate = self
        self.presentViewController(mmvc, animated: true, completion: nil)
    }

    optional func matchmakerViewController(_ viewController: GKMatchmakerViewController,
                                             didFindMatch match: GKMatch) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        match.delegate = self
        self.match = match
    }
    
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController,
                                    didFailWithError error: NSError) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    optional func match(_ match: GKMatch, didReceiveData data: NSData, fromRemotePlayer player: GKPlayer) {
        if self.match != match  {
            return
        }
        let p = data.bytes

        // Handle a position message.
    }
    
    optional func match(_ match: GKMatch, player player: GKPlayer, didChangeConnectionState state: GKPlayerConnectionState) {
        
    }
    
    optional func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
        
    }
    */
    func unlockLevel(_ moves: Int) {
        if gcEnabled {
            let sScore = GKScore(leaderboardIdentifier: "Level\(level)")
            sScore.value = Int64(moves)
            let sLevels = GKScore(leaderboardIdentifier: "Levels")
            sLevels.value = Int64(level)
            // Swift 3 changed NSError to Error
            GKScore.report([sLevels, sScore], withCompletionHandler: { (error: Error?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Score submitted: \(moves) moves in Level \(self.level)")
                }
            })
        }
        
        if isInterfaceLocked(INTERFACE.level) {
            interfaceLocks[level][INTERFACE.level.rawValue] = false
            userDefaults.set(interfaceLocks, forKey: unlockDefaultKey)
            //if !imagineViewControllerContainer.hidden {
            //    imagineViewController?.displayLevel(scene.gameModel)
            //}
        }
    }
    
    //Implement MenuSceneDelegate
    func currentLevel() -> Int {
        return level
    }
    
    func updateLevel(_ levelNumber: Int) {
        self.level = levelNumber
    }
    
    func levelStatus(_ level: Int) -> Int {
        var levelStatus = 0 // forbidden
        if level == 0 { levelStatus = 1 } //  allowed
        if level > 0 {
            if !interfaceLocks[level - 1][INTERFACE.level.rawValue]
                {levelStatus = 1 }
        }
        if !interfaceLocks[level][INTERFACE.level.rawValue]
            { levelStatus = 2 } // unlocked
        return levelStatus
    }

    // Implement HelpViewControllerDelegate
    func instructionClose() {
        helpViewControllerContainer.isHidden = true
        if let scene = sceneView.scene as? GameSKScene {
            scene.tutorNode.instructionClose(scene.robotNode.instructionButtonNode, level1parentNode: scene.robotNode)
        }
    }
    
    func instructionOk() {
        interfaceLocks[level][INTERFACE.instruction.rawValue] = false
        userDefaults.set(interfaceLocks, forKey: unlockDefaultKey)
        if let scene = sceneView.scene as? GameSKScene {
            scene.tutorNode.instructionOk(scene, level1parentNode: scene.robotNode)
            scene.robotNode.instructionButtonNode.disactivate()
            scene.robotNode.instructionButtonNode.unpulse()
            if scene.robotNode.recommendation == RECOMMEND.instruction {
                scene.robotNode.recommend(RECOMMEND.instruction_OK)
            }
            if !isInterfaceLocked(INTERFACE.level) && scene.robotNode.recommendation == RECOMMEND.instruction_OK {
                scene.robotNode.recommend(RECOMMEND.imagine)
            }
        }
        helpViewControllerContainer.isHidden = true
    }
    
    // Implement WorldViewControllerDelegate
    func imagineClose() {
        if !isInterfaceLocked(INTERFACE.level) {
            //if interfaceLocks[level][INTERFACE.imagine.rawValue] {
                if let scene = sceneView.scene as? GameSKScene {
                    scene.tutorNode.exploreOk(scene.robotNode.imagineButtonNode)
                }
            //}
        }
        closeImagineWindow()
    }
    
    func closeImagineWindow() {
        imagineViewControllerContainer.isHidden = true
        imagineViewController!.imagineModel = nil
        imagineViewController!.sceneView.scene = nil
    }
    
    func imagineOk() {
        if !isInterfaceLocked(INTERFACE.level) {
            interfaceLocks[level][INTERFACE.imagine.rawValue] = false
            userDefaults.set(interfaceLocks, forKey: unlockDefaultKey)
            if let scene = sceneView.scene as? GameSKScene {
                scene.tutorNode.robotOk(scene.robotNode.gameCenterButtonNode)
                scene.robotNode.imagineButtonNode.disactivate()
                if scene.robotNode.recommendation == RECOMMEND.imagine {
                    scene.robotNode.recommend(RECOMMEND.leaderboard)
                }
                if scene.robotNode.recommendation == RECOMMEND.leaderboard && gcEnabled {
                    scene.robotNode.gameCenterButtonNode.pulse()
                }
            }
        }
        closeImagineWindow()
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1 Show login if player is not logged in
                //self.presentViewController(ViewController!, animated: true, completion: nil)
                self.gcEnabled = false
            } else if (localPlayer.isAuthenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true                
                // Get the default leaderboard ID
                /*localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer!
                    }
                })*/
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated, disabling game center")
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        //print(gameCenterViewController.leaderboardIdentifier)
        if let scene = sceneView.scene as? GameSKScene {
            scene.robotNode.gameCenterButtonNode.disactivate()
            scene.tutorNode.gameCenterOk(scene.robotNode, level17ParentNode: scene.topRightNode)
            if isInterfaceLocked(INTERFACE.leaderboard) && !isInterfaceLocked(INTERFACE.level) {
                interfaceLocks[level][INTERFACE.leaderboard.rawValue] = false
                let defaults = UserDefaults.standard
                defaults.set(interfaceLocks, forKey: unlockDefaultKey)
            }
            if scene.robotNode.recommendation == RECOMMEND.leaderboard {
                scene.robotNode.recommend(RECOMMEND.done)
            }
        }
    }
    
    func loadSounds() {
        let sound1 = SKAction.playSoundFileNamed("baby1.wav", waitForCompletion: false)
        let sound2 = SKAction.playSoundFileNamed("baby2.wav", waitForCompletion: false)
        let sound3 = SKAction.playSoundFileNamed("baby3.wav", waitForCompletion: false)
        let sound4 = SKAction.playSoundFileNamed("baby4.wav", waitForCompletion: false)
        let sound5 = SKAction.playSoundFileNamed("baby5.wav", waitForCompletion: false)
        let sound6 = SKAction.playSoundFileNamed("baby6.wav", waitForCompletion: false)
        let sound7 = SKAction.playSoundFileNamed("baby7.wav", waitForCompletion: false)
        let sound8 = SKAction.playSoundFileNamed("baby8.wav", waitForCompletion: false)
        let sound9 = SKAction.playSoundFileNamed("baby9.wav", waitForCompletion: false)
        let sound10 = SKAction.playSoundFileNamed("baby10.wav", waitForCompletion: false)
        let sound11 = SKAction.playSoundFileNamed("baby11.wav", waitForCompletion: false)
        let sound12 = SKAction.playSoundFileNamed("baby12.wav", waitForCompletion: false)
        let sound13 = SKAction.playSoundFileNamed("baby13.wav", waitForCompletion: false)
        sounds = [sound1, sound2, sound3, sound4, sound5, sound6, sound7, sound8, sound9, sound10, sound11, sound12, sound13]
    }
    
    func soundAction(_ soundIndex: Int) -> SKAction {
        if soundIndex <= sounds.count {
            return sounds[soundIndex - 1]
        } else {
            return SKAction.run({})
        }
    }
    
    func toggleSound() -> Bool {
        soundDisabled = !soundDisabled
        userDefaults.set(soundDisabled, forKey: soundKey)
        if !soundDisabled && sounds.count < 13 {
            loadSounds()
        }
        return !soundDisabled
    }
    
    func isSoundEnabled() -> Bool {
        return !soundDisabled
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
        if let scene = sceneView.scene as? GameSKScene {
            scene.traceNode.dispose(scene.clock)
        }
    }
}
