import SwiftUI
import Foundation
import FirebaseFirestore

struct ProfileCompletionView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var selectedRole: UserRole = .clientAdult
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    @EnvironmentObject var authViewModel: UserAuthViewModel
    
    private let roles: [UserRole] = [.clientAdult, .clientChild]
    
    var body: some View {
        VStack {
            Text("Complete Your Profile")
                .font(.largeTitle)
                .bold()
                .padding()
            
            TextField("First Name", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Last Name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .keyboardType(.phonePad)
            
            TextField("Street", text: $street)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("City", text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("State", text: $state)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Zip Code", text: $zipCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .keyboardType(.numberPad)
            
            Picker("Tutoring is for", selection: $selectedRole) {
                Text("Tutoring is for myself").tag(UserRole.clientAdult)
                Text("Tutoring is for my child").tag(UserRole.clientChild)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: saveProfile) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Save Profile")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .disabled(isLoading)
            
            Spacer()
        }
        .padding()
    }
    
    private func saveProfile() {
        guard let user = authViewModel.user else { return }
        isLoading = true
        errorMessage = nil
        
        let updatedUser = UserModel(
            id: user.uid,
            firstName: firstName,
            lastName: lastName,
            email: user.email ?? "",
            phoneNumber: phoneNumber,
            stripeCustomerId: "", // This should be generated later when integrating Stripe
            role: selectedRole,
            address: Address(street: street, city: city, state: state, zipCode: zipCode)
        )
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData(try! updatedUser.asDictionary(), merge: true) { error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    // Navigate to the main app screen after successful completion
                }
            }
        }
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String: Any]
    }
}

struct ProfileCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileCompletionView().environmentObject(UserAuthViewModel())
    }
}
