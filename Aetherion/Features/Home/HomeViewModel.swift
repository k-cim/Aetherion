// === File: HomeViewModel.swift
// Version: 1.2
// Date: 2025-09-14 06:12:00 UTC
// Description: Durable Home ViewModel (state machine, cancellation, retries, DI for clock/RNG, logging).
// Author: K-Cim

import SwiftUI
import os

@MainActor
public final class HomeViewModel: ObservableObject {

    // MARK: - Types
    public enum LoadState: Equatable {
        case idle
        case loading(attempt: Int)
        case success
        case failure(error: Error)

        public static func == (lhs: LoadState, rhs: LoadState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle): return true
            case let (.loading(a), .loading(b)): return a == b
            case (.success, .success): return true
            case (.failure, .failure): return true // ignore error details
            default: return false
            }
        }
    }

    public struct Config: Sendable, Equatable {
        public var maxRetries: Int = 2          // total attempts = maxRetries + 1
        public var baseBackoff: Duration = .milliseconds(200)
        public init(maxRetries: Int = 2, baseBackoff: Duration = .milliseconds(200)) {
            self.maxRetries = max(0, maxRetries)
            self.baseBackoff = baseBackoff
        }
    }

    public enum VMError: Error, Equatable, LocalizedError {
        case simulatedFailure
        public var errorDescription: String? { "An error occurred while loading." }
    }

    // MARK: - Dependencies
    public let log = Logger(subsystem: "net.aetherion.app", category: "HomeViewModel")
    private let clock: any Clock<Duration>
    private var rng: any RandomNumberGenerator
    private let config: Config

    // MARK: - Published
    @Published public private(set) var state: LoadState = .idle
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?

    // MARK: - Task handling
    private var currentTask: Task<Void, Never>?

    // MARK: - Init
    public init(
        clock: any Clock<Duration> = ContinuousClock(),
        rng: any RandomNumberGenerator = SystemRandomNumberGenerator(),
        config: Config = .init()
    ) {
        self.clock = clock
        self.rng = rng
        self.config = config
    }

    // MARK: - API
    /// Loads startup data with retry & backoff. Idempotent under cancellation (latest wins).
    @discardableResult
    public func load() -> LoadState {
        // Cancel any running load
        currentTask?.cancel()
        isLoading = true
        errorMessage = nil
        state = .loading(attempt: 0)

        let attemptLimit = config.maxRetries
        currentTask = Task { [weak self] in
            guard let self else { return }
            defer { self.isLoading = false }

            var attempt = 0
            while !Task.isCancelled {
                self.log.debug("Load attempt: \(attempt)")
                self.state = .loading(attempt: attempt)

                // Simulated work (replace by real async work)
                do {
                    try await self.clock.sleep(for: .milliseconds(800))
                } catch {
                    // sleep cancelled
                    self.log.debug("Load cancelled during sleep")
                    return
                }

                // Deterministic/testable “random” result
                let shouldFail = Self.rollFail(using: &self.rng)
                if !shouldFail {
                    self.state = .success
                    self.errorMessage = nil
                    self.log.info("Load success on attempt \(attempt)")
                    return
                } else {
                    let err = VMError.simulatedFailure
                    self.state = .failure(error: err)
                    self.errorMessage = err.localizedDescription
                    self.log.warning("Load failed on attempt \(attempt): \(self.errorMessage ?? "unknown")")
                }

                // Retry or exit
                guard attempt < attemptLimit else {
                    self.log.error("Load exhausted retries (attempts=\(attempt + 1))")
                    return
                }

                attempt += 1
                let backoff = backoffDuration(for: attempt)
                do {
                    try await self.clock.sleep(for: backoff)
                } catch {
                    self.log.debug("Backoff sleep cancelled")
                    return
                }
            }
        }

        return state
    }

    /// Clear last error and set state to idle (does not cancel a running load).
    public func clearError() {
        errorMessage = nil
        if case .failure = state { state = .idle }
    }

    /// Cancel any ongoing work.
    public func cancel() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false
        log.debug("Load cancelled by user")
    }

    // MARK: - Helpers
    private func backoffDuration(for attempt: Int) -> Duration {
        // Exponential backoff: base * 2^(attempt-1), bounded to 2s
        let factor = 1 << max(0, attempt - 1)
        let raw = config.baseBackoff * factor
        return min(raw, .seconds(2))
    }

    private static func rollFail(using rng: inout any RandomNumberGenerator) -> Bool {
        // 50% failure by default (deterministic in tests via seeded RNG)
        let bit = rng.next() & 1
        return bit == 0
    }
}
