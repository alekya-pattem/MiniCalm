import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                //Session List
                List{
                    if viewModel.isLoading {
                        ForEach(0..<18, id: \.self) { _ in
                            SessionRowView(session: .placeholder)
                                .redacted(reason: .placeholder)
                        }
                    } else {
                        ForEach(viewModel.sessions) { session in
                            SessionRowView(session: session)
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("MiniCalm")
                .task {
                    await viewModel.fetchSessions()
                }
                .refreshable {
                    await viewModel.fetchSessions()
                }
                
                //Sessions empty
                if let error = viewModel.errorMessage, !viewModel.isLoading, viewModel.sessions.isEmpty {
                    VStack {
                        Text("Oops!")
                            .font(.headline)
                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            Task {
                                await viewModel.fetchSessions()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}
