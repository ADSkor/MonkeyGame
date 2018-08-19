//
//  ViewController.swift
//  Monkey Game
//
//  Created by Aleksandr Skorotkin on 18.08.2018.
//  Copyright © 2018 Aleksandr Skorotkin. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var midleMonkey: UIImageView!
    
    @IBOutlet weak var monkeyRight: UIImageView!
    
    @IBOutlet weak var monkeyLeft: UIImageView!
    
    @IBOutlet weak var hPLabel: UILabel!
    
    @IBOutlet weak var bananaScore: UILabel!
    
    @IBOutlet weak var banana: UIImageView!
    
    @IBOutlet weak var dinamite: UIImageView!
    
    private enum Constants {
        static let bananaSize = CGSize(width: 75, height: 65)
        static let dynamiteSize = CGSize(width: 53, height: 83)
    }
    
    private var bananas = [UIView]()
    private var dynamites = [UIView]()
    
    private var isMonkeyInRight = false
    private var isMonkeyInLeft = false
    private var tempScore = 0
    private var score = 0
    private var hpCount = 3
    
    private var isPaused = false
    
    //MARK:- Tap Gesture
    
    override func viewDidLoad() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didRecognizeTap(_:)))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        score = UserDefaults.standard.integer(forKey: "score")
        bananaScore.text = "\(tempScore)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scheduleNewTimer(isLeft: true)
        scheduleNewTimer(isLeft: false)
    }
    
    @objc func didRecognizeTap(_ sender: UIGestureRecognizer) {
        if !isMonkeyInRight {
            monkeyRight.isHidden = false
            midleMonkey.isHidden = true
            monkeyLeft.isHidden = true
            isMonkeyInRight = true
            isMonkeyInLeft = false
        } else {
            monkeyRight.isHidden = true
            midleMonkey.isHidden = true
            monkeyLeft.isHidden = false
            isMonkeyInRight = false
            isMonkeyInLeft = true
        }
    }
    
    private func scheduleNewTimer(isLeft: Bool) {
        
        if isPaused {
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                guard let `self` = self else { return }
                self.scheduleNewTimer(isLeft: isLeft)
            }
            return
        }
        
        let timeInterval = randomDouble() * 3.0 + 1.0
        let createBanana = randomBool()
        let xOffset: CGFloat = isLeft ? 50.0 : 250.0 //тут можно экран поделить на части, но так понятнее пока что
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            
//            print("Timer: \(createBanana ? "banana" : "dynamite")")
            
            guard let `self` = self, let view = self.view else { return }
            
            if self.isPaused {
                self.scheduleNewTimer(isLeft: isLeft)
                return
            }
            
            let fallingView: UIView
            if createBanana {
                if self.bananas.isEmpty {
                    fallingView = UIImageView(image: #imageLiteral(resourceName: "Banana"))
                    view.addSubview(fallingView)
                } else {
                    fallingView = self.bananas.removeLast()
                    fallingView.isHidden = false
                }
                
                var rect = view.bounds.divided(atDistance: xOffset, from: .minXEdge).remainder
                rect = rect.divided(atDistance: Constants.bananaSize.width, from: .minXEdge).slice
                rect = rect.divided(atDistance: Constants.bananaSize.height, from: .minYEdge).slice
                fallingView.frame = rect
            } else {
                if self.dynamites.isEmpty {
                    fallingView = UIImageView(image: #imageLiteral(resourceName: "Dinamite"))
                    view.addSubview(fallingView)
                } else {
                    fallingView = self.dynamites.removeLast()
                    fallingView.isHidden = false
                }
                
                var rect = view.bounds.divided(atDistance: xOffset, from: .minXEdge).remainder
                rect = rect.divided(atDistance: Constants.dynamiteSize.width, from: .minXEdge).slice
                rect = rect.divided(atDistance: Constants.dynamiteSize.height, from: .minYEdge).slice
                fallingView.frame = rect
            }
            view.setNeedsLayout()
            
            self.animate(fallingView: fallingView, isBanana: createBanana, isLeft: isLeft)
            self.scheduleNewTimer(isLeft: isLeft)
        }
    }
    
    private func viewDidFallToMonkey(isLeft: Bool, isBanana: Bool) -> Bool {
        if (isLeft && isMonkeyInLeft) || (!isLeft && isMonkeyInRight) {
            if isBanana {
                score += 1
                tempScore += 1
                bananaScore.text = "\(tempScore)"
            } else {
                hpCount -= 1
                if hpCount < 1 {
                    isPaused = true
                    let alert = UIAlertController(title: "Game over", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
                        self.hpCount = 3
                        self.hPLabel.text = "\(self.hpCount)"
                        self.isPaused = false
                        self.tempScore = 0
                        self.bananaScore.text = "\(self.tempScore)"
                    }))
                    alert.addAction(UIAlertAction(title: "Menu", style: .cancel, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    hPLabel.text = "\(hpCount)"
                }
            }
            return false
        }
        return true
    }
    
    private func animate(fallingView: UIView, isBanana: Bool, isLeft: Bool) {
        UIView.animate(withDuration: 2.0, delay: 0.0, options: [.curveLinear], animations: {
            fallingView.frame.origin.y = 350
        }, completion: { [weak self] finished in
            guard let `self` = self else { return }

            if self.viewDidFallToMonkey(isLeft: isLeft, isBanana: isBanana) {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear], animations: {
                    fallingView.frame.origin.y = 470
                }, completion: { _ in
                    fallingView.isHidden = true
                    if isBanana {
                        self.bananas.append(fallingView)
                    } else {
                        self.dynamites.append(fallingView)
                    }
                })
            } else {

                fallingView.isHidden = true
                if isBanana {
                    self.bananas.append(fallingView)
                } else {
                    self.dynamites.append(fallingView)
                }
            }
            
//            print("CHECK: \(finished)")
        })
    }
    
    private func randomDouble() -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF)
    }
    
    private func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(score, forKey: "score")
    }
}
