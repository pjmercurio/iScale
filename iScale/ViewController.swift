//
//  ViewController.swift
//  iScale
//
//  Created by Paul Mercurio on 5/31/16.
//  Copyright © 2016 Paul Mercurio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var tareWeights: [Float] = [0.0, 0.0, 0.0, 0.0];
    var weights: [Float] = [0.0, 0.0, 0.0, 0.0];
    let units = ["mg", "g", "Oz", "Lbs"];
    let labels = [["",""], ["180", "360"], ["6.5", "13"], ["0.4", "0.8"]];
    var segIndex: Int = 0;

    
    @IBOutlet weak var halfwayLabel: UILabel!
    @IBOutlet weak var fullwayLabel: UILabel!
    @IBOutlet weak var tareButton: UIButton!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var unitSelector: UISegmentedControl!
    @IBOutlet weak var needle: UIImageView!
    @IBAction func unitChanged(sender: AnyObject) {
        segIndex = unitSelector.selectedSegmentIndex;
        weightLabel.text = "\(weights[segIndex]) \(units[segIndex])";
        halfwayLabel.text = labels[segIndex][0];
        fullwayLabel.text = labels[segIndex][1];
    }
    @IBAction func tare(sender: AnyObject) {
        tareWeights[0] = weights[0];
        tareWeights[1] = weights[1];
        tareWeights[2] = weights[2];
        tareWeights[3] = weights[3];
        weightLabel.text = "0.0 \(units[unitSelector.selectedSegmentIndex])";
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // SET STATUS BAR TO BE LIGHT THEME
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    // Adjust weight as it changes
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if (touch.view != tareButton) {
                if traitCollection.forceTouchCapability == UIForceTouchCapability.Available { // See if device supports force touch
                    if touch.force >= touch.maximumPossibleForce { // Max weight exceeded
                        weightLabel.text = "ERROR";
                        weightLabel.textColor = UIColor.redColor();
                    }
                    else {
                        needle.layer.removeAnimationForKey("transform.rotation.z");
                        
                        let force = touch.force/touch.maximumPossibleForce;
                        let grams = force * 385;
                        
                        weights[0] = Float(round(grams*100))*10;
                        weights[1] = Float(round(grams*100))/100;
                        weights[2] = Float(round((grams*0.035274)*100))/100;
                        weights[3] = Float(round((grams*0.00220462)*100))/100;
                        
                        weightLabel.text = "\(weights[segIndex] - tareWeights[segIndex]) \(units[segIndex])";
                        weightLabel.textColor = UIColor.greenColor();
                        
                        needle.transform = CGAffineTransformMakeRotation(CGFloat(force*5.0));
                    }
                }
            }
        }
    }
    
    // Nothing on the scale anymore, reset all values
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if (touch.view != tareButton) {
                
                if (weights[1] > 250) { // Don't want needle to take the "shortcut route" back
                    let animation = CAKeyframeAnimation.init(keyPath: "transform.rotation.z");
                    animation.duration = 1.0;
                    animation.removedOnCompletion = false;
                    animation.cumulative = false;
                    animation.fillMode = kCAFillModeForwards;
                    
                    animation.values = [(weights[1]/385)*5,(weights[1]/385)*2.5,0.0];
                    animation.keyTimes = [0.0,0.5,1.0];
                    animation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear), CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)];
                    needle.layer.addAnimation(animation, forKey: "transform.rotation.z");
                }
                else {
                    UIView.animateWithDuration(1.0, animations: {
                        self.needle.transform = CGAffineTransformMakeRotation(0.0);
                    })
                }
                
                weightLabel.text = "0.0 \(units[segIndex])";
                weightLabel.textColor = UIColor.whiteColor();
                weights = [0.0, 0.0, 0.0, 0.0];
                tareWeights = [0.0, 0.0, 0.0, 0.0];
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

