struct MyView: View {
  @Environment(\.toast)
  var toast

  var body: some View {
    Button("Copy") {
      toast("Password Copied", image: .ds.action.copy.outlined)
    }
  }
}
