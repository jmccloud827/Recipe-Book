import SwiftUI

struct TextInputField: View {
    let text: String
    let label: String
    let onChange: (String) -> Void
    
    @State private var tempText: String
    @State private var previousText: String
    @State private var didChange = false
    
    init(text: String, label: String, onChange: @escaping (String) -> Void) {
        self.text = text
        self.label = label
        self.tempText = text
        self.previousText = text
        self.onChange = onChange
    }
    
    var body: some View {
        NavigationLink {
            TextInputFieldDestination(text: $tempText,
                                      previousText: $previousText,
                                      didChange: $didChange,
                                      label: label)
        } label: {
            HStack {
                Text(label)
                    
                Spacer()
                    
                Group {
                    if text.isEmpty {
                        Text(previousText)
                            .foregroundStyle(.gray)
                    } else {
                        Text(tempText)
                    }
                }
                .lineLimit(1)
            }
        }
        .onChange(of: didChange) {
            onChange(tempText)
        }
        .onChange(of: text) {
            tempText = text
            previousText = text
        }
    }
}

private struct TextInputFieldDestination: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var text: String
    @Binding var previousText: String
    @Binding var didChange: Bool
    let label: String
    
    @FocusState private var focus: Bool
    
    var body: some View {
        List {
            HStack {
                TextField(previousText, text: $text)
                    .focused($focus)
                    .onSubmit {
                        dismiss()
                    }
                
                Spacer()
                
                clearButton
                    .opacity(text.isEmpty ? 0.0 : 1.0)
                    .scaleEffect(text.isEmpty ? 0.7 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: UUID())
            }
        }
        .navigationTitle(label)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            focus = true
        }
        .onDisappear(perform: onDisappear)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                confirmButton
            }
        }
    }
    
    private var clearButton: some View {
        Button("Clear", systemImage: "xmark.circle.fill") {
            text = ""
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color(UIColor.systemGray3))
        .labelStyle(.iconOnly)
    }
    
    private var confirmButton: some View {
        Button(role: .confirm) {
            dismiss()
        }
    }
    
    private func onDisappear() {
        didChange.toggle()
        previousText = text
    }
}

#Preview {
    @Previewable @State var text = ""
    
    NavigationStack {
        List {
            TextInputField(text: text, label: "Test") { text = $0 }
        }
    }
}
