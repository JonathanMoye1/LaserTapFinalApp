//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/30/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!
var displayInt = 0
var death = 0


func playBackgroundMusic(filename: String) {
  let url = NSBundle.mainBundle().URLForResource(
    filename, withExtension: nil)
  if (url == nil) {
    println("Could not find file: \(filename)")
    return
  }

  var error: NSError? = nil
  backgroundMusicPlayer = 
    AVAudioPlayer(contentsOfURL: url, error: &error)
  if backgroundMusicPlayer == nil {
    println("Could not create audio player: \(error!)")
    return
  }

  backgroundMusicPlayer.numberOfLoops = -1
  backgroundMusicPlayer.prepareToPlay()
  backgroundMusicPlayer.play()
}

import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Monster   : UInt32 = 0b1       // 1
  static let Projectile: UInt32 = 0b10
  static let Player: UInt32 = 0b10      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  let player = SKSpriteNode(imageNamed: "player")
   
  var monstersDestroyed = 0
  
  override func didMoveToView(view: SKView) {
  
    playBackgroundMusic("background-music-aac.caf")
  
    backgroundColor = SKColor.blackColor()
    player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.35)
    
    
    addChild(player)
    player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
    player.physicsBody?.dynamic = true
    player.physicsBody?.categoryBitMask = PhysicsCategory.Player
    player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
    player.physicsBody?.collisionBitMask = PhysicsCategory.None
    
    physicsWorld.gravity = CGVectorMake(0, 0)
    physicsWorld.contactDelegate = self
    
    addMonster()
    
    runAction(SKAction.repeatActionForever(
      SKAction.sequence([
        SKAction.runBlock(addMonster),
        SKAction.waitForDuration(1.0)
      ])
    ))
    
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }

  func random(#min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }

  func addMonster() {

    // Create sprite
    let monster = SKSpriteNode(imageNamed: "monster")
    monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
    monster.physicsBody?.dynamic = true
    monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player
    monster.physicsBody?.collisionBitMask = PhysicsCategory.None
    
    // Determine where to spawn the monster along the X and Y axis
    let xchose = random(min: CGFloat(0.0), max: CGFloat(16.0))
    let actualY = monster.size.height/2
    if   xchose > 8 {let actualX = size.width
        monster.position = CGPoint(x: actualX, y: actualY)}
    else if xchose < 8 { let actualX = monster.size.width                  //actualX =  size.width //monster.size.width
                                                                   // Position the monster
        monster.position = CGPoint(x: actualX, y: actualY) }
    
    // Add the monster to the scene
    addChild(monster)
    displayInt = displayInt + 1
    
    // Determine speed of the monster
    let actualDuration = random(min: CGFloat(10.0), max: CGFloat(22.0))
    
    // Create the actions
    if xchose > 8 {let actionMove = SKAction.moveTo(CGPoint(x: size.width/50, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.runAction(SKAction.sequence([actionMove,actionMoveDone]))}
        
        
    else if xchose < 8 {let actionMove = SKAction.moveTo(CGPoint(x: size.width, y: actualY), duration: NSTimeInterval(actualDuration))

        let actionMoveDone = SKAction.removeFromParent()
    let loseAction = SKAction.runBlock() {
      let reveal = SKTransition.flipHorizontalWithDuration(0.5)
      let gameOverScene = GameOverScene(size: self.size, won: false)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
    monster.runAction(SKAction.sequence([actionMove,actionMoveDone]))}//loseAction, actionMoveDone]))

  }
  
    
    
    
    
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {

    runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))

    // 1 - Choose one of the touches to work with
    let touch = touches.anyObject() as UITouch
    let touchLocation = touch.locationInNode(self)
    
    // 2 - Set up initial location of projectile
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = player.position
    
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    projectile.physicsBody?.dynamic = true

    projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
    projectile.physicsBody?.usesPreciseCollisionDetection = true
    
    // 3 - Determine offset of location to projectile
    
    let offset = touchLocation - projectile.position
    
    
    
    // 4 - Bail out if you are shooting down or backwards
    
   // if (death > 1) { projectile.removeFromParent() ; death = 0 }
   // if (death < 2) { addChild(projectile) }
   // death = death + 1
    
    if (offset.x < 0) {     player.position = touchLocation}
    if (offset.x > 0) {     player.position = touchLocation}
    
    
    // 5 - OK to add now - you've double checked position
    
    
   
    
    
    
    
    
    
     
    
     projectile.position = touchLocation
    
    // 6 - Get the direction of where to shoot
    //let direction = offset.normalized()
   //if (offset.x > 0) {   let direction = touchLocation  }
    // 7 - Make it shoot far enough to be guaranteed off screen
    //let shootAmount = direction * 1000
    
    // 8 - Add the shoot amount to the current position
   // let realDest = shootAmount + projectile.position
    
    // 9 - Create the actions
   // let actionMove = SKAction.moveTo(realDest, duration: 1500.0)
   // let actionMoveDone = SKAction.removeFromParent()
   //projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    
  }
  
  func projectileDidCollideWithMonster(player:SKSpriteNode, monster:SKSpriteNode) {
    println("Hit")
    player.removeFromParent()
    monster.removeFromParent()
    
    monstersDestroyed++
    if (monstersDestroyed > 0) {
      let reveal = SKTransition.flipHorizontalWithDuration(0.1)
      let gameOverScene = GameOverScene(size: self.size, won: true)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
  }
  
  func didBeginContact(contact: SKPhysicsContact) {

    // 1
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    // 2
    if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
        (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
      projectileDidCollideWithMonster(firstBody.node as SKSpriteNode, monster: secondBody.node as SKSpriteNode)
    }
    
  }
  
}
