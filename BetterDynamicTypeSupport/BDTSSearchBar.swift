import UIKit

public class BDTSSearchBar: UISearchBar {
    let textStyle: UIFont.TextStyle = .body

    init() {
        super.init(frame: .zero)
        self.commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        let font = UIFont.preferredFont(forTextStyle: self.textStyle)
        let attributes = [NSAttributedString.Key.font: font]
        UITextField.appearance(whenContainedInInstancesOf: [BDTSSearchBar.self]).defaultTextAttributes = attributes
        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: .main) { _ in
            self.adjustFontSize()
        }
    }
    
    private func adjustFontSize() {
        guard let firstView = self.subviews.first else {
            return
        }
        
        for view in firstView.subviews {
            if let textField = view as? UITextField {
                textField.font = UIFont.preferredFont(forTextStyle: self.textStyle)
                // Reset cursor. Does not account for the case where the user selected part of the range, or
                // had the cursor in another place except at the end.
                textField.selectedTextRange = textField.textRange(from: textField.endOfDocument,
                                                                  to: textField.endOfDocument)
            }
        }
    }
}
