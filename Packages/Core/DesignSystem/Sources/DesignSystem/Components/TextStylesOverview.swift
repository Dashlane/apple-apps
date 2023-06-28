import SwiftUI

struct TextStylesOverview: View {
    var body: some View {
        List {
            Group {
                Section("body/helper") {
                    row(forStyle: .body.helper.regular, named: "regular")
                }
                Section("body/reduced") {
                    row(forStyle: .body.reduced.regular, named: "regular")
                    row(forStyle: .body.reduced.monospace, named: "monospace")
                    row(forStyle: .body.reduced.strong, named: "strong")
                }
                Section("body/standard") {
                    row(forStyle: .body.standard.monospace, named: "monospace")
                    row(forStyle: .body.standard.regular, named: "regular")
                    row(forStyle: .body.standard.strong, named: "strong")
                }
            }
            Group {
                Section("component/badge") {
                    row(forStyle: .component.badge.standard, named: "standard")
                }
                Section("component/button") {
                    row(forStyle: .component.button.small, named: "small")
                    row(forStyle: .component.button.standard, named: "standard")
                }
            }
            Group {
                Section("specialty/brand") {
                    row(forStyle: .specialty.brand.small, named: "small")
                    row(forStyle: .specialty.brand.medium, named: "medium")
                    row(forStyle: .specialty.brand.large, named: "large")
                }
                Section("specialty/monospace") {
                    row(forStyle: .specialty.monospace.small, named: "small")
                    row(forStyle: .specialty.monospace.medium, named: "medium")
                    row(forStyle: .specialty.monospace.large, named: "large")
                }
                Section("specialty/spotlight") {
                    row(forStyle: .specialty.spotlight.small, named: "small")
                    row(forStyle: .specialty.spotlight.medium, named: "medium")
                    row(forStyle: .specialty.spotlight.large, named: "large")
                }
            }
            Group {
                Section("title/block") {
                    row(forStyle: .title.block.small, named: "small")
                    row(forStyle: .title.block.medium, named: "medium")
                }
                Section("title/section") {
                    row(forStyle: .title.section.medium, named: "medium")
                    row(forStyle: .title.section.large, named: "large")
                }
                Section("title/supporting") {
                    row(forStyle: .title.supporting.small, named: "small")
                }
            }
        }
    }

    private func row(forStyle style: TextStyle, named name: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The quick brown fox jumps over the lazy dog")
                .textStyle(style)
            Text(name)
                .foregroundColor(.white)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .foregroundColor(.secondary)
                )
        }
    }
}

struct TextStylesOverview_Previews: PreviewProvider {
    static var previews: some View {
        TextStylesOverview()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
