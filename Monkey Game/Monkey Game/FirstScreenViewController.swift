//
//  FirstScreenViewController.swift
//  Monkey Game
//
//  Created by Aleksandr Skorotkin on 18.08.2018.
//  Copyright © 2018 Aleksandr Skorotkin. All rights reserved.
//

import UIKit

class FirstScreenViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let score = UserDefaults.standard.integer(forKey: "score")
        scoreLabel.text = "\(String(describing: score))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func game2ButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Game is locked!", message: "Unlock it by getting 500 Bananas", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func game3ButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Game is locked!", message: "Unlock it by getting 1000 Bananas", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
