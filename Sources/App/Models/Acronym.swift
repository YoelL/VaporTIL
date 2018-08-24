
import Vapor
import FluentPostgreSQL

final class Acronym: Codable {
	var id: Int?
	var short: String
	var long: String
	
	init(short: String, long: String) {
		self.short = short
		self.long = long
	}
}

//Conform to SQLiteModel
//default
extension Acronym: PostgreSQLModel {}
extension Acronym: Migration {}
extension Acronym: Content {}
