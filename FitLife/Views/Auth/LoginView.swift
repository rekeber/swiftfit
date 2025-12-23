import SwiftUI

struct LoginView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showingRegister = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 60)
                    
                    // Logo and Title
                    VStack(spacing: 16) {
                        Text("🏃‍♂️")
                            .font(.system(size: 80))
                        
                        Text("FitLife")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Inicia sesión para continuar")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Login Form
                    VStack(spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                TextField("Email", text: $email)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disabled(authViewModel.isLoading)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                if isPasswordVisible {
                                    TextField("Contraseña", text: $password)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .disabled(authViewModel.isLoading)
                                } else {
                                    SecureField("Contraseña", text: $password)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .disabled(authViewModel.isLoading)
                                }
                                
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                        .foregroundColor(.secondary)
                                }
                                .disabled(authViewModel.isLoading)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Login Button
                        Button(action: {
                            authViewModel.login(email: email.trimmingCharacters(in: .whitespaces), password: password)
                        }) {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Iniciar Sesión")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                (email.isEmpty || password.isEmpty || authViewModel.isLoading) ?
                                Color.gray : Color.blue
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                        
                        // Error Message
                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    // Register Link
                    Button(action: {
                        showingRegister = true
                    }) {
                        Text("¿No tienes cuenta? Regístrate")
                            .foregroundColor(.blue)
                            .font(.body)
                    }
                    .disabled(authViewModel.isLoading)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .sheet(isPresented: $showingRegister) {
            RegisterView()
        }
        .onAppear {
            authViewModel.clearError()
        }
    }
}

// MARK: - Helper Extension

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}