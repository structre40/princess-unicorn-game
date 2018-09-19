//
//  GameElements.swift
//  PrincessCherry
//
//  Created by Adam on 8/29/18.
//  Copyright © 2018 Adam Johnson. All rights reserved.
//

import SpriteKit

struct CollisionBitMask {
    static let princessCategory:UInt32 = 0x1 << 0
    static let pillarCategory:UInt32 = 0x1 << 1
    static let singleCherryCategory:UInt32 = 0x1 << 2
    static let groundCategory:UInt32 = 0x1 << 3
    static let doubleCherryCategory:UInt32 = 0x1 << 4
}
//var randomIntUsedForApple = random(10)

extension GameScene {
    
    func createPrincessUnicorn() -> SKSpriteNode {
        //1
        let princessUnicorn = SKSpriteNode(texture: SKTextureAtlas(named:"player").textureNamed("pu1"))
        princessUnicorn.size = CGSize(width: 100, height: 100)
        princessUnicorn.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        //2
        princessUnicorn.physicsBody = SKPhysicsBody(circleOfRadius: princessUnicorn.size.width / 2)
        princessUnicorn.physicsBody?.linearDamping = 1.1
        princessUnicorn.physicsBody?.restitution = 0
        //3
        princessUnicorn.physicsBody?.categoryBitMask = CollisionBitMask.princessCategory
        princessUnicorn.physicsBody?.collisionBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.groundCategory
        princessUnicorn.physicsBody?.contactTestBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.singleCherryCategory | CollisionBitMask.groundCategory
        //4
        princessUnicorn.physicsBody?.affectedByGravity = false
        princessUnicorn.physicsBody?.isDynamic = true
        
        return princessUnicorn
    }
    
    //Creates the restart button and resets the game
    func createRestartBtn() {
        
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width:100, height:100)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    //Creaes the pause button to be displayed during the game running
    func createPauseBtn() {
        pauseBtn = SKSpriteNode(imageNamed: "pause")
        pauseBtn.size = CGSize(width:40, height:40)
        pauseBtn.position = CGPoint(x: self.frame.width - 30, y: 30)
        pauseBtn.zPosition = 6
        self.addChild(pauseBtn)
    }
    //3
    func createScoreLabel() -> SKLabelNode {
        let scoreLbl = SKLabelNode()
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.6)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 50
        scoreLbl.fontName = "HelveticaNeue-Bold"
        
