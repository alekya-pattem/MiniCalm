import SwiftUI
import UIKit

struct PlayerViewRepresentable: UIViewControllerRepresentable {
    let session: Session
    
    func makeUIViewController(context: Context) -> PlayerViewController {
        let playerVC = PlayerViewController(nibName: "PlayerViewController", bundle: nil)
        playerVC.session = session
        return playerVC
    }
    
    func updateUIViewController(_ uiViewController: PlayerViewController, context: Context) {
    }
}
