import Foundation

class DeepSeekService {
    static let shared = DeepSeekService()

    private let apiKey: String?
    private let apiURL = URL(string: "https://api.deepseek.com/v1/ai-optimize")! // Change to actual DeepSeek endpoint if different

    private init() {
        self.apiKey = ProcessInfo.processInfo.environment["DeepSeek_API"]
    }

    // MARK: - Route Optimization
    func optimizeRoute(appointments: [Appointment], completion: @escaping (Result<[UUID], DeepSeekError>) -> Void) {
        guard let apiKey = apiKey else {
            completion(.failure(.message("Missing DeepSeek API Key.")))
            return
        }
        let payload: [String: Any] = [
            "action": "optimize_route",
            "appointments": appointments.map { [
                "id": $0.id.uuidString,
                "client": $0.client.name,
                "pet": $0.pet.name,
                "time": $0.time.timeIntervalSince1970,
                "duration": $0.duration
            ]}
        ]
        sendRequest(payload: payload, apiKey: apiKey) { result in
            switch result {
            case .success(let response):
                if let order = response["optimizedOrder"] as? [String] {
                    let uuids = order.compactMap(UUID.init)
                    completion(.success(uuids))
                } else if let error = response["error"] as? String {
                    completion(.failure(.message(error)))
                } else {
                    completion(.failure(.message("AI did not return a valid order.")))
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }

    // MARK: - Pet Summary
    func summarizePet(pet: Pet, completion: @escaping (Result<String, DeepSeekError>) -> Void) {
        guard let apiKey = apiKey else {
            completion(.failure(.message("Missing DeepSeek API Key.")))
            return
        }
        let payload: [String: Any] = [
            "action": "summarize_pet",
            "name": pet.name,
            "breed": pet.breed,
            "notes": pet.notes,
            "temperament": pet.temperament,
            "behaviorTags": pet.behaviorTags.map { $0.label }
        ]
        sendRequest(payload: payload, apiKey: apiKey) { result in
            switch result {
            case .success(let response):
                if let summary = response["summary"] as? String {
                    completion(.success(summary))
                } else if let error = response["error"] as? String {
                    completion(.failure(.message(error)))
                } else {
                    completion(.failure(.message("AI did not return a summary.")))
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }

    // MARK: - Appointment Notes Suggestion
    func suggestAppointmentNotes(context: [String: Any], completion: @escaping (Result<String, DeepSeekError>) -> Void) {
        guard let apiKey = apiKey else {
            completion(.failure(.message("Missing DeepSeek API Key.")))
            return
        }
        sendRequest(payload: context, apiKey: apiKey) { result in
            switch result {
            case .success(let response):
                if let suggestion = response["suggestedNotes"] as? String {
                    completion(.success(suggestion))
                } else if let error = response["error"] as? String {
                    completion(.failure(.message(error)))
                } else {
                    completion(.failure(.message("AI did not return a note suggestion.")))
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }

    // MARK: - Networking Helper
    private func sendRequest(payload: [String: Any], apiKey: String, completion: @escaping (Result<[String: Any], DeepSeekError>) -> Void) {
        print("[DeepSeekService] Payload: \(payload)")
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(.message("Failed to encode request body.")))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.message(error.localizedDescription)))
                return
            }
            if let data = data, let rawString = String(data: data, encoding: .utf8) {
                print("[DeepSeekService] Raw response: \(rawString)")
            }
            guard let data = data,
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(.message("Invalid response from server.")))
                return
            }
            print("[DeepSeekService] Parsed response: \(obj)")
            completion(.success(obj))
        }
        task.resume()
    }
}
