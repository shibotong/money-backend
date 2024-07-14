//
//  String+Extension.swift
//
//
//  Created by Shibo Tong on 14/7/2024.
//

import Foundation

extension String {
    var isOnlySpacesOrEmpty: Bool {
        // Check if the trimmed string is empty
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
