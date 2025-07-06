//
//  ShareViewController.swift
//  Share Extension
//
//  Created by Oyale Peter on 15/03/2025.
//

import receive_sharing_intent

class ShareViewController: RSIShareViewController {
      
    // Use this method to return false if you don't want to redirect to host app automatically.
    // Default is true
    override func shouldAutoRedirect() -> Bool {
        return false
    }
    
}
