//
//  String+AddText.swift
//  MyLocations
//
//  Created by Donald Lee on 2015-05-12.
//  Copyright (c) 2015 mylocations. All rights reserved.
//

extension String {
    mutating func addText(text: String?, withSeparator separator: String = "") {
    self += separator
    if let text = text {
        if !isEmpty {
            self += separator
        }
    self += text }
    }
}