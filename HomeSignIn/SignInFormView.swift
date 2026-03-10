import SwiftUI

struct SignInFormView: View {
    @Environment(DataStore.self) private var store

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var hasAgent = false
    @State private var agentName = ""
    @State private var agentBrokerage = ""
    @State private var agentPhone = ""
    @State private var showThankYou = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    personalInfoSection
                    agentSection
                    submitButton
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 40)
                .frame(maxWidth: 720)
            }
            .frame(maxWidth: .infinity)
        }
        .alert("Thank You for Visiting!", isPresented: $showThankYou) {
            Button("Done") { }
        } message: {
            Text("Your information has been recorded. Enjoy touring the home!")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "house.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)
            Text("Welcome")
                .font(.system(size: 42, weight: .bold, design: .rounded))
            Text("Please sign in before your tour")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Personal Info

    private var personalInfoSection: some View {
        GroupBox {
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    FormField(label: "First Name", text: $firstName)
                    FormField(label: "Last Name", text: $lastName)
                }
                FormField(
                    label: "Phone Number",
                    text: $phone,
                    keyboard: .numberPad
                )
                FormField(
                    label: "Email Address",
                    text: $email,
                    keyboard: .default
                )
            }
            .padding(.vertical, 8)
        } label: {
            Label("Your Information", systemImage: "person.fill")
                .font(.headline)
        }
    }

    // MARK: - Agent Section

    private var agentSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Toggle("I am currently working with a real estate agent", isOn: $hasAgent)
                    .font(.body)
                    .tint(.blue)

                if hasAgent {
                    Divider()
                    FormField(label: "Agent's Full Name", text: $agentName)
                    FormField(label: "Brokerage / Company", text: $agentBrokerage)
                    FormField(
                        label: "Agent's Phone Number",
                        text: $agentPhone,
                        keyboard: .numberPad
                    )
                }
            }
            .padding(.vertical, 8)
            .animation(.easeInOut(duration: 0.25), value: hasAgent)
        } label: {
            Label("Real Estate Agent", systemImage: "briefcase.fill")
                .font(.headline)
        }
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button(action: submit) {
            Text("Save")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        .padding(.bottom, 20)
    }

    // MARK: - Actions

    private func submit() {
        let visitor = Visitor(
            firstName: firstName.trimmed,
            lastName: lastName.trimmed,
            phone: phone.trimmed,
            email: email.trimmed,
            hasAgent: hasAgent,
            agentName: agentName.trimmed,
            agentBrokerage: agentBrokerage.trimmed,
            agentPhone: agentPhone.trimmed,
            timestamp: Date()
        )
        store.add(visitor)
        resetForm()
        showThankYou = true
    }

    private func resetForm() {
        firstName = ""
        lastName = ""
        phone = ""
        email = ""
        hasAgent = false
        agentName = ""
        agentBrokerage = ""
        agentPhone = ""
    }
}

// MARK: - FormField

private struct FormField: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            NoAutofillTextField(
                placeholder: label,
                text: $text,
                keyboardType: keyboard
            )
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
        }
        .frame(maxWidth: .infinity)
    }

}

// MARK: - NoAutofillTextField

private struct NoAutofillTextField: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    func makeUIView(context: Context) -> _NoAutofillUITextField {
        let field = _NoAutofillUITextField()
        field.placeholder = nil
        field.keyboardType = keyboardType
        field.autocorrectionType = .no
        field.autocapitalizationType = (keyboardType == .numberPad) ? .none : .words
        field.textContentType = nil
        field.spellCheckingType = .no
        field.smartQuotesType = .no
        field.smartDashesType = .no
        field.font = UIFont.preferredFont(forTextStyle: .body)
        field.delegate = context.coordinator
        field.addTarget(context.coordinator, action: #selector(Coordinator.textChanged), for: .editingChanged)
        if #available(iOS 17, *) {
            field.inlinePredictionType = .no
        }
        return field
    }

    func updateUIView(_ uiView: _NoAutofillUITextField, context: Context) {
        if uiView.text != text { uiView.text = text }
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }

        @objc func textChanged(_ field: UITextField) {
            text = field.text ?? ""
        }
    }
}

// Subclass ensures inputAssistantItem stays empty even if iOS tries to repopulate it
final class _NoAutofillUITextField: UITextField {
    override var inputAssistantItem: UITextInputAssistantItem {
        let item = super.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        return item
    }
}
