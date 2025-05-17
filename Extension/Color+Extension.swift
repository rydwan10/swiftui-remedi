//
//  Color+Extension.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 13/04/25.
//

import SwiftUI

extension Color {
    /// Menghitung luminance untuk menentukan apakah warna terang atau gelap
    func isDark() -> Bool {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return false
        }
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        // Rumus luminance
        let luminance = (0.299 * red + 0.587 * green + 0.114 * blue)
        return luminance < 0.5
    }
}
