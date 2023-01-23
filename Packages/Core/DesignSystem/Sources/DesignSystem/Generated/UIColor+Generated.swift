#if os(iOS)
import UIKit

extension UIColor {
    public enum ds {
                public enum background {
            public static let alternate = UIColor("background/alternate")
            public static let `default` = UIColor("background/default")
        }

        public enum border {
            public enum brand {
                public enum quiet {
                    public static let idle = UIColor("border/brand/quiet/idle")
                }
                public enum standard {
                    public static let active = UIColor("border/brand/standard/active")
                    public static let hover = UIColor("border/brand/standard/hover")
                    public static let idle = UIColor("border/brand/standard/idle")
                }
            }
            public enum danger {
                public enum quiet {
                    public static let idle = UIColor("border/danger/quiet/idle")
                }
                public enum standard {
                    public static let active = UIColor("border/danger/standard/active")
                    public static let hover = UIColor("border/danger/standard/hover")
                    public static let idle = UIColor("border/danger/standard/idle")
                }
            }
            public enum neutral {
                public enum quiet {
                    public static let idle = UIColor("border/neutral/quiet/idle")
                }
                public enum standard {
                    public static let active = UIColor("border/neutral/standard/active")
                    public static let hover = UIColor("border/neutral/standard/hover")
                    public static let idle = UIColor("border/neutral/standard/idle")
                }
            }
            public enum positive {
                public enum quiet {
                    public static let idle = UIColor("border/positive/quiet/idle")
                }
                public enum standard {
                    public static let active = UIColor("border/positive/standard/active")
                    public static let hover = UIColor("border/positive/standard/hover")
                    public static let idle = UIColor("border/positive/standard/idle")
                }
            }
            public enum warning {
                public enum quiet {
                    public static let idle = UIColor("border/warning/quiet/idle")
                }
                public enum standard {
                    public static let active = UIColor("border/warning/standard/active")
                    public static let hover = UIColor("border/warning/standard/hover")
                    public static let idle = UIColor("border/warning/standard/idle")
                }
            }
        }

