//
//  LibraryViewModel.swift
//  MiniCalm
//
//  Created by swathipriya pattem on 16/09/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class LibraryViewModel: ObservableObject {
    
    @Published var sessions     : [Session] = []
    @Published var isLoading    : Bool = false
    @Published var errorMessage : String?
    private let networkManager  : NetworkManager
    
    init(networkManager: NetworkManager? = nil) {
        self.networkManager = networkManager ?? .shared
    }
    
    func fetchSessions() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        self.sessions = []
        do {
            self.sessions = try await networkManager.fetchSessions()
        }
        catch let urlError as URLError where urlError.code == .notConnectedToInternet {
            self.errorMessage = "No internet connection. Please check your network and pull to refresh."
        }
        catch {
            self.errorMessage = "Failed to load sessions. Please pull to refresh."
        }
        
        isLoading = false
    }
}
