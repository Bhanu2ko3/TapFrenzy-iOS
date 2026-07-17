import SwiftUI

struct ScoreBadge: View {
    let text: String
    let value: String
    let themeColor: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.black)
                .foregroundColor(themeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(themeColor.opacity(0.15))
                .cornerRadius(8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
    }
}

struct HubActionCard<Content: View>: View {
    let title: String
    let iconName: String
    let highlightColor: Color
    let content: Content
    
    init(title: String, iconName: String, highlightColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.iconName = iconName
        self.highlightColor = highlightColor
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(highlightColor)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct HubMenuButton: View {
    let iconName: String
    let title: String
    let subtitle: String
    let themeColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 54, height: 54)
                .background(themeColor)
                .cornerRadius(12)
                .shadow(color: themeColor.opacity(0.4), radius: 6, x: 0, y: 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray6), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}
