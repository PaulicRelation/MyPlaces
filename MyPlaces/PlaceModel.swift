//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Pavel on 6/8/19.
//  Copyright © 2019 Pavel. All rights reserved.
//

import Foundation

struct Place {
    var name: String
    var location: String
    var type: String
    var image: String

    static  let restaurantNames = [
            "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
            "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
            "Speak Easy", "Morris Pub", "Вкусные истории",
            "Классик", "Love&Life", "Шок", "Бочка"
        ]

   static func getPlaces() ->[Place] {

        var places = [Place]()
        for place in restaurantNames  {
            places.append(Place(name: place, location: "Kyiv", type: "Caffe", image: place))
        }
    return places

    }




}
