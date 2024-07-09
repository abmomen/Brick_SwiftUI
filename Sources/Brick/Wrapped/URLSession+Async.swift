import Foundation

public extension Brick where Wrapped: URLSession {
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func data(request: URLRequest) async throws -> (Data, URLSessionTaskMetrics?) {
        let controller = URLSessionTaskController()
        let (data, _) = try await wrapped.data(for: request, delegate: controller)
        return (data, controller.metrics)
    }
    /// Start a data task with a URL using async/await.
    /// - parameter url: The URL to send a request to.
    /// - returns: A tuple containing the binary `Data` that was downloaded,
    ///   as well as a `URLResponse` representing the server's response.
    /// - throws: Any error encountered while performing the data task.
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(for: URLRequest(url: url))
    }

    /// Start a data task with a `URLRequest` using async/await.
    /// - parameter request: The `URLRequest` that the data task should perform.
    /// - returns: A tuple containing the binary `Data` that was downloaded,
    ///   as well as a `URLResponse` representing the server's response.
    /// - throws: Any error encountered while performing the data task.
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let sessionTask = URLSessionTaskActor()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    await sessionTask.start(wrapped.dataTask(with: request) { data, response, error in
                        guard let data = data, let response = response else {
                            let error = error ?? URLError(.badServerResponse)
                            continuation.resume(throwing: error)
                            return
                        }

                        continuation.resume(returning: (data, response))
                    })
                }
            }
        } onCancel: {
            Task { await sessionTask.cancel() }
        }
    }

    func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        let sessionTask = URLSessionTaskActor()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    await sessionTask.start(wrapped.uploadTask(with: request, fromFile: fileURL) { data, response, error in
                        guard let data = data, let response = response else {
                            let error = error ?? URLError(.badServerResponse)
                            return continuation.resume(throwing: error)
                        }

                        continuation.resume(returning: (data, response))
                    })
                }
            }
        } onCancel: {
            Task { await sessionTask.cancel() }
        }
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        let sessionTask = URLSessionTaskActor()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    await sessionTask.start(wrapped.uploadTask(with: request, from: bodyData) { data, response, error in
                        guard let data = data, let response = response else {
                            let error = error ?? URLError(.badServerResponse)
                            return continuation.resume(throwing: error)
                        }

                        continuation.resume(returning: (data, response))
                    })
                }
            }
        } onCancel: {
            Task { await sessionTask.cancel() }
        }
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        let sessionTask = URLSessionTaskActor()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    await sessionTask.start(wrapped.downloadTask(with: request) { data, response, error in
                        guard let data = data, let response = response else {
                            let error = error ?? URLError(.badServerResponse)
                            return continuation.resume(throwing: error)
                        }

                        continuation.resume(returning: (data, response))
                    })
                }
            }
        } onCancel: {
            Task { await sessionTask.cancel() }
        }
    }

    func download(from url: URL) async throws -> (URL, URLResponse) {
        let sessionTask = URLSessionTaskActor()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    await sessionTask.start(wrapped.downloadTask(with: url) { data, response, error in
                        guard let data = data, let response = response else {
                            let error = error ?? URLError(.badServerResponse)
                            return continuation.resume(throwing: error)
                        }

                        continuation.resume(returning: (data, response))
                    })
                }
            }
        } onCancel: {
            Task { await sessionTask.cancel() }
        }
    }

    func download(resumeFrom resumeData: Data) async throws -> (URL, URLResponse) {
        let sessionTask = URLSessionTaskActor()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    await sessionTask.start(wrapped.downloadTask(withResumeData: resumeData) { data, response, error in
                        guard let data = data, let response = response else {
                            let error = error ?? URLError(.badServerResponse)
                            return continuation.resume(throwing: error)
                        }

                        continuation.resume(returning: (data, response))
                    })
                }
            }
        } onCancel: {
            Task { await sessionTask.cancel() }
        }
    }

}

private actor URLSessionTaskActor {
    weak var task: URLSessionTask?

    func start(_ task: URLSessionTask) {
        self.task = task
        task.resume()
    }

    func cancel() {
        task?.cancel()
    }
}

private class URLSessionTaskController: NSObject, URLSessionTaskDelegate {
    
    var metrics: URLSessionTaskMetrics?
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        self.metrics = metrics
    }
}
