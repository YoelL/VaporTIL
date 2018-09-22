import Vapor
import Fluent


/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

	
//	Create - POST Request
	router.post("api", "acronyms") { req -> Future<Acronym> in
	
		return try req.content.decode(Acronym.self)
			.flatMap(to: Acronym.self) { acronym in
	
				return acronym.save(on: req)
		}
	}
	
	
//	Retrive All - GET
	router.get("api", "acronyms") { req -> Future<[Acronym]> in
		return Acronym.query(on: req).all()
	}
	
	
//	Retrive Single - GET
	router.get("api", "acronyms", Acronym.parameter) {
		req -> Future<Acronym> in
		// 2
		return try req.parameters.next(Acronym.self)
	}
	
//	Update Single Acronym
	router.put("api", "acronyms", Acronym.parameter) {
		req -> Future<Acronym> in
	
		return try flatMap(to: Acronym.self,
						   req.parameters.next(Acronym.self),
						   req.content.decode(Acronym.self)) {
							acronym, updatedAcronym in
							// 3
							acronym.short = updatedAcronym.short
							acronym.long = updatedAcronym.long
							// 4
							return acronym.save(on: req)
		}
	}
	
//	Delete Single Acronym
	router.delete("api", "acronyms", Acronym.parameter) {
		req -> Future<HTTPStatus> in
		// 2
		return try req.parameters.next(Acronym.self)
		// 3
		.delete(on: req)
		// 4
		.transform(to: HTTPStatus.noContent)
	}
	
	
	/// Searching with Fluent- GET, pg - 108
	// http://localhost:8080/api/acronyms/search?term=WTF
	// 1 uses Retrive All - GET as well  to fetch all short Acronyms
	router.get("api", "acronyms", "search") {
		req -> Future<[Acronym]> in
		// 2
		guard
			let searchTerm = req.query[String.self, at: "term"] else {
				throw Abort(.badRequest)
		}
	//Short terms only -> WTF
/*
		return Acronym.query(on: req)
			.filter(\.short == searchTerm)
			.all()
	*/
		
		//Short and Long  -> WTF or What The Flip
		return Acronym.query(on: req).group(.or) { or in
		
			or.filter(\.short == searchTerm)
			or.filter(\.long == searchTerm)
			
			}.all()
	}
	
	//First result of a query - http://localhost:8080/api/acronyms/first
	router.get("api", "acronyms", "first") {
		req -> Future<Acronym> in
		// 2
		return Acronym.query(on: req)
			// 3
			.first()
			.map(to: Acronym.self) { acronym in
				guard let acronym = acronym else {
					throw Abort(.notFound)
				}
				// 4
				return acronym
		}
	}
	
	
	
	// Sorting results in ascending order - GET - http://localhost:8080/api/acronyms/sorted
	router.get("api", "acronyms", "sorted") {
		req -> Future<[Acronym]> in
		// 2
		return Acronym.query(on: req)
			.sort(\.short, .ascending)
			.all()
	}
	
}
