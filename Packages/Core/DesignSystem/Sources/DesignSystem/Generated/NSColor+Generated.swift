#if os(macOS)
import AppKit

extension NSColor {
    public enum ds {
                public enum background {
            public static let alternate = NSColor("background/alternate")
            public static let `default` = NSColor("background/default")
        }

        public enum border {
            public enum brand {
                public enum quiet {
                    public static let idle = NSColor("border/brand/quiet/idle")
                }
                public enum standard {
                    public static let active = NSColor("border/brand/standard/active")
                    public static let hover = NSColor("border/brand/standard/hover")
                    public static let idle = NSColor("border/brand/standard/idle")
                }
            }
            public enum danger {
                public enum quiet {
                    public static let idle = NSColor("border/danger/quiet/idle")
                }
                public enum standard {
                    public static let active = NSColor("border/danger/standard/active")
                    public static let hover = NSColor("border/danger/standard/hover")
                    public static let idle = NSColor("border/danger/standard/idle")
                }
            }
            public enum neutral {
                public enum quiet {
                    public static let idle = NSColor("border/neutral/quiet/idle")
                }
                public enum standard {
                    public static let active = NSColor("border/neutral/standard/active")
                    public static let hover = NSColor("border/neutral/standard/hover")
                    public static let idle = NSColor("border/neutral/standard/idle")
                }
            }
            public enum positive {
                public enum quiet {
                    public static let idle = NSColor("border/positive/quiet/idle")
                }
                public enum standard {
                    public static let active = NSColor("border/positive/standard/active")
                    public static let hover = NSColor("border/positive/standard/hover")
                    public static let idle = NSColor("border/positive/standard/idle")
                }
            }
            public enum warning {
                public enum quiet {
                    public static let idle = NSColor("border/warning/quiet/idle")
                }
                public enum standard {
                    public static let active = NSColor("border/warning/standard/active")
                    public static let hover = NSColor("border/warning/standard/hover")
                    public static let idle = NSColor("border/warning/standard/idle")
                }
            }
        }

