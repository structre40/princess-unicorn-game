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
    //TODO: change sound to something a unicorn would do when eating the cherry instead of coin sound
    let coinSound = SKAction.playSoundFileNamed("CoinSound.mp3", waitForCompletion: false)
    let coinSoundWait = SKAction.playSoundFileNamed("CoinSound.mp3", waitForCompletion: true)
    let buzzerSound = SKAction.playSoundFileNamed("Buzzer.mp3", waitForCompletion: false)
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
    let princeUnicornAtlas = SKTextureAtlas(named:"prince")
    var princessUnicornSprites = Array<SKTexture>()
    var princessUnicorn = SKSpriteNode()
    var repeatActionPrincessUnicorn = SKAction()
    
    override func didMove(to view: SKView) {
        createScene()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameStarted == false{
            //1
            isGameStarted =  true
            princessUnicorn.physicsBody?.affectedByGravity = true
            createPauseBtn()
            //2
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()
            //3
            self.princessUnicorn.run(repeatActionPrincessUnicorn)
            
            //1- This run an action that creates and add pillar pairs to the scene.
            let spawn = SKAction.run({
                () in
                
                self.wallPair = self.createPlayableItems(score: self.score)
                self.addChild(self.wallPair)
            })
            //2- Here you wait for 2 seconds for the next set of pillars to be generated. A sequence of actions will run the spawn and delay actions forever.
            let delay = SKAction.wait(forDuration: 2.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            //3
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePillars = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePillars = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePillars, removePillars])
            
            princessUnicorn.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            princessUnicorn.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
        } else {
            //4
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
            run(coinSoundWait)
            run(coinSound)
            score += 2
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.doubleCherryCategory && secondBody.categoryBitMask == CollisionBitMask.princessCategory {
            run(coinSoundWait)
            run(coinSound)
            score += 2
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.princessCategory && secondBody.categoryBitMask == CollisionBitMask.badAppleCategory {
            run(buzzerSound)
            score -= 5
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.badAppleCategory && secondBody.categoryBitMask == CollisionBitMask.princessCategory {
            run(buzzerSound)
            score -= 5
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
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
}
