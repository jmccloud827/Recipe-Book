import SwiftUI
import SwiftData

struct FancyHeader<Content: View, Label: View, Background: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let title: String
    @ViewBuilder let content: () -> Content
    @ViewBuilder let label: () -> Label
    @ViewBuilder let background: () -> Background
    
    @State private var baseline = 0.0
    @State private var isShowingNavBar = true
    @State private var isAboveBaseline = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                
                content()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onScrollGeometryChange(for: Double.self) { geo in
            geo.contentOffset.y
        } action: { _, newValue in
            if baseline == 0.0 {
                baseline = newValue
            }
            
            isAboveBaseline = newValue > baseline
        }
        .onScrollGeometryChange(for: Bool.self) { geo in
            geo.contentOffset.y > 200
        } action: { _, newValue in
            withAnimation {
                isShowingNavBar = newValue
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .bold()
                    .opacity(isShowingNavBar ? 1 : 0)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder private var header: some View {
        Section {} header: {
            Group {
                if #available(iOS 26.0, *) {
                    ZStack {
                        image
                        
                        titleView
                            .foregroundStyle(.foreground.opacity(0.7))
                    }

                } else {
                    titleView
                        .foregroundStyle(.foreground)
                }
            }
        }
    }
    
    @ViewBuilder private var image: some View {
        background()
            .stretchy()
    }
    
    private var titleView: some View {
        VStack {
            Spacer()
            
            let label =
                label()
                .padding(.horizontal)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, alignment: .bottom)
            
            if #available(iOS 26.0, *) {
                label
                    .background {
                        ZStack(alignment: .top) {
                            Rectangle()
                                .foregroundStyle(.thinMaterial)
                                .mask(LinearGradient(gradient: Gradient(colors: [colorScheme == .light ? .white : .black, .clear]), startPoint: .bottom, endPoint: .top))
                                
                            Rectangle()
                                .foregroundStyle(Gradient(colors: [.clear, colorScheme == .light ? .white : .black]))
                                .opacity(0.5)
                        }
                    }
            } else {
                label
            }
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        .animation(.none, value: UUID())
    }
}

extension View {
    func stretchy() -> some View {
        visualEffect { effect, geometry in
            let currentHeight = geometry.size.height
            let scrollOffset = geometry.frame(in: .scrollView).minY
            let positiveOffset = max(0, scrollOffset)
            
            let newHeight = currentHeight + positiveOffset
            let scaleFactor = newHeight / currentHeight
            
            return effect.scaleEffect(
                x: scaleFactor, y: scaleFactor,
                anchor: .bottom
            )
        }
    }
}

#Preview {
    NavigationStack {
        ViewRecipe(recipe: .palaminoSauce)
    }
}
