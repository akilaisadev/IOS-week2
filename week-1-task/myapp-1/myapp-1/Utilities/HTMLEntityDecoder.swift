//
//  HTMLEntityDecoder.swift
//  myapp-1
//
//  A simple utility to decode common HTML entities returned by web APIs like OpenTDB.
//

import Foundation

struct HTMLEntityDecoder {
    
    // Decodes common HTML entities found in trivia questions and answers.
    static func decode(_ string: String) -> String {
        var result = string
        
        // Dictionary mapping common HTML entity codes to their string characters.
        let entities: [String: String] = [
            "&quot;": "\"",
            "&#039;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&eacute;": "é",
            "&lrm;": "",
            "&rrm;": ""
        ]
        
        // Replace each entity with its decoded character.
        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        
        return result
    }
}
