//
//  Category.swift
//  ToDo
//
//  Created by Liza Sapsaj on 9/7/21.
//


import Foundation
import RealmSwift


class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
}
