import Foundation
import SwiftUI

struct DisplayFieldPreview: View {
  var body: some View {
    List {
      Section("w/o label persistency") {
        DS.DisplayField("Label", text: "_") {
          DS.FieldAction.CopyContent { print("Copy action.") }
          FieldAction.Button("Open", image: .ds.action.openExternalLink.outlined) {}
        }
        .fieldLabelHiddenOnFocus()

        DS.TextField(
          "Label", text: .constant("_"),
          actions: {
            DS.FieldAction.CopyContent { print("Copy action.") }
          }
        )
        .containerContext(.list(.insetGrouped))
        .fieldLabelHiddenOnFocus()
      }

      Section("w/ placeholder value") {
        DS.DisplayField("Label", placeholder: "_")
        DS.DisplayField("Label", placeholder: "Empty value") {
          DS.FieldAction.CopyContent { print("Copy action.") }
          FieldAction.Button("Test", image: .ds.action.openExternalLink.outlined) {}
        }
      }

      Section("w/ label persistency") {
        DS.DisplayField("Label", text: "_") {
          DS.FieldAction.CopyContent { print("Copy action.") }
          FieldAction.Button("Edit", image: .ds.action.edit.outlined) {}
          DS.FieldAction.Button("Open", image: .ds.action.openExternalLink.outlined) {}
          DS.FieldAction.Button("Import", image: .ds.attachment.outlined, action: {})
        }
      }

      Section("w/ applied styles") {
        ForEach([Style.warning, .error, .positive], id: \.self) { style in
          DS.DisplayField("Label", text: "_") {
            FieldAction.Button("Edit", image: .ds.action.edit.outlined, action: {})
            FieldAction.Menu("Share", image: .ds.action.share.outlined) {
              Button(
                action: {},
                label: {
                  Label(
                    title: { Text("Action") },
                    icon: { Image(systemName: "42.circle") }
                  )
                }
              )
            }
          }
          .style(style)
        }
      }

      Section("Custom accessory icon") {
        DS.DisplayField("Label") {
          Label(
            title: { Text(verbatim: "_") },
            icon: {
              Image.ds.spaces.all.outlined
                .resizable()
                .foregroundStyle(.orange)
            }
          )
        } actions: {
          EmptyView()
        }
      }

      Section("Disabled") {
        DS.DisplayField("Label", text: "_") {
          FieldAction.Button("Test", image: .ds.action.edit.outlined, action: {})
          FieldAction.Menu("Test", image: .ds.collection.outlined) {
            Button(
              action: {},
              label: {
                Label(
                  title: { Text("Action") },
                  icon: { Image(systemName: "42.circle") }
                )
              }
            )
          }
        }
        .disabled(true)
      }

      Section("Multiline") {
        DS.DisplayField(
          "Label",
          text:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        )
        .lineLimit(nil)

        DS.DisplayField(
          "Label",
          text:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        ) {
          DS.FieldAction.CopyContent {}
        }
        .lineLimit(nil)
      }

      Section {
        HStack {
          Text("System reference")
            .frame(maxWidth: .infinity, alignment: .leading)
          Button("Test") {}
            .buttonStyle(.borderless)
            .tint(.green)
        }
      }
    }
  }
}

#Preview {
  DisplayFieldPreview()
}
