//
//  UIColor.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/20.
//

import UIKit

extension UIColor {
    static func randomColor() -> UIColor {
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemPink, .systemTeal, .systemGreen, .systemYellow, .systemOrange]
        
        let randomColor = colors.randomElement()!
        return randomColor
    }
}
