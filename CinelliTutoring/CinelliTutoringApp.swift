//
//  CinelliTutoringApp.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 2/22/25.
//

import SwiftUI
import Firebase

@main
struct CinelliTutoringApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