        let scoreBg = SKShapeNode()
        scoreBg.position = CGPoint(x: 0, y: 0)
        scoreBg.path = CGPath(roundedRect: CGRect(x: CGFloat(-50), y: CGFloat(-30), width: CGFloat(100), height: CGFloat(100)), cornerWidth: 50, cornerHeight: 50, transform: nil)
        let scoreBgColor = UIColor(red: CGFloat(0.0 / 255.0), green: CGFloat(0.0 / 255.0), blue: CGFloat(0.0 / 255.0), alpha: CGFloat(0.2))
        scoreBg.strokeColor = UIColor.clear
        scoreBg.fillColor = scoreBgColor
        scoreBg.zPosition = -1
        scoreLbl.addChild(scoreBg)
        return scoreLbl
    }
    //4
    func createHighscoreLabel() -> SKLabelNode {
        let highscoreLbl = SKLabelNode()
        highscoreLbl.position = CGPoint(x: self.frame.width - 80, y: self.frame.height - 22)
        if let highestScore = UserDefaults.standard.object(forKey: "highestScore"){
            highscoreLbl.text = "Highest Score: \(highestScore)"
        } else {
            highscoreLbl.text = "Highest Score: 0"
        }
        highscoreLbl.zPosition = 5
        highscoreLbl.fontSize = 15
        highscoreLbl.fontName = "Helvetica-Bold"
        return highscoreLbl
    }
    //5
    func createLogo() {
        logoImg = SKSpriteNode()
        logoImg = SKSpriteNode(imageNamed: "logo")
        logoImg.size = CGSize(width: 272, height: 65)
        logoImg.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 100)
        logoImg.setScale(0.5)
        self.addChild(logoImg)
        logoImg.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    //6
    func createTaptoplayLabel() -> SKLabelNode {
        let taptoplayLbl = SKLabelNode()
        taptoplayLbl.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 100)
        taptoplayLbl.text = "Tap anywhere to play"
        taptoplayLbl.fontColor = UIColor(red: 63/255, green: 79/255, blue: 145/255, alpha: 1.0)
        taptoplayLbl.zPosition = 5
        taptoplayLbl.fontSize = 20
        taptoplayLbl.fontName = "HelveticaNeue"
        return taptoplayLbl
    }
    
    func createPlayableItems(score: Int) -> SKNode  {
        //If the score is a factor of 10, do the double cherry
        cherryNode = SKSpriteNode()
        wallPair = SKNode()
        wallPair.name = "wallPair"
        if (score > 0 && score % 10 == 0)
        {
            cherryNode = SKSpriteNode(imageNamed: "doublecherry")
            cherryNode.size = CGSize(width: 30, height: 50)
            cherryNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
            cherryNode.physicsBody = SKPhysicsBody(rectangleOf: cherryNode.size)
            cherryNode.physicsBody?.affectedByGravity = false
            cherryNode.physicsBody?.isDynamic = false
            cherryNode.physicsBody?.categoryBitMask = CollisionBitMask.doubleCherryCategory
            cherryNode.physicsBody?.collisionBitMask = 0
            cherryNode.physicsBody?.contactTestBitMask = CollisionBitMask.princessCategory
            cherryNode.color = SKColor.blue
        }
        else
        {
            // Prepare the single cherry
            cherryNode = SKSpriteNode(imageNamed: "singlecherry")
            cherryNode.size = CGSize(width: 30, height: 50)
            cherryNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
            cherryNode.physicsBody = SKPhysicsBody(rectangleOf: cherryNode.size)
            cherryNode.physicsBody?.affectedByGravity = false
            cherryNode.physicsBody?.isDynamic = false
            cherryNode.physicsBody?.categoryBitMask = CollisionBitMask.singleCherryCategory
            cherryNode.physicsBody?.collisionBitMask = 0
            cherryNode.physicsBody?.contactTestBitMask = CollisionBitMask.princessCategory
            cherryNode.color = SKColor.blue
            
        }
        if score > 5 {
            let topWall = SKSpriteNode(imageNamed: "pillarVines")
            let btmWall = SKSpriteNode(imageNamed: "pillarVines")
            
            topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 500)
            btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 500)
            
            topWall.setScale(0.5)
            btmWall.setScale(0.5)
            
            topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
            topWall.physicsBody?.categoryBitMask = CollisionBitMask.pillarCategory
            topWall.physicsBody?.collisionBitMask = CollisionBitMask.princessCategory
            topWall.physicsBody?.contactTestBitMask = CollisionBitMask.princessCategory
            topWall.physicsBody?.isDynamic = false
            topWall.physicsBody?.affectedByGravity = false
            
            btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
            btmWall.physicsBody?.categoryBitMask = CollisionBitMask.pillarCategory
            btmWall.physicsBody?.collisionBitMask = CollisionBitMask.princessCategory
            btmWall.physicsBody?.contactTestBitMask = CollisionBitMask.princessCategory
            btmWall.physicsBody?.isDynamic = false
            btmWall.physicsBody?.affectedByGravity = false
        
            topWall.zRotation = CGFloat(Double.pi)
        
            wallPair.addChild(topWall)
            
            if (score > 10) {
                wallPair.addChild(btmWall)
            }
        }
        wallPair.zPosition = 1
        // 3
        let randomPosition = random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y +  randomPosition
        wallPair.addChild(cherryNode)
        
        wallPair.run(moveAndRemove)
        
        return wallPair
        
    }
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }

}

