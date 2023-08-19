//
//  UserModels.swift created on 8/2/23.
//

import Foundation
import SwiftUI

public struct UserData {
    var uid: String
    var name: String
    var firstName: String
    var lastName: String
    var profileImage: UIImage?
    var friends: [String]
}

public struct UserDocument: Codable {
    var firstName: String
    var lastName: String
    var friends: [String]
}
