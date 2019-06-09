//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Pavel on 6/8/19.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import RealmSwift

class Place: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?



    let restaurantNames = [
            "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
            "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
            "Speak Easy", "Morris Pub", "Вкусные истории",
            "Классик", "Love&Life", "Шок", "Бочка"
        ]

    func savePlaces() {

        for place in restaurantNames  {

            let image = UIImage(named: place)
            guard let imageData = image?.pngData() else { return }

            let newPlace = Place()

            newPlace.name = place
            newPlace.location = "Kyiv"
            newPlace.type = "Caffe"
            newPlace.imageData = imageData

            StorageManager.saveObject(newPlace)


        }

    }




}
