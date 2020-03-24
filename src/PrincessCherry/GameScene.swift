//
//  GameScene.swift
//  PrincessCherry
//
//  Created by Adam on 8/29/18.
//  Copyright © 2018 Adam Johnson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene , SKPhysicsContactDelegate {
    var isGameStarted = Bool(false)
    var isSleeping = Bool(false)
    var isPrinceMoving = Bool(false)
    var isPlayerTypePrincess = Bool(true)
    
    let coinSound = "CoinSound.mp3"
    let doubleCoinSound = "DoubleCoinSound.mp3"
    let eatingAppleSound = "EatingApple.mp3"
     let kissSound = "kiss2.mp3"
    
    var score = Int(0)
    var scoreLbl = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    var restartBtn = SKSpriteNode()
    var settingsBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var logoImg = SKSpriteNode()
    var wallPair = SKNode()
    var cherryNode = SKSpriteNode()
    var badAppleNode = SKSpriteNode()
    var moveAndRemove = SKAction()
    
    //Preferences
    var showWallsPreference = UserDefaults.standard.bool(forKey: "display_columns_preference")
    var playSoundsPreference = UserDefaults.standard.bool(forKey: "play_sounds_preference")
    
    //CREATE THE PLAYER ATLAS FOR ANIMATION
    let princessUnicornAtlas = SKTextureAtlas(named:"player")
    let knightDragonAtlas = SKTextureAtlas(named:"dragonprince")
    var princessUnicornSprites = Array<SKTexture>()
    var knightDragonSprites = Array<SKTexture>()
    var playerSpriteNode = SKSpriteNode()
    var repeatActionPlayer = SKAction()
    
    let princeAtlas = SKTextureAtlas(named:"prince")
    var princeSprites = Array<SKTexture>()
    var prince = SKSpriteNode()
    var repeatActionPrince = SKAction()
    
    
    override func didMove(to view: SKView) {
        createScene()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isGameStarted == false)
        {
            let touch = touches.first!
            let location = touch.location(in: self.view)
            if (settingsBtn.contains(location))
            {
                //Open the settings menu instead of starting the game
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
            else
            {
                //Start player to be affected by gravity requiring use to tap and create pause button
                isGameStarted =  true
                playerSpriteNode.physicsBody?.affectedByGravity = true
                createPauseBtn()
                //Run the logo shrinking and removal
                logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                    self.logoImg.removeFromParent()
                })
                taptoplayLbl.removeFromParent()
                settingsBtn.removeFromParent()
                
                //Run the player animations for flapping
                self.playerSpriteNode.run(repeatActionPlayer)
                
                //This run an action that creates and add pillar pairs to the scene.
                let spawn = SKAction.run({
                    () in
                    
                    self.wallPair = self.createPlayableItems(score: self.score, showWalls: self.showWallsPreference)
                    self.addChild(self.wallPair)
                })
                //Wait for 2 seconds for the next set of pillars to be generated. A sequence of actions will run the spawn and delay actions forever.
                let delay = SKAction.wait(forDuration: 2.0)
                let SpawnDelay = SKAction.sequence([spawn, delay])
                let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
                self.run(spawnDelayForever)
                
                //Move the pillars and remove as they get to the end of the frame
                let distance = CGFloat(self.frame.width + wallPair.frame.width)
                let movePillars = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
                let removePillars = SKAction.removeFromParent()
                moveAndRemove = SKAction.sequence([movePillars, removePillars])
                
                playerSpriteNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                playerSpriteNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
                }
        } else {
            //Continue with movement as long as collision did not occur
            if isSleeping == false {
                playerSpriteNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                playerSpriteNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
            }
        }
        for touch in touches{
            let location = touch.location(in: self)
            if (settingsBtn.contains(location))
            {
                //Open the settings menu
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
            else
            {
                //Check if the game is active
                if isSleeping == true{
                    if restartBtn.contains(location){
                        if UserDefaults.standard.object(forKey: "highestScore") != nil {
                            let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                            if hscore < Int(scoreLbl.text!)!{
                                UserDefaults.standard.set(scoreLbl.text, forKey: "highestScore")
                            }
                        } else {
                            UserDefaults.standard.set(0, forKey: "highestScore")
                        }
                        restartScene()
                    }
                    
                } else {
                    //If the game is active and the user clicks pause
                    if pauseBtn.contains(location){
                        if self.isPaused == false{
                            self.isPaused = true
                            pauseBtn.texture = SKTexture(imageNamed: "play")
                        } else {
                            self.isPaused = false
                            pauseBtn.texture = SKTexture(imageNamed: "pause")
                        }
                    }
                }
            }
        }
     }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if isGameStarted == true{
            if isSleeping == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
                    }
                }))
            }
        }
    }
    
    func createScene(){
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.playerCategory
        self.physicsBody?.contactTestBitMask = CollisionBitMask.playerCategory
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        //Creates the background
        for i in 0..<2
        {
            let background = SKSpriteNode(imageNamed: "bgCastle")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        //Check the settings in case they changed and we need to update the player being used
        if(UserDefaults.standard.string(forKey: "player_type_preference") == "princess")
        {
            isPlayerTypePrincess = true;
        }
        else
        {
            isPlayerTypePrincess = false;
        }
        
        //Create the prince and player based on settings
        self.playerSpriteNode = createPlayer(atlasName: isPlayerTypePrincess ? "player" : "dragonprince", textureName: isPlayerTypePrincess ? "pu1" : "DragonPrince1")
        self.addChild(playerSpriteNode)
        self.prince = createPrince()
        princeSprites.append(princeAtlas.textureNamed("prince1"))
        princeSprites.append(princeAtlas.textureNamed("prince2"))
        princeSprites.append(princeAtlas.textureNamed("prince3"))
        princeSprites.append(princeAtlas.textureNamed("prince4"))
        let animatePrince = SKAction.animate(with: self.princeSprites, timePerFrame: 0.1)
        self.repeatActionPrince = SKAction.repeatForever(animatePrince)
        
        var animatePlayer = SKAction()
        //Prepare to animate the player as selected in settings and animate forever
        if(isPlayerTypePrincess)
        {
            princessUnicornSprites.append(princessUnicornAtlas.textureNamed("pu1"))
            princessUnicornSprites.append(princessUnicornAtlas.textureNamed("pu2"))
            princessUnicornSprites.append(princessUnicornAtlas.textureNamed("pu3"))
            princessUnicornSprites.append(princessUnicornAtlas.textureNamed("pu4"))
            animatePlayer = SKAction.animate(with: self.princessUnicornSprites, timePerFrame: 0.1)
        }
        else
        {
            knightDragonSprites.append(knightDragonAtlas.textureNamed("DragonPrince1"))
            knightDragonSprites.append(knightDragonAtlas.textureNamed("DragonPrince2"))
            knightDragonSprites.append(knightDragonAtlas.textureNamed("DragonPrince3"))
            knightDragonSprites.append(knightDragonAtlas.textureNamed("DragonPrince4"))
            animatePlayer = SKAction.animate(with: self.knightDragonSprites, timePerFrame: 0.1)
        }
        
        self.repeatActionPlayer = SKAction.repeatForever(animatePlayer)
        
        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        createSettingsBtn()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionBitMask.playerCategory && secondBody.categoryBitMask == CollisionBitMask.pillarCategory || firstBody.categoryBitMask == CollisionBitMask.pillarCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory || firstBody.categoryBitMask == CollisionBitMask.playerCategory && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory{
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if isSleeping == false{
                isSleeping = true
                self.addChild(prince)
                
                //Dont do the prince animation for now
                //showPrinceAnimation()
                createRestartBtn()
                createSettingsBtn()
                pauseBtn.removeFromParent()
                self.playerSpriteNode.removeAllActions()
                self.cherryNode.removeFromParent()
                self.badAppleNode.removeFromParent()
            }
        } else if firstBody.categoryBitMask == CollisionBitMask.playerCategory && secondBody.categoryBitMask == CollisionBitMask.singleCherryCategory {
            playSound(coinSound)
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.singleCherryCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory {
            playSound(coinSound)
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.playerCategory && secondBody.categoryBitMask == CollisionBitMask.doubleCherryCategory {
            playSound(doubleCoinSound)
            score += 2
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.doubleCherryCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory {
            playSound(doubleCoinSound)
            score += 2
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.playerCategory && secondBody.categoryBitMask == CollisionBitMask.badAppleCategory {
            playSound(eatingAppleSound)
            score -= 5
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.badAppleCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory {
            playSound(eatingAppleSound)
            score -= 5
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.princeCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory {
            prince.physicsBody?.contactTestBitMask = 0;
            prince.physicsBody?.isDynamic = false;
            //prince.removeAllActions()
            
        } else if firstBody.categoryBitMask == CollisionBitMask.playerCategory && secondBody.categoryBitMask == CollisionBitMask.princeCategory {
            prince.physicsBody?.contactTestBitMask = 0;
            prince.physicsBody?.isDynamic = false;
            //prince.removeAllActions()
        }
    }
    func showPrinceAnimation() {
        
        //PREPARE TO ANIMATE THE PRINCE AND REPEAT THE ANIMATION FOREVER
        self.prince.run(repeatActionPrince, withKey: "princeWalk")
        
        let move = SKAction.moveTo(x:frame.maxX, duration: 5)
        prince.run(move) {
            self.prince.removeFromParent()
        }
        
    }
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        isSleeping = false
        isGameStarted = false
        score = 0
        createScene()
    }
    
    func playSound(_ soundToPlay: String)
    {
        //if (self.playSoundsPreference)
        if(UserDefaults.standard.bool(forKey: "play_sounds_preference"))
        {
            run(SKAction.playSoundFileNamed(soundToPlay, waitForCompletion: false))
        }
    }
}
