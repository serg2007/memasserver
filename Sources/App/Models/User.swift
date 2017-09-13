//
//  User.swift
//  ImagesServer
//
//  Created by Sergiy Sobol on 12.09.17.
//
//

import Vapor
import FluentProvider
import AuthProvider
import HTTP

final class User: Model {
    let storage = Storage()
    
    /// The name of the user
    var name: String
    
    var imageUrl: String?
    
//    var userTagsIds: [Int64]?
    
    
    
    /// The user's email
    var email: String
    
    /// The user's _hashed_ password
    var password: String?
    
    /// Creates a new User
    init(name: String, email: String, password: String? = nil, imageUrl: String? = "") {
        self.name = name
        self.email = email
        self.password = password
        self.imageUrl = imageUrl
//        self.userTagsIds = userTagsIds
//        self.userPostsIds = userPostsIds
    }
    
    // MARK: Row
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        name = try row.get("name")
        email = try row.get("email")
        password = try row.get("password")
        imageUrl = try row.get("imageUrl")
//        userTagsIds = try row.get("userTagsIds")
//        userPostsIds = try row.get("userPostsIds")
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("email", email)
        try row.set("password", password)
        try row.set("imageUrl", imageUrl)
//        try row.set("userTagsIds", userTagsIds)
//        try row.set("userPostsIds", userPostsIds)
        return row
    }
}

// MARK: Preparation
extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Users
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("email")
            builder.string("password")
            builder.string("imageUrl")
//            builder.foreignKey("posts_id", references: "id", on: Post.self)
//            builder.string("userTagsIds")
//            builder.string("userPostsIds")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON
// How the model converts from / to JSON.
// For example when:
//     - Creating a new User (POST /users)
//
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            email: json.get("email")
        )
        id = try json.get("id")
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("email", email)
        return json
    }
}

// MARK: HTTP
// This allows User models to be returned
// directly in route closures
extension User: ResponseRepresentable { }

// MARK: Password
// This allows the User to be authenticated
// with a password. We will use this to initially
// login the user so that we can generate a token.
extension User: PasswordAuthenticatable {
    var hashedPassword: String? {
        return password
    }
    
    public static var passwordVerifier: PasswordVerifier? {
        get { return _userPasswordVerifier }
        set { _userPasswordVerifier = newValue }
    }
}

// store private variable since storage in extensions
// is not yet allowed in Swift
private var _userPasswordVerifier: PasswordVerifier? = nil

// MARK: Request
extension Request {
    /// Convenience on request for accessing
    /// this user type.
    /// Simply call `let user = try req.user()`.
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}

// MARK: Token
// This allows the User to be authenticated
// with an access token.
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User {
    func posts() throws -> Children<User, Post> {
        return try children()
    }
}
