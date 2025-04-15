import SwiftUI

struct TextInputField: View {
    @Binding var text: String
    let label: String
    
    @State private var previousText: String
    
    init(text: Binding<String>, label: String) {
        _text = text
        self.label = label
        self.previousText = text.wrappedValue
    }
    
    var body: some View {
        NavigationLink {
            TextInput(text: $text, previousText: $previousText, label: label)
        } label: {
            LabeledContent {
                if text.isEmpty {
                    Text(previousText)
                } else {
                    Text(text)
                }
            } label: {
                Text(label)
            }
        }
    }
}

private struct TextInput: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var text: String
    @Binding var previousText: String
    let label: String
    
    @FocusState private var focus: Bool
    
    init(text: Binding<String>, previousText: Binding<String>, label: String) {
        _text = text
        _previousText = previousText
        self.label = label
    }
    
    var body: some View {
        List {
            HStack {
                TextField(previousText, text: $text)
                    .focused($focus)
                    .onSubmit {
                        dismiss()
                    }
                
                Spacer()
                
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(UIColor.systemGray3))
                }
                .buttonStyle(.plain)
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
        .onDisappear {
            if text.isEmpty {
                text = previousText
            } else {
                previousText = text
            }
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    
    NavigationStack {
        List {
            TextInputField(text: $text, label: "Test")
        }
    }
}
