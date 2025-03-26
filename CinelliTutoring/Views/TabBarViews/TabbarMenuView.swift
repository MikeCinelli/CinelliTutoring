//
//  TabBarMenuView.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/11/25.
//

import SwiftUI // This lets us use SwiftUI, a tool to build the app's interface


/// The main tab bar menu for the CinelliTutoring app.
/// This view provides navigation between booking, scheduled sessions, and profile management.
struct TabBarMenuView: View {
    
    // State variable to keep track of which tab is currently selected
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) { // TabView creates a tabbed navigation interface
            
            
            // Scheduled Sessions View Tab
            ScheduledSessionsView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Schedule")
                }
                .tag(1)
            
            // Profile View Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(2)
        }
        .accentColor(.blue) // Set the accent color of the tab bar
    }
}


/// Placeholder view for ScheduledSessionsView
struct ScheduledSessionsView: View {
    var body: some View {
        VStack {
            Text("Scheduled Sessions View")
                .font(.largeTitle)
                .padding()
            Text("This is where users will see their booked sessions.")
        }
    }
}

/// Placeholder view for ProfileView
struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Profile View")
                .font(.largeTitle)
                .padding()
            Text("This is where users will manage their profile.")
        }
    }
}

/// Preview provider to allow live previews in Xcode's canvas
struct TabBarMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarMenuView()
    }
}
