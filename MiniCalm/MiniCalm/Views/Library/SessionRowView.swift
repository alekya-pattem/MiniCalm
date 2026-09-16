import SwiftUI

struct SessionRowView: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 16) {
            // Artwork
            AsyncImage(url: URL(string: session.artwork_url ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Color.gray.opacity(0.2)
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Text Info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title ?? "")
                    .font(.headline)
                    .lineLimit(1)
                
                Text(session.teacher ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(session.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Premium Badge
            VStack{
                if session.is_premium ?? false {
                    Text("Premium")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .clipShape(Capsule())
                }
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}
