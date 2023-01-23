import SwiftUI

class SearchTextFieldViewController: NSViewController {
    
    private var text: String
    private let placeholder: String
    private let textDidChange: (String) -> Void
    private let validate: (String) -> Void
    private let font = NSFont.systemFont(ofSize: 16)

    private let textField: MouseTextField
    
    init(text: String,
         placeholder: String,
         textDidChange: @escaping (String) -> Void,
         validate: @escaping (String) -> Void) {
        self.text = text
        self.placeholder = placeholder
        self.textDidChange = textDidChange
        self.validate = validate
        textField = MouseTextField()
        textField.stringValue = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func loadView() {
        self.view = textField
        textField.clicked = {
            let text = self.textField.stringValue
            self.textDidChange(text)
        }

        let cell = SearchTextFieldCell()
        textField.cell = cell
        cell.stringValue = ""
        cell.isEditable = true
        textField.delegate = self
        
        cell.placeholderAttributedString = NSAttributedString(string: placeholder,
                                                              attributes: [.font: font,
                                                                           .foregroundColor: NSColor.placeholderTextColor])
        cell.usesSingleLineMode = true
        cell.lineBreakMode = .byClipping
    
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
    }
    
    func refreshFont() {
        (view as! NSTextField).cell?.font = font
    }
    
    func refreshString(with text: String) {
        guard text != textField.stringValue else { return }
        textField.stringValue = text
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(self.view)
    }
}

extension SearchTextFieldViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let field = view as? NSTextField else {
            return
        }
        textDidChange(field.stringValue)
    }
}


struct SearchTextFieldView: NSViewControllerRepresentable {
    
    @Binding private var text: String
    private let placeholder: String
    private let validate: (String) -> Void
    
    class Coordinator {
        var view: SearchTextFieldView
        
        init(view: SearchTextFieldView) {
            self.view = view
        }
        
        func textDidChange(_ text: String) {
            view.text = text
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }
    
    init(text: Binding<String>,
         placeholder: String,
         validate: @escaping (String) -> Void) {
        self._text = text
        self.placeholder = placeholder
        self.validate = validate
    }

    func makeNSViewController(
        context: NSViewControllerRepresentableContext<SearchTextFieldView>
    ) -> SearchTextFieldViewController {
        return SearchTextFieldViewController(text: text,
                                             placeholder: placeholder,
                                             textDidChange: context.coordinator.textDidChange,
                                             validate: validate)
    }
    
    func updateNSViewController(
        _ nsViewController: SearchTextFieldViewController,
        context: NSViewControllerRepresentableContext<SearchTextFieldView>
    ) {
        nsViewController.refreshFont()
        nsViewController.refreshString(with: text)
        context.coordinator.view = self
    }
}

class MouseTextField: NSTextField {
    
    var clicked: (() -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        clicked?()
    }
    
}

class SearchTextFieldCell: NSTextFieldCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        drawBezel(withFrame: cellFrame, in: controlView)
        drawInterior(withFrame: cellFrame, in: controlView)
    }

    func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        if isHighlighted {
            Asset.separation.color.setFill()
            let path = NSBezierPath(roundedRect: controlView.bounds, xRadius: 6, yRadius: 6)
            path.fill()
        } else {
            let strokeColor = Asset.separation.color
            let strokePath = NSBezierPath(roundedRect: controlView.bounds.insetBy(dx: 0.5, dy: 0.5), xRadius: 5.5, yRadius: 5.5)
            strokeColor.setStroke()
            strokePath.stroke()
        }
    }

    override func drawFocusRingMask(withFrame cellFrame: NSRect, in controlView: NSView) {
        NSGraphicsContext.saveGraphicsState()
        let path = NSBezierPath(roundedRect: cellFrame.insetBy(dx: 1, dy: 1), xRadius: 5.0, yRadius: 5.0)
        path.addClip()
        path.fill()

        super.drawFocusRingMask(withFrame: cellFrame, in: controlView)
        NSGraphicsContext.restoreGraphicsState()
    }

    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let rectInset = NSRect(x: rect.origin.x + 32, y: rect.origin.y + 7, width: rect.size.width - 40, height: rect.size.height)
        return super.drawingRect(forBounds: rectInset)
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let rectInset = NSRect(x: rect.origin.x + 32, y: rect.origin.y + 7, width: rect.size.width - 40, height: rect.size.height)
        super.select(withFrame: rectInset, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
}
