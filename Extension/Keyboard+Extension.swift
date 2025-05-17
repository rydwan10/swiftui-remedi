//
//  Keyboard+Extension.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 18/04/25.
//

import SwiftUI

struct KeyboardCloseButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Close") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                }
            }
    }
}

extension View {
    func withKeyboardCloseButton() -> some View {
        self.modifier(KeyboardCloseButtonModifier())
    }
}
