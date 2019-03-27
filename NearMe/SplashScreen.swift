//
//  SplashScreen.swift
//  NearMe
//
//  Created by aliazam on 27/3/19.
//  Copyright © 2019 sebpo. All rights reserved.
//

import UIKit

class SplashScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        perform(Selector("showMainMap"), with: nil, afterDelay: 3)
    }
    
    func showMainMap(){
        performSegue(withIdentifier: "showSplashScreen", sender: self)
    }

}
