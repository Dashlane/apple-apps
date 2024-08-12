import SwiftUI

extension SwiftUI.Color {
  public enum ds {
    public enum background {
      public static let alternate = SwiftUI.Color("background/alternate")
      public static let `default` = SwiftUI.Color("background/default")
    }

    public enum border {
      public enum brand {
        public enum quiet {
          public static let idle = SwiftUI.Color("border/brand/quiet/idle")
        }
        public enum standard {
          public static let active = SwiftUI.Color("border/brand/standard/active")
          public static let hover = SwiftUI.Color("border/brand/standard/hover")
          public static let idle = SwiftUI.Color("border/brand/standard/idle")
        }
      }
      public enum danger {
        public enum quiet {
          public static let idle = SwiftUI.Color("border/danger/quiet/idle")
        }
        public enum standard {
          public static let active = SwiftUI.Color("border/danger/standard/active")
          public static let hover = SwiftUI.Color("border/danger/standard/hover")
          public static let idle = SwiftUI.Color("border/danger/standard/idle")
        }
      }
      public enum neutral {
        public enum quiet {
          public static let idle = SwiftUI.Color("border/neutral/quiet/idle")
        }
        public enum standard {
          public static let active = SwiftUI.Color("border/neutral/standard/active")
          public static let hover = SwiftUI.Color("border/neutral/standard/hover")
          public static let idle = SwiftUI.Color("border/neutral/standard/idle")
        }
      }
      public enum positive {
        public enum quiet {
          public static let idle = SwiftUI.Color("border/positive/quiet/idle")
        }
        public enum standard {
          public static let active = SwiftUI.Color("border/positive/standard/active")
          public static let hover = SwiftUI.Color("border/positive/standard/hover")
          public static let idle = SwiftUI.Color("border/positive/standard/idle")
        }
      }
      public enum warning {
        public enum quiet {
          public static let idle = SwiftUI.Color("border/warning/quiet/idle")
        }
        public enum standard {
          public static let active = SwiftUI.Color("border/warning/standard/active")
          public static let hover = SwiftUI.Color("border/warning/standard/hover")
          public static let idle = SwiftUI.Color("border/warning/standard/idle")
        }
      }
    }

