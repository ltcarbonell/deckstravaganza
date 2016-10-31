//
//  GameViewControllerButton.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 10/19/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import SpriteKit


// this is a class for a button that can be used with SKScenes
class GameViewControllerButton: SKSpriteNode {
    var defaultButton: SKSpriteNode;
    var action: () -> Void
    
    init(defaultButtonImage: String, buttonAction: @escaping () -> Void) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        action = buttonAction
        
        let imageTexture = SKTexture(imageNamed: defaultButtonImage)
        super.init(texture: imageTexture, color: UIColor.black, size: imageTexture.size())
        
        isUserInteractionEnabled = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        defaultButton.isHidden = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location: CGPoint = touch.location(in: self)
            
            if defaultButton.contains(location) {
                defaultButton.isHidden = true
            } else {
                defaultButton.isHidden = false
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location: CGPoint = touch.location(in: self)
            
            if defaultButton.contains(location) {
                action()
            }
            
            defaultButton.isHidden = false
            self.removeFromParent()
        }
        
    }
}
