import SwiftData
import SwiftUI

struct FancyHeader<Content: View, Label: View, Background: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let title: String
    let content: () -> Content
    @ViewBuilder let label: () -> Label
    @ViewBuilder let background: () -> Background
    
    @State private var headerYSize = 0.0
    @State private var safeAreaHeight = 0.0
    @State private var isShowingNavBar = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .foregroundStyle(.foreground.opacity(0.7))
                    .onGeometryChange(for: Double.self) { proxy in
                        proxy.size.height
                    } action: { newValue in
                        self.headerYSize = newValue
                    }
                    
                content()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onGeometryChange(for: Double.self) { proxy in
            proxy.safeAreaInsets.bottom
        } action: { newValue in
            safeAreaHeight = newValue + 78
        }
        .onScrollGeometryChange(for: Bool.self) { proxy in
            proxy.contentOffset.y - headerYSize + safeAreaHeight > 0
        } action: { _, newValue in
            self.isShowingNavBar = newValue
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .bold()
                    .opacity(isShowingNavBar ? 1 : 0)
                    .animation(.default, value: isShowingNavBar)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder private var header: some View {
        Section {} header: {
            ZStack {
                image
                
                titleView
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
            
            label()
                .padding(.horizontal)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, alignment: .bottom)
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
            
            return effect.scaleEffect(x: scaleFactor, y: scaleFactor,
                                      anchor: .bottom)
        }
    }
}

#Preview {
    NavigationStack {
        ViewRecipe(recipe: .palaminoSauce)
    }
}