    public enum container {
      public enum agnostic {
        public enum inverse {
          public static let standard = SwiftUI.Color("container/agnostic/inverse/standard")
        }
        public enum neutral {
          public static let quiet = SwiftUI.Color("container/agnostic/neutral/quiet")
          public static let standard = SwiftUI.Color("container/agnostic/neutral/standard")
          public static let supershy = SwiftUI.Color("container/agnostic/neutral/supershy")
        }
      }
      public enum expressive {
        public enum brand {
          public enum catchy {
            public static let active = SwiftUI.Color("container/expressive/brand/catchy/active")
            public static let disabled = SwiftUI.Color("container/expressive/brand/catchy/disabled")
            public static let hover = SwiftUI.Color("container/expressive/brand/catchy/hover")
            public static let idle = SwiftUI.Color("container/expressive/brand/catchy/idle")
          }
          public enum quiet {
            public static let active = SwiftUI.Color("container/expressive/brand/quiet/active")
            public static let disabled = SwiftUI.Color("container/expressive/brand/quiet/disabled")
            public static let hover = SwiftUI.Color("container/expressive/brand/quiet/hover")
            public static let idle = SwiftUI.Color("container/expressive/brand/quiet/idle")
          }
        }
        public enum danger {
          public enum catchy {
            public static let active = SwiftUI.Color("container/expressive/danger/catchy/active")
            public static let disabled = SwiftUI.Color(
              "container/expressive/danger/catchy/disabled")
            public static let hover = SwiftUI.Color("container/expressive/danger/catchy/hover")
            public static let idle = SwiftUI.Color("container/expressive/danger/catchy/idle")
          }
          public enum quiet {
            public static let active = SwiftUI.Color("container/expressive/danger/quiet/active")
            public static let disabled = SwiftUI.Color("container/expressive/danger/quiet/disabled")
            public static let hover = SwiftUI.Color("container/expressive/danger/quiet/hover")
            public static let idle = SwiftUI.Color("container/expressive/danger/quiet/idle")
          }
        }
        public enum neutral {
          public enum catchy {
            public static let active = SwiftUI.Color("container/expressive/neutral/catchy/active")
            public static let disabled = SwiftUI.Color(
              "container/expressive/neutral/catchy/disabled")
            public static let hover = SwiftUI.Color("container/expressive/neutral/catchy/hover")
            public static let idle = SwiftUI.Color("container/expressive/neutral/catchy/idle")
          }
          public enum quiet {
            public static let active = SwiftUI.Color("container/expressive/neutral/quiet/active")
            public static let disabled = SwiftUI.Color(
              "container/expressive/neutral/quiet/disabled")
            public static let hover = SwiftUI.Color("container/expressive/neutral/quiet/hover")
            public static let idle = SwiftUI.Color("container/expressive/neutral/quiet/idle")
          }
          public enum supershy {
            public static let active = SwiftUI.Color("container/expressive/neutral/supershy/active")
            public static let hover = SwiftUI.Color("container/expressive/neutral/supershy/hover")
            public static let idle = SwiftUI.Color("container/expressive/neutral/supershy/idle")
          }
        }
        public enum positive {
          public enum catchy {
            public static let active = SwiftUI.Color("container/expressive/positive/catchy/active")
            public static let disabled = SwiftUI.Color(
              "container/expressive/positive/catchy/disabled")
            public static let hover = SwiftUI.Color("container/expressive/positive/catchy/hover")
            public static let idle = SwiftUI.Color("container/expressive/positive/catchy/idle")
          }
          public enum quiet {
            public static let active = SwiftUI.Color("container/expressive/positive/quiet/active")
            public static let disabled = SwiftUI.Color(
              "container/expressive/positive/quiet/disabled")
            public static let hover = SwiftUI.Color("container/expressive/positive/quiet/hover")
            public static let idle = SwiftUI.Color("container/expressive/positive/quiet/idle")
          }
        }
        public enum warning {
          public enum catchy {
            public static let active = SwiftUI.Color("container/expressive/warning/catchy/active")
            public static let disabled = SwiftUI.Color(
              "container/expressive/warning/catchy/disabled")
            public static let hover = SwiftUI.Color("container/expressive/warning/catchy/hover")
            public static let idle = SwiftUI.Color("container/expressive/warning/catchy/idle")
          }
          public enum quiet {
            public static let active = SwiftUI.Color("container/expressive/warning/quiet/active")
            public static let disabled = SwiftUI.Color(
              "container/expressive/warning/quiet/disabled")
            public static let hover = SwiftUI.Color("container/expressive/warning/quiet/hover")
            public static let idle = SwiftUI.Color("container/expressive/warning/quiet/idle")
          }
        }
      }
    }

    public enum oddity {
      public static let autofilled = SwiftUI.Color("oddity/autofilled")
      public static let brand = SwiftUI.Color("oddity/brand")
      public static let focus = SwiftUI.Color("oddity/focus")
      public static let ghostButtonFix = SwiftUI.Color("oddity/ghostButtonFix")
      public static let overlay = SwiftUI.Color("oddity/overlay")
    }

    public enum text {
      public enum brand {
        public static let quiet = SwiftUI.Color("text/brand/quiet")
        public static let standard = SwiftUI.Color("text/brand/standard")
      }
      public enum danger {
        public static let quiet = SwiftUI.Color("text/danger/quiet")
        public static let standard = SwiftUI.Color("text/danger/standard")
      }
      public enum inverse {
        public static let catchy = SwiftUI.Color("text/inverse/catchy")
        public static let quiet = SwiftUI.Color("text/inverse/quiet")
        public static let standard = SwiftUI.Color("text/inverse/standard")
      }
      public enum neutral {
        public static let catchy = SwiftUI.Color("text/neutral/catchy")
        public static let quiet = SwiftUI.Color("text/neutral/quiet")
        public static let standard = SwiftUI.Color("text/neutral/standard")
      }
      public enum oddity {
        public static let disabled = SwiftUI.Color("text/oddity/disabled")
        public static let passwordDigits = SwiftUI.Color("text/oddity/passwordDigits")
        public static let passwordSymbols = SwiftUI.Color("text/oddity/passwordSymbols")
      }
      public enum positive {
        public static let quiet = SwiftUI.Color("text/positive/quiet")
        public static let standard = SwiftUI.Color("text/positive/standard")
      }
      public enum warning {
        public static let quiet = SwiftUI.Color("text/warning/quiet")
        public static let standard = SwiftUI.Color("text/warning/standard")
      }
    }
  }
}

extension SwiftUI.Color {
  init(_ name: String) {
    self.init(name, bundle: Bundle.module)
  }
}

extension View where Self == SwiftUI.Color {
  public static var ds: SwiftUI.Color.ds.Type {
    return SwiftUI.Color.ds.self
  }
}
