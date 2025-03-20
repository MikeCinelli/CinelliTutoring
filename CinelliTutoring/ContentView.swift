//
//  ContentView.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 2/22/25.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    let db = Firestore.firestore()

    var body: some View {
        VStack {
            Text("Firestore Test")
                .font(.title)
                .padding()
            Button("Add Test Data") {
                addTestData()
            }
        }
    }

    func addTestData() {
        let testRef = db.collection("testCollection").document("testDoc")
        testRef.setData(["message": "Hello, Firestore!"]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}

#Preview {
    ContentView()
}
