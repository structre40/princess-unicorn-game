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

    let coinSound = SKAction.playSoundFileNamed("CoinSound.mp3", waitForCompletion: false)
    let doubleCoinSound = SKAction.playSoundFileNamed("DoubleCoinSound.mp3", waitForCompletion: false)
    let eatingAppleSound = SKAction.playSoundFileNamed("EatingApple.mp3", waitForCompletion: false)
    //TODO: They fall to the ground and to restart a prince comes and gives them a kiss
    
    var score = Int(0)
    var scoreLbl = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var logoImg = SKSpriteNode()
    var wallPair = SKNode()
    var cherryNode = SKSpriteNode()
    var badAppleNode = SKSpriteNode()
    var moveAndRemove = SKAction()
    
    //CREATE THE PLAYER ATLAS FOR ANIMATION
    let princessUnicornAtlas = SKTextureAtlas(named:"player")
    var princessUnicornSprites = Array<SKTexture>()
    var princessUnicorn = SKSpriteNode()
    var repeatActionPrincessUnicorn = SKAction()
    
    let princeAtlas = SKTextureAtlas(named:"prince")
    var princeSprites = Array<SKTexture>()
    var prince = SKSpriteNode()
    var repeatActionPrince = SKAction()
    
    override func didMove(to view: SKView) {
        createScene()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameStarted == false{
            //Start princess unicorn to be affected by gravity requiring use to tap and create pause button
            isGameStarted =  true
            princessUnicorn.physicsBody?.affectedByGravity = true
            createPauseBtn()
            //Run the logo shrinking and removal
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()
            //Run the princess animations for flapping
            self.princessUnicorn.run(repeatActionPrincessUnicorn)
            
            //This run an action that creates and add pillar pairs to the scene.
            let spawn = SKAction.run({
                () in
                
                self.wallPair = self.createPlayableItems(score: self.score)
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
            
            princessUnicorn.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            princessUnicorn.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
        } else {
            //Continue with movement as long as collision did not occur
            if isSleeping == false {
                princessUnicorn.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                princessUnicorn.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
            }
        }
        for touch in touches{
            let location = touch.location(in: self)
            //1
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
                //2
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
        self.physicsBody?.collisionBitMask = CollisionBitMask.princessCategory
        self.physicsBody?.contactTestBitMask = CollisionBitMask.princessCategory
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
        
        //SET UP THE UNICORN SPRITES FOR ANIMATION
        princessUnicornSprites.append(princessUnicornAtlas.textureNamed("pu1"))
        princessUnicornSprites.append(princessUnicornAtlas.textureNamed("pu2"))
        princessUnicornSprites.append(princessUnicornAtlas.textureNamed("pu3"))
        princessUnicornSprites.append(princessUnicornAtlas.textureNamed("pu4"))
        
        //Create the princess unicorn
        self.princessUnicorn = createPrincessUnicorn()
        self.addChild(princessUnicorn)
        
        //PREPARE TO ANIMATE THE PRINCESS UNICORN AND REPEAT THE ANIMATION FOREVER
        let animatePrincessUnicorn = SKAction.animate(with: self.princessUnicornSprites, timePerFrame: 0.1)
        self.repeatActionPrincessUnicorn = SKAction.repeatForever(animatePrincessUnicorn)
        
        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionBitMask.princessCategory && secondBody.categoryBitMask == CollisionBitMask.pillarCategory || firstBody.categoryBitMask == CollisionBitMask.pillarCategory && secondBody.categoryBitMask == CollisionBitMask.princessCategory || firstBody.categoryBitMask == CollisionBitMask.princessCategory && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.princessCategory{
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if isSleeping == false{
                isSleeping = true
                createRestartBtn()
                pauseBtn.removeFromParent()
                self.princessUnicorn.removeAllActions()
                self.cherryNode.removeFromParent()
                showPrinceAnimation()
            }
        } else if firstBody.categoryBitMask == CollisionBitMask.princessCategory && secondBody.categoryBitMask == CollisionBitMask.singleCherryCategory {
            run(coinSound)
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.singleCherryCategory && secondBody.categoryBitMask == CollisionBitMask.princessCategory {
            run(coinSound)
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.princessCategory && secondBody.categoryBitMask == CollisionBitMask.doubleCherryCategory {
            run(doubleCoinSound)
            score += 2
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.doubleCherryCategory && secondBody.categoryBitMask == CollisionBitMask.princessCategory {
            run(doubleCoinSound)
            score += 2
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.princessCategory && secondBody.categoryBitMask == CollisionBitMask.badAppleCategory {
            run(eatingAppleSound)
            score -= 5
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.badAppleCategory && secondBody.categoryBitMask == CollisionBitMask.princessCategory {
            run(eatingAppleSound)
            score -= 5
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.princeCategory && secondBody.categoryBitMask == CollisionBitMask.princessCategory {
            self.prince.removeAllActions()
            
        } else if firstBody.categoryBitMask == CollisionBitMask.princessCategory && secondBody.categoryBitMask == CollisionBitMask.princeCategory {
            self.prince.removeAllActions()
        }
    }
    func showPrinceAnimation() {
        //Show the prince and animate
        //SET UP THE PRINCE SPRITES FOR ANIMATION
        princeSprites.append(princeAtlas.textureNamed("prince1"))
        princeSprites.append(princeAtlas.textureNamed("prince2"))
        princeSprites.append(princeAtlas.textureNamed("prince3"))
        princeSprites.append(princeAtlas.textureNamed("prince4"))
        
        //Create the prince
        self.prince = createPrince()
        self.addChild(prince)
        
        //PREPARE TO ANIMATE THE PRINCE AND REPEAT THE ANIMATION FOREVER
        let animatePrince = SKAction.animate(with: self.princeSprites, timePerFrame: 0.1)
        self.repeatActionPrince = SKAction.repeatForever(animatePrince)
        self.prince.run(repeatActionPrince)
        
        let move = SKAction.moveTo(x:0, duration: 5.0)
        prince.run(move)
        
    }
    func restartScene(){
        
        
        self.removeAllChildren()
        self.removeAllActions()
        isSleeping = false
        isGameStarted = false
        score = 0
        createScene()
    }
}
