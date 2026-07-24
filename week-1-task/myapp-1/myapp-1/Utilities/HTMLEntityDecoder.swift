//
//  HTMLEntityDecoder.swift
//  myapp-1
//
//  

import Foundation

struct HTMLEntityDecoder {
    
    static func decode(_ string: String) -> String {
        var result = string
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
        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        
        return result
    }
}
