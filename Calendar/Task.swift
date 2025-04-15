//
//  Task.swift
//  Created by GaliSrikanth on 15/04/25.

import Foundation

struct Task: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
}
