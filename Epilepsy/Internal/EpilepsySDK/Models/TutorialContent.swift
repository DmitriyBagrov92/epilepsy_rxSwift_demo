//
//  TutorialContent.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 19/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit

struct TutorialContent {
    
    let image: UIImage?
    
    let title: String
    
    let description: String
    
    let color: UIColor
    
    enum CodingKeys: String, CodingKey {
        case image
        case title
        case description
        case color
    }
    
}

// MARK: Decodable

extension TutorialContent: Decodable {

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let imageName = try values.decode(String.self, forKey: CodingKeys.image)
        self.image = UIImage(named: imageName)
        self.title = try values.decode(String.self, forKey: CodingKeys.title)
        self.description = try values.decode(String.self, forKey: CodingKeys.description)
        let colorHex = try values.decode(String.self, forKey: CodingKeys.color)
        self.color = UIColor.from(hex: colorHex)
    }

}
