//
//  ProjectService.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import Foundation

enum ProjectService {
    private static let baseURL = "https://us-central1-mierute-c7b7f.cloudfunctions.net/api"

    static func fetchProject(id: String) async throws -> Project {
        guard let url = URL(string: "\(baseURL)/api/projects/\(id)") else {
            throw ProjectServiceError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProjectServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw ProjectServiceError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let project = try decoder.decode(Project.self, from: data)

        return project
    }
}

enum ProjectServiceError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
}
