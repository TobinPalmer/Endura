import Foundation

public enum Roles: String, Codable {
    case ADMIN = "admin"
    case USER = "user"
}

public enum UserGender: String, Codable {
    case MALE = "male"
    case FEMALE = "female"
    case OTHER = "other"
}
