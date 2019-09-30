//
//  GameScene.swift
//  BioProj
//
//  Created by Addison Chen on 5/3/19.
//  Copyright © 2019 Addison Chen. All rights reserved.
//


import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //var bumper = SKSpriteNode(color: UIColor.black, size: CGSize(width: 150, height: 30))
    var hexagons =  [Hexagon]()
    var gameOver = false
    var baseHex = SKSpriteNode()
    var time = 0
    var prevValue = 0
    var rotationTimer = 0
    var rotatingRight = false
    var rotatingLeft = false
    
    var score = 0
    var highScore = 0
    
    
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let tapRec2 = UITapGestureRecognizer()
    
    
    // initial screen
    override func didMove(to view: SKView) {
        // initial values
        hexagons = Utils().initGenerateHexagons(width: self.frame.width, height: self.frame.height)
        baseHex = Utils().initGenerateBaseHex(width: self.frame.width, height: self.frame.height, rotation: 0)
        
        swipeRightRec.addTarget(self, action: #selector(GameScene.swipedRight) )
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)
        
        swipeLeftRec.addTarget(self, action: #selector(GameScene.swipedLeft) )
        swipeLeftRec.direction = .left
        self.view!.addGestureRecognizer(swipeLeftRec)
        
        tapRec2.addTarget(self, action:#selector(GameScene.tappedView2(_:) ))
        tapRec2.numberOfTouchesRequired = 1
        tapRec2.numberOfTapsRequired = 2  //2 taps instead of 1 this time
        self.view!.addGestureRecognizer(tapRec2)

        
        self.addChild(baseHex)
        
        var hexImage: SKSpriteNode
        for hex in hexagons {
            hexImage = hex.drawHexagon()
            
            self.addChild(hexImage)
        }
    }
    
    // function to call after a swipe right
    @objc
    func swipedRight() {
        if (!self.rotatingRight && !self.rotatingLeft) {
        self.rotatingRight = true
        self.rotationTimer = 1

        }
    }
    
    // function to call after a swipe left
    @objc
    func swipedLeft() {
        if (!self.rotatingRight && !self.rotatingLeft) {
        self.rotatingLeft = true
        self.rotationTimer = 1
        }
    }
    
    // catch a double tap.
    @objc
    func tappedView2(_ sender:UITapGestureRecognizer) {
        
        if gameOver {
            gameOver = false
            hexagons = Utils().initGenerateHexagons(width: self.frame.width, height: self.frame.height)
            baseHex = Utils().initGenerateBaseHex(width: self.frame.width, height: self.frame.height, rotation: 0)
            time = 0
            prevValue = 0
            rotationTimer = 0
            score = 0
            rotatingRight = false
            rotatingLeft = false
            
            for child in self.children {
                child.removeFromParent()
            }
            self.addChild(baseHex)
            
            var hexImage: SKSpriteNode
            for hex in hexagons {
                hexImage = hex.drawHexagon()
                
                self.addChild(hexImage)
            }
            
        }
        
    }
    
    // Update the game, attempts 60fps
    override func update(_ currentTime: TimeInterval) {

        // if the game isnt over, update normally
        if (!self.gameOver) {
            // increase time accumulator
            self.time += 1
            // if rotating, continue rotation
            if self.rotationTimer == 1 {
                self.rotationTimer += 1
                for hex in hexagons {
                    if hex.height > 20 {
                        if rotatingLeft {
                            hex.rotatingLeft = true
                            hex.rotateRight()
                        } else if rotatingRight {
                            hex.rotatingRight = true
                            hex.rotateLeft()
                        }
                    }
                }
                // increment the rotation timer
            } else if self.rotationTimer > 1 && self.rotationTimer <= 10 {
                self.rotationTimer += 1
                // stop the rotation
            } else if self.rotationTimer > 10 {
                self.rotatingRight = false
                self.rotatingLeft = false
                for hex in hexagons {
                        hex.rotatingLeft = false
                        hex.rotatingRight = false
                }
                self.rotationTimer = 0
            }
            // remove the children
            for child in self.children {
                child.removeFromParent()
            }
            // use the rotation timer to rotate left
            if self.rotatingLeft {
                var temp = (Double)(self.rotationTimer)
                temp = temp * -1 / 10 + 0.1
                baseHex = Utils().initGenerateBaseHex(width: self.frame.width, height: self.frame.height, rotation: temp)
            }
            // use the rotation timer to rotate right
            if self.rotatingRight {
                var temp = (Double)(self.rotationTimer)
                temp = temp / 10 - 0.1
                baseHex = Utils().initGenerateBaseHex(width: self.frame.width, height: self.frame.height, rotation: temp)
            }
        
            // re-add the base image
            self.addChild(baseHex)
        
            //adding new hexagon every second
            if self.time == 60 {
                self.hexagons.append(Utils().fractalLogicGate(input: prevValue, width: self.frame.width, height: self.frame.height))
                self.time = 1
            }

            // call update hexagons and readd them as children
            var hexImage: SKSpriteNode
            for hex in hexagons {
            
                let result = hex.updateHexagon()
            
                if (result == 1) {
                    self.prevValue = Int(round(hex.value))
                    hexagons.removeFirst()
                    self.score += 1
                } else if (result == 3){
                    self.gameOver = true
                
                } else {
            
                    hexImage = hex.drawHexagon()
     
                    self.addChild(hexImage)
                }
            }
            
            // adding score label
            let scoreBox = SKShapeNode(rectOf: CGSize(width: 100, height: 100))
            scoreBox.fillColor = UIColor.darkGray
            scoreBox.position = CGPoint(x: 150, y: frame.maxY - 120)
            
            let score = SKLabelNode(fontNamed: "Arial")
            score.text = String(self.score)
            score.fontSize = 65
            score.fontColor = SKColor.red
            score.position = CGPoint(x: 150, y: frame.maxY - 145)
            
            self.addChild(scoreBox)
            self.addChild(score)
            
            
        }
        
        // game is over, set up game over screen
        else {
            for child in self.children {
                child.removeFromParent()
            }
            
            // calculate if new score is high score
            if score > highScore {
                self.highScore = self.score
            }
            
            // add game over text and play again text
            let loser = SKLabelNode(fontNamed: "Arial")
            loser.text = "Game Over"
            loser.fontSize = 65
            loser.fontColor = SKColor.red
            loser.position = CGPoint(x: frame.midX, y: frame.midY + 100)
            
            let playAgain = SKLabelNode(fontNamed: "Arial")
            playAgain.text = "Double tap to restart"
            playAgain.fontSize = 35
            playAgain.fontColor = SKColor.lightGray
            playAgain.position = CGPoint(x: frame.midX, y: frame.midY - 100)
            
            let box = SKShapeNode(rectOf: CGSize(width: frame.maxX, height: 500))
            box.fillColor = UIColor.black
            box.position = CGPoint(x: frame.midX, y: frame.midY)
            
            
            let score = SKLabelNode(fontNamed: "Arial")
            score.text = "Score: " + String(self.score) + " High Score: " + String(self.highScore)
            score.fontSize = 45
            score.fontColor = SKColor.white
            score.position = CGPoint(x: frame.midX, y: frame.midY)
            
            self.addChild(box)
            self.addChild(loser)
            self.addChild(playAgain)
            self.addChild(score)
        }
    }

}

// represents a triagle section of the full hexagon gate
class Triangle {
    var sideLength: CGFloat
    var gate: Bool
    var position: Double
    var anchorPoint: CGPoint
    
    var gateColor = UIColor(red: 0.68, green: 0.33, blue: 0.0, alpha: 1.0)
    
    // default constructor
    init(sideLength: CGFloat, gate: Bool, position: Double, anchorPoint: CGPoint) {
        self.sideLength = sideLength
        self.gate = gate
        self.position = position
        self.anchorPoint = anchorPoint
    }
    
    // draws this triangle as an skspritenode
    public func drawTriangle() -> SKSpriteNode {
        // Sprite node accumulator
        let final = SKSpriteNode()
        
        // determine angles and points of the triangle
        let angle_deg1: Double = (Double)(60 * position)
        let angle_deg2: Double = (Double)(60 * (position + 1))
        
        let angle_rad1: CGFloat = (CGFloat)(Double.pi / 180 * angle_deg1)
        let angle_rad2: CGFloat = (CGFloat)(Double.pi / 180 * angle_deg2)
        
        let ptA = CGPoint(x: anchorPoint.x + sideLength * cos(angle_rad1), y: anchorPoint.y + sideLength * sin(angle_rad1))
        let ptB = CGPoint(x: anchorPoint.x + sideLength * cos(angle_rad2), y: anchorPoint.y + sideLength * sin(angle_rad2))
        
        
        let triangle = SKShapeNode()
        let path = UIBezierPath()
        
        // set cg path
        path.move(to: ptA)
        path.addLine(to: ptB)

        // set triangle based on path
        triangle.path = path.cgPath
        triangle.lineWidth = sideLength / (CGFloat)(100)
        triangle.strokeColor = UIColor.black
        
        // add triangle to acc
        final.addChild(triangle)
        
        // if there is a gate on this triangle, add it to the sksprite acc
        if (self.gate) {
            let path2 = UIBezierPath()
            let ptC = CGPoint(x: anchorPoint.x + (3/4) * sideLength * cos(angle_rad2), y: anchorPoint.y + (3/4) * sideLength * sin(angle_rad2))
            let ptD = CGPoint(x: anchorPoint.x + (3/4) * sideLength * cos(angle_rad1), y: anchorPoint.y + (3/4) * sideLength * sin(angle_rad1))
            let gate = SKShapeNode()
            path2.move(to: ptA)
            path2.addLine(to: ptB)
            path2.addLine(to: ptD)
            
            path2.move(to: ptB)
            path2.move(to: ptC)
            path2.addLine(to: ptD)
            path2.addLine(to: ptB)
            
            gate.path = path2.cgPath
            gate.fillColor = self.gateColor
            
            final.addChild(gate)
        }
        
        
        // return acc
        return final
        
    }

}

// represents a hexagonal gate, has 6 triangles
class Hexagon {
    var triangles: [Triangle]
    var height: CGFloat
    var triangleSideLength: CGFloat
    var value: Double
    var center: CGPoint
    var screenHeight: CGFloat
    var rotatingRight: Bool
    var rotatingLeft: Bool
    
    
    var position = 3
    // constructor
    init(height: CGFloat, value: Double, screenWidth: CGFloat, screenHeight: CGFloat) {
        
        let tsl = height / sqrt(3)
        let ctr = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        
        self.height = height
        self.screenHeight = screenHeight
        self.triangleSideLength = tsl
        self.value = value
        self.center = ctr
        self.rotatingRight = false
        self.rotatingLeft = false
        self.triangles = [Triangle]()
        self.triangles = initGenerateTriangles(triangleSideLength: tsl, center: ctr)
    }
    // generate the six triangles
    func initGenerateTriangles(triangleSideLength: CGFloat, center: CGPoint) -> [Triangle] {
        
        var triangles = [Triangle]()
        var triangle: Triangle
        for n in 1...6 {
            triangle = Triangle(sideLength: triangleSideLength, gate: false, position: (Double)(n), anchorPoint: center)
            triangles.append(triangle)
        }
        
        return triangles
    }
    
    
    
    // draws this hexagon as an sksprite node
    public func drawHexagon() -> SKSpriteNode {
        let hex = SKSpriteNode()
        // iterate through the triangles
        for n in 0...5 {
            hex.addChild(triangles[n].drawTriangle())
        }
        
        return hex
        
    }
    
    // moves the hexagon forward and returns the status
    public func updateHexagon() -> Int {

        // move forward by making larger
        self.height += (height + 4) / 30
        let tsl = height / sqrt(3)
        for triangle in triangles {
            triangle.sideLength = tsl
            // rotate if necessary
            if rotatingRight {
                triangle.position += 0.1
            } else if rotatingLeft {
                triangle.position -= 0.1
            } else {

            }
        }

        // check if player has passed this hexagon
        if height >= screenHeight {
            // check if player has hit a gate
            if triangles[position].gate {
                return 3
            }
            // player has not hit a gate
            return 1
            
        } else {
            // player has yet to hit this hexagon
            return 2
        }

    }
    
    // rotate this hexagon to the right, shift gate inputs
    public func rotateRight() {

        value += 1
        
        if value == 7 {
            value = 1
        }
        
        
        position += 1
        
        if position == 6 {
            position = 0
        }


    }
    // rotate this hexagon to the left, shift gate inputs
    public func rotateLeft() {
        value -= 1
        if value == 0 {
            value = 6
        }
        
        
        position -= 1
        if position == -1 {
            position = 5
        }
        
    }

}


// utility class
class Utils {
    
    // generate hexagons when the game starts with random position values
    func initGenerateHexagons(width: CGFloat, height: CGFloat) -> [Hexagon] {
        var hexagons = [Hexagon]()
        var hexagon: Hexagon
        
        hexagon = Hexagon(height: 1, value: (Double)(Int.random(in: 1...6)), screenWidth: width, screenHeight: height)
        hexagons.append(hexagon)

        
        return hexagons
    }
    
    // generate the base background hexagon image
    func initGenerateBaseHex(width: CGFloat, height: CGFloat, rotation: Double) -> SKSpriteNode {
        let base = SKSpriteNode()

        let path = UIBezierPath()
        
        let sideLength = height * (CGFloat)(sqrt(3.0))
        let ctr = CGPoint(x: width/2, y: height/2)
        
        for n in 1...6 {
            
            let curLine = SKShapeNode()
            
            let angle_deg1: Double = (Double)(60 * ((Double)(n) + rotation))
            
            let angle_rad1: CGFloat = (CGFloat)(Double.pi / 180 * angle_deg1)
            
            let ptA = CGPoint(x: ctr.x + sideLength * cos(angle_rad1), y: ctr.y + sideLength * sin(angle_rad1))
            
            path.move(to: ptA)
            path.addLine(to: ctr)
            
            curLine.path = path.cgPath
            curLine.lineWidth = 1
            curLine.strokeColor = UIColor.black
            
            base.addChild(curLine)
        }
        
        return base
    }
    
    // takes the user input from the hexagon that was passed, uses that value to determine the next obstacle arrangement
    func fractalLogicGate(input: Int, width: CGFloat, height: CGFloat) -> Hexagon {
        let hex = Hexagon(height: 1, value: (Double)(Int.random(in: 1...6)), screenWidth: width, screenHeight: height)
        
        
        if input == 1 {
            hex.triangles[0].gate = true
            hex.triangles[4].gate = true
            hex.triangles[3].gate = true
        }
        if input == 2 {
            hex.triangles[3].gate = true
            hex.triangles[5].gate = true
            hex.triangles[2].gate = true
        }
        if input == 3 {
            hex.triangles[1].gate = true
            hex.triangles[3].gate = true
            hex.triangles[5].gate = true
            hex.triangles[4].gate = true
            hex.triangles[2].gate = true
        }
        if input == 4 {
            hex.triangles[1].gate = true
            hex.triangles[2].gate = true
            hex.triangles[3].gate = true
        }
        if input == 5 {
            hex.triangles[0].gate = true
            hex.triangles[2].gate = true
            hex.triangles[3].gate = true
            hex.triangles[4].gate = true
        }
        if input == 6 {
            hex.triangles[1].gate = true
            hex.triangles[2].gate = true
            hex.triangles[4].gate = true
            hex.triangles[5].gate = true
        }
        
        return hex
    }

}




