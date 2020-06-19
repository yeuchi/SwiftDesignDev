//
//  Image+CoreDataProperties.swift
//  PersistenceLesson
//
//  Created by yeuchi on 6/19/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var title: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var tagLink: Tag?

}
