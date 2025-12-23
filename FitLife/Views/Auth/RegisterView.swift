import SwiftUI

struct RegisterView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // Form fields
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var age = ""
    @State private var height = ""
    @State private var currentWeight = ""
    @State private var targetWeight = ""
    @State private var goal = "PERDER_PESO"
    @State private var activityLevel = "MODERADO"
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    private let goals = [
        ("PERDER_PESO", "Perder peso"),
        ("MANTENER", "Mantener peso"),
        ("GANAR_MUSCULO", "Ganar músculo")
    ]
    
    private let activityLevels = [
        ("SEDENTARIO", "Sedentario"),
        ("LIGERO", "Ligero"),
        ("MODERADO", "Moderado"),
        ("ACTIVO", "Activo"),
        ("MUY_ACTIVO", "Muy activo")
    ]
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        !age.isEmpty && Int(age) != nil &&
        !height.isEmpty && Double(height) != nil &&
        !currentWeight.isEmpty && Double(currentWeight) != nil &&
        !targetWeight.isEmpty && Double(targetWeight) != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("🏃‍♂️")
                            .font(.system(size: 60))
                        
                        Text("Crear Cuenta")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Completa tus datos para comenzar")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Personal Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Información Personal")
                        
                        CustomTextField(
                            icon: "person",
                            placeholder: "Nombre completo",
                            text: $name,
                            disabled: authViewModel.isLoading
                        )
                        
                        CustomTextField(
                            icon: "envelope",
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress,
                            disabled: authViewModel.isLoading
                        )
                        
                        CustomTextField(
                            icon: "calendar",
                            placeholder: "Edad",
                            text: $age,
                            keyboardType: .numberPad,
                            disabled: authViewModel.isLoading
                        )
                    }
                    
                    // Physical Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Información Física")
                        
                        HStack(spacing: 12) {
                            CustomTextField(
                                icon: "ruler",
                                placeholder: "Altura (cm)",
                                text: $height,
                                keyboardType: .decimalPad,
                                disabled: authViewModel.isLoading
                            )
                            
                            CustomTextField(
                                icon: "scalemass",
                                placeholder: "Peso (kg)",
                                text: $currentWeight,
                                keyboardType: .decimalPad,
                                disabled: authViewModel.isLoading
                            )
                        }
                        
                        CustomTextField(
                            icon: "target",
                            placeholder: "Peso objetivo (kg)",
                            text: $targetWeight,
                            keyboardType: .decimalPad,
                            disabled: authViewModel.isLoading
                        )
                        
                        // Goal Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Objetivo")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(goals, id: \.0) { goalValue, goalName in
                                    Button(action: {
                                        goal = goalValue
                                    }) {
                                        Text(goalName)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(goal == goalValue ? Color.blue : Color(.systemGray6))
                                            .foregroundColor(goal == goalValue ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                    .disabled(authViewModel.isLoading)
                                }
                            }
                        }
                        
                        // Activity Level Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nivel de Actividad")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(activityLevels, id: \.0) { levelValue, levelName in
                                    Button(action: {
                                        activityLevel = levelValue
                                    }) {
                                        Text(levelName)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(activityLevel == levelValue ? Color.blue : Color(.systemGray6))
                                            .foregroundColor(activityLevel == levelValue ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                    .disabled(authViewModel.isLoading)
                                }
                            }
                        }
                    }
                    
                    // Security Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Seguridad")
                        
                        CustomSecureField(
                            icon: "lock",
                            placeholder: "Contraseña",
                            text: $password,
                            isVisible: $isPasswordVisible,
                            disabled: authViewModel.isLoading
                        )
                        
                        CustomSecureField(
                            icon: "lock",
                            placeholder: "Confirmar contraseña",
                            text: $confirmPassword,
                            isVisible: $isConfirmPasswordVisible,
                            disabled: authViewModel.isLoading
                        )
                        
                        if !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Las contraseñas no coinciden")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    // Register Button
                    Button(action: {
                        authViewModel.register(
                            email: email.trimmingCharacters(in: .whitespaces),
                            password: password,
                            name: name.trimmingCharacters(in: .whitespaces),
                            age: Int(age) ?? 0,
                            height: Double(height) ?? 0,
                            currentWeight: Double(currentWeight) ?? 0,
                            targetWeight: Double(targetWeight) ?? 0,
                            goal: goal,
                            activityLevel: activityLevel
                        )
                    }) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Crear Cuenta")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid && !authViewModel.isLoading ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || authViewModel.isLoading)
                    
                    // Error Message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Login Link
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("¿Ya tienes cuenta? Inicia sesión")
                            .foregroundColor(.blue)
                            .font(.body)
                    }
                    .disabled(authViewModel.isLoading)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(authViewModel.isLoading)
            )
            .onTapGesture {
                hideKeyboard()
            }
        }
        .onAppear {
            authViewModel.clearError()
        }
        .onChange(of: authViewModel.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - Custom Components

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.primary)
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var disabled: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .disabled(disabled)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    var disabled: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            if isVisible {
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disabled(disabled)
            } else {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disabled(disabled)
            }
            
            Button(action: {
                isVisible.toggle()
            }) {
                Image(systemName: isVisible ? "eye" : "eye.slash")
                    .foregroundColor(.secondary)
            }
            .disabled(disabled)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}