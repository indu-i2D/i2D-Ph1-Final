//
//  Double+Extension.swift
//  i2-Donate
//
//  Created by Emile Milot on 14/08/23.
//  Copyright © 2023 Im043. All rights reserved.
//

import Foundation

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
