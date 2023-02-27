//
//  SceneDelegate.swift
//  i2~Donate
//
//  Created by Apple on 23/12/22.
//  Copyright © 2022 Im043. All rights reserved.
//

import Foundation
import FBSDKCoreKit
  
@available(iOS 13.0, *)
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else {
        return
    }

    ApplicationDelegate.shared.application(
        UIApplication.shared,
        open: url,
        sourceApplication: nil,
        annotation: [UIApplication.OpenURLOptionsKey.annotation]
    )
}