        public enum container {
            public enum agnostic {
                public enum inverse {
                    public static let standard = NSColor("container/agnostic/inverse/standard")
                }
                public enum neutral {
                    public static let quiet = NSColor("container/agnostic/neutral/quiet")
                    public static let standard = NSColor("container/agnostic/neutral/standard")
                    public static let supershy = NSColor("container/agnostic/neutral/supershy")
                }
            }
            public enum expressive {
                public enum brand {
                    public enum catchy {
                        public static let active = NSColor("container/expressive/brand/catchy/active")
                        public static let disabled = NSColor("container/expressive/brand/catchy/disabled")
                        public static let hover = NSColor("container/expressive/brand/catchy/hover")
                        public static let idle = NSColor("container/expressive/brand/catchy/idle")
                    }
                    public enum quiet {
                        public static let active = NSColor("container/expressive/brand/quiet/active")
                        public static let disabled = NSColor("container/expressive/brand/quiet/disabled")
                        public static let hover = NSColor("container/expressive/brand/quiet/hover")
                        public static let idle = NSColor("container/expressive/brand/quiet/idle")
                    }
                }
                public enum danger {
                    public enum catchy {
                        public static let active = NSColor("container/expressive/danger/catchy/active")
                        public static let disabled = NSColor("container/expressive/danger/catchy/disabled")
                        public static let hover = NSColor("container/expressive/danger/catchy/hover")
                        public static let idle = NSColor("container/expressive/danger/catchy/idle")
                    }
                    public enum quiet {
                        public static let active = NSColor("container/expressive/danger/quiet/active")
                        public static let disabled = NSColor("container/expressive/danger/quiet/disabled")
                        public static let hover = NSColor("container/expressive/danger/quiet/hover")
                        public static let idle = NSColor("container/expressive/danger/quiet/idle")
                    }
                }
                public enum neutral {
                    public enum catchy {
                        public static let active = NSColor("container/expressive/neutral/catchy/active")
                        public static let disabled = NSColor("container/expressive/neutral/catchy/disabled")
                        public static let hover = NSColor("container/expressive/neutral/catchy/hover")
                        public static let idle = NSColor("container/expressive/neutral/catchy/idle")
                    }
                    public enum quiet {
                        public static let active = NSColor("container/expressive/neutral/quiet/active")
                        public static let disabled = NSColor("container/expressive/neutral/quiet/disabled")
                        public static let hover = NSColor("container/expressive/neutral/quiet/hover")
                        public static let idle = NSColor("container/expressive/neutral/quiet/idle")
                    }
                    public enum supershy {
                        public static let active = NSColor("container/expressive/neutral/supershy/active")
                        public static let hover = NSColor("container/expressive/neutral/supershy/hover")
                        public static let idle = NSColor("container/expressive/neutral/supershy/idle")
                    }
                }
                public enum positive {
                    public enum catchy {
                        public static let active = NSColor("container/expressive/positive/catchy/active")
                        public static let disabled = NSColor("container/expressive/positive/catchy/disabled")
                        public static let hover = NSColor("container/expressive/positive/catchy/hover")
                        public static let idle = NSColor("container/expressive/positive/catchy/idle")
                    }
                    public enum quiet {
                        public static let active = NSColor("container/expressive/positive/quiet/active")
                        public static let disabled = NSColor("container/expressive/positive/quiet/disabled")
                        public static let hover = NSColor("container/expressive/positive/quiet/hover")
                        public static let idle = NSColor("container/expressive/positive/quiet/idle")
                    }
                }
                public enum warning {
                    public enum catchy {
                        public static let active = NSColor("container/expressive/warning/catchy/active")
                        public static let disabled = NSColor("container/expressive/warning/catchy/disabled")
                        public static let hover = NSColor("container/expressive/warning/catchy/hover")
                        public static let idle = NSColor("container/expressive/warning/catchy/idle")
                    }
                    public enum quiet {
                        public static let active = NSColor("container/expressive/warning/quiet/active")
                        public static let disabled = NSColor("container/expressive/warning/quiet/disabled")
                        public static let hover = NSColor("container/expressive/warning/quiet/hover")
                        public static let idle = NSColor("container/expressive/warning/quiet/idle")
                    }
                }
            }
        }

        public enum oddity {
            public static let autofilled = NSColor("oddity/autofilled")
            public static let brand = NSColor("oddity/brand")
            public static let focus = NSColor("oddity/focus")
            public static let ghostButtonFix = NSColor("oddity/ghostButtonFix")
            public static let overlay = NSColor("oddity/overlay")
        }

        public enum text {
            public enum brand {
                public static let quiet = NSColor("text/brand/quiet")
                public static let standard = NSColor("text/brand/standard")
            }
            public enum danger {
                public static let quiet = NSColor("text/danger/quiet")
                public static let standard = NSColor("text/danger/standard")
            }
            public enum inverse {
                public static let catchy = NSColor("text/inverse/catchy")
                public static let quiet = NSColor("text/inverse/quiet")
                public static let standard = NSColor("text/inverse/standard")
            }
            public enum neutral {
                public static let catchy = NSColor("text/neutral/catchy")
                public static let quiet = NSColor("text/neutral/quiet")
                public static let standard = NSColor("text/neutral/standard")
            }
            public enum oddity {
                public static let disabled = NSColor("text/oddity/disabled")
                public static let passwordDigits = NSColor("text/oddity/passwordDigits")
                public static let passwordSymbols = NSColor("text/oddity/passwordSymbols")
            }
            public enum positive {
                public static let quiet = NSColor("text/positive/quiet")
                public static let standard = NSColor("text/positive/standard")
            }
            public enum warning {
                public static let quiet = NSColor("text/warning/quiet")
                public static let standard = NSColor("text/warning/standard")
            }
        }
    }
}

fileprivate extension NSColor {
    convenience init(_ name: String) {
        self.init(named: NSColor.Name(name), bundle: Bundle.main)!
    }
}
#endif
