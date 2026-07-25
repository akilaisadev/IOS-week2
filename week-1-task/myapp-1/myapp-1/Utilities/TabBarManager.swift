import SwiftUI
import Combine

class TabBarManager: ObservableObject {
    static let shared = TabBarManager()
    @Published var isHidden = false
    
    func hide() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isHidden = true
        }
    }
    
    func show() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isHidden = false
        }
    }
}
