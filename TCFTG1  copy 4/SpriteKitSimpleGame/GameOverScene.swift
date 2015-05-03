//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/30/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
  
  init(size: CGSize, won:Bool) {
    
    super.init(size: size)
    
    // 1
    backgroundColor = SKColor.blackColor()
    
    // 2
    var message = won ? "You Won!" : "You Lose"
    var count = displayInt
    
    // 3
    
    let label2 = SKLabelNode(fontNamed: "Chalkduster")
    label2.text = " You Survived \(count) Lasers "
    label2.fontSize = 25
    label2.fontColor = SKColor.redColor()
    label2.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(label2)

    
    
    //let label = SKLabelNode(fontNamed: "Chalkduster")
    //label.text = message
    //label.fontSize = 40
    //label.fontColor = SKColor.redColor()
    //label.position = CGPoint(x: size.width/2, y: size.height/2)
    //addChild(label)
    
    // 4
    runAction(SKAction.sequence([
      SKAction.waitForDuration(1.5),
      SKAction.runBlock() {
        // 5
        let reveal = SKTransition.flipHorizontalWithDuration(1.5)
        let scene = GameScene(size: size)
        self.view?.presentScene(scene, transition:reveal)
        displayInt = 0
      }
    ]))
    
  }

  // 6
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}