        public enum container {
            public enum agnostic {
                public enum inverse {
                    public static let standard = UIColor("container/agnostic/inverse/standard")
                }
                public enum neutral {
                    public static let quiet = UIColor("container/agnostic/neutral/quiet")
                    public static let standard = UIColor("container/agnostic/neutral/standard")
                    public static let supershy = UIColor("container/agnostic/neutral/supershy")
                }
            }
            public enum expressive {
                public enum brand {
                    public enum catchy {
                        public static let active = UIColor("container/expressive/brand/catchy/active")
                        public static let disabled = UIColor("container/expressive/brand/catchy/disabled")
                        public static let hover = UIColor("container/expressive/brand/catchy/hover")
                        public static let idle = UIColor("container/expressive/brand/catchy/idle")
                    }
                    public enum quiet {
                        public static let active = UIColor("container/expressive/brand/quiet/active")
                        public static let disabled = UIColor("container/expressive/brand/quiet/disabled")
                        public static let hover = UIColor("container/expressive/brand/quiet/hover")
                        public static let idle = UIColor("container/expressive/brand/quiet/idle")
                    }
                }
                public enum danger {
                    public enum catchy {
                        public static let active = UIColor("container/expressive/danger/catchy/active")
                        public static let disabled = UIColor("container/expressive/danger/catchy/disabled")
                        public static let hover = UIColor("container/expressive/danger/catchy/hover")
                        public static let idle = UIColor("container/expressive/danger/catchy/idle")
                    }
                    public enum quiet {
                        public static let active = UIColor("container/expressive/danger/quiet/active")
                        public static let disabled = UIColor("container/expressive/danger/quiet/disabled")
                        public static let hover = UIColor("container/expressive/danger/quiet/hover")
                        public static let idle = UIColor("container/expressive/danger/quiet/idle")
                    }
                }
                public enum neutral {
                    public enum catchy {
                        public static let active = UIColor("container/expressive/neutral/catchy/active")
                        public static let disabled = UIColor("container/expressive/neutral/catchy/disabled")
                        public static let hover = UIColor("container/expressive/neutral/catchy/hover")
                        public static let idle = UIColor("container/expressive/neutral/catchy/idle")
                    }
                    public enum quiet {
                        public static let active = UIColor("container/expressive/neutral/quiet/active")
                        public static let disabled = UIColor("container/expressive/neutral/quiet/disabled")
                        public static let hover = UIColor("container/expressive/neutral/quiet/hover")
                        public static let idle = UIColor("container/expressive/neutral/quiet/idle")
                    }
                    public enum supershy {
                        public static let active = UIColor("container/expressive/neutral/supershy/active")
                        public static let hover = UIColor("container/expressive/neutral/supershy/hover")
                        public static let idle = UIColor("container/expressive/neutral/supershy/idle")
                    }
                }
                public enum positive {
                    public enum catchy {
                        public static let active = UIColor("container/expressive/positive/catchy/active")
                        public static let disabled = UIColor("container/expressive/positive/catchy/disabled")
                        public static let hover = UIColor("container/expressive/positive/catchy/hover")
                        public static let idle = UIColor("container/expressive/positive/catchy/idle")
                    }
                    public enum quiet {
                        public static let active = UIColor("container/expressive/positive/quiet/active")
                        public static let disabled = UIColor("container/expressive/positive/quiet/disabled")
                        public static let hover = UIColor("container/expressive/positive/quiet/hover")
                        public static let idle = UIColor("container/expressive/positive/quiet/idle")
                    }
                }
                public enum warning {
                    public enum catchy {
                        public static let active = UIColor("container/expressive/warning/catchy/active")
                        public static let disabled = UIColor("container/expressive/warning/catchy/disabled")
                        public static let hover = UIColor("container/expressive/warning/catchy/hover")
                        public static let idle = UIColor("container/expressive/warning/catchy/idle")
                    }
                    public enum quiet {
                        public static let active = UIColor("container/expressive/warning/quiet/active")
                        public static let disabled = UIColor("container/expressive/warning/quiet/disabled")
                        public static let hover = UIColor("container/expressive/warning/quiet/hover")
                        public static let idle = UIColor("container/expressive/warning/quiet/idle")
                    }
                }
            }
        }

        public enum oddity {
            public static let autofilled = UIColor("oddity/autofilled")
            public static let brand = UIColor("oddity/brand")
            public static let focus = UIColor("oddity/focus")
            public static let ghostButtonFix = UIColor("oddity/ghostButtonFix")
            public static let overlay = UIColor("oddity/overlay")
        }

        public enum text {
            public enum brand {
                public static let quiet = UIColor("text/brand/quiet")
                public static let standard = UIColor("text/brand/standard")
            }
            public enum danger {
                public static let quiet = UIColor("text/danger/quiet")
                public static let standard = UIColor("text/danger/standard")
            }
            public enum inverse {
                public static let catchy = UIColor("text/inverse/catchy")
                public static let quiet = UIColor("text/inverse/quiet")
                public static let standard = UIColor("text/inverse/standard")
            }
            public enum neutral {
                public static let catchy = UIColor("text/neutral/catchy")
                public static let quiet = UIColor("text/neutral/quiet")
                public static let standard = UIColor("text/neutral/standard")
            }
            public enum oddity {
                public static let disabled = UIColor("text/oddity/disabled")
                public static let passwordDigits = UIColor("text/oddity/passwordDigits")
                public static let passwordSymbols = UIColor("text/oddity/passwordSymbols")
            }
            public enum positive {
                public static let quiet = UIColor("text/positive/quiet")
                public static let standard = UIColor("text/positive/standard")
            }
            public enum warning {
                public static let quiet = UIColor("text/warning/quiet")
                public static let standard = UIColor("text/warning/standard")
            }
        }
    }
}

fileprivate extension UIColor {
    convenience init(_ name: String) {
        self.init(named: name, in: Bundle.module, compatibleWith: nil)!
    }
}
#endif
