import SwiftUI

struct ContentView: View {
    @State private var showPasswordPrompt = false
    @State private var showSubmissions = false

    private let correctPassword = "1930"
    private let hint = "Home Phone Number"

    var body: some View {
        SignInFormView()
            .overlay(alignment: .topTrailing) {
                Button {
                    showPasswordPrompt = true
                } label: {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding(20)
                }
            }
            .sheet(isPresented: $showPasswordPrompt) {
                PasswordPromptView(
                    isPresented: $showPasswordPrompt,
                    showSubmissions: $showSubmissions,
                    correctPassword: correctPassword,
                    hint: hint
                )
                .presentationDetents([.height(360)])
                .presentationCornerRadius(20)
                .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $showSubmissions) {
                NavigationStack {
                    SubmissionsView()
                }
            }
    }
}

// MARK: - Password Prompt

private struct PasswordPromptView: View {
    @Binding var isPresented: Bool
    @Binding var showSubmissions: Bool
    let correctPassword: String
    let hint: String

    @State private var password = ""
    @State private var showError = false
    @State private var showHint = false
    @FocusState private var isFocused: Bool

    private var canUnlock: Bool { password.count >= 3 }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
                .padding(.top, 32)

            Text("Enter Password")
                .font(.title2.bold())

            SecureField("Password", text: $password)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title3)
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(showError ? Color.red.opacity(0.6) : Color(.separator), lineWidth: 0.5)
                )
                .padding(.horizontal, 40)
                .focused($isFocused)
                .onChange(of: password) { showError = false }
                .onSubmit { if canUnlock { tryUnlock() } }

            if showError {
                Text("Incorrect password. Please try again.")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                // reserve space so layout doesn't jump
                Text(" ").font(.caption)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button("Hint") {
                    showHint = true
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button("Unlock") {
                    tryUnlock()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!canUnlock)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
        .onAppear { isFocused = true }
        .alert("Password Hint", isPresented: $showHint) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(hint)
        }
    }

    private func tryUnlock() {
        if password == correctPassword {
            isPresented = false
            showSubmissions = true
        } else {
            showError = true
            password = ""
        }
    }
}
