//
//  PaymentView.swift
//  i2-Donate


import TKFormTextField

/// Protocol for handling payment responses.
protocol PaymentDelegate: class {
    /// Method called when a payment response is received.
    ///
    /// - Parameter string: The response string.
    func paymentResponse(string: String)
}

/// A custom view for handling payment-related actions.
class PaymentView: UIView, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    /// Block to be executed when the payment action is done.
    typealias PaymentDoneBlock = (_ selectedRating: Int?, _ selectedValue: String?) -> Void
    
    /// The delegate for payment-related actions.
    weak var delegate: PaymentDelegate?
    
    /// The visual effect view used for blurring background.
    @IBOutlet var blurView: UIVisualEffectView!
    
    /// Button for canceling the payment action.
    @IBOutlet var cancelBtn: UIButton!
    
    /// Button for removing payment details.
    @IBOutlet var removeBtn: UIButton!
    
    /// Button for confirming the payment action.
    @IBOutlet var doneBtn: UIButton!
    
    /// The container view for the payment UI.
    @IBOutlet var donateView: UIView!
    
    /// Block to be executed when the payment action is done.
    var doneBlock: PaymentDoneBlock?
    
    // MARK: - Public Methods
    
    /// Opens the payment view.
    ///
    /// - Parameters:
    ///   - controller: The parent view controller.
    ///   - bool: An integer value indicating some condition (unused).
    ///   - delegate: The delegate for payment-related actions.
    ///   - successBlock: The block to be executed when the payment action is done.
    func openMenuview(controller: UIView, _ bool: Int, delegate: PaymentDelegate, withSuccess successBlock: @escaping PaymentDoneBlock) {
        var nibView: PaymentView?
        nibView = Bundle.main.loadNibNamed("PaymentView", owner: self, options: nil)?[0] as? PaymentView
        nibView?.frame = controller.bounds
        nibView?.doneBlock = successBlock
        controller.addSubview(nibView!)
        nibView?.delegate = delegate
    }
    
    // MARK: - Actions
    
    /// Action method called when the payment action is confirmed.
    ///
    /// - Parameter sender: The button initiating the action.
    @IBAction func doneAction(_ sender: UIButton) {
        self.doneBlock?(6, "\(6)")
    }
    
    /// Action method called when the payment action is canceled.
    ///
    /// - Parameter sender: The button initiating the action.
    @IBAction func cancelAction(_ sender: UIButton) {
        self.delegate?.paymentResponse(string: "1")
        self.doneBlock?(4, "\(4)")
    }
    
    /// Action method called when the donation action is initiated.
    ///
    /// - Parameter sender: The button initiating the action.
    @IBAction func donateAction(_ sender: UIButton) {
        self.doneBlock?(1, "\(1)")
    }
    
    // MARK: - UITextFieldDelegate
    
    /// Notifies the delegate that editing began in the specified text field.
    ///
    /// - Parameter textField: The text field in which editing began.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        self.doneBlock?(5, "\(5)")
    }
    
    /// Asks the delegate if the text field should process the pressing of the return button.
    ///
    /// - Parameters:
    ///   - textField: The text field whose return button was pressed.
    ///   - string: The replacement string.
    ///   - range: The range of characters to be replaced.
    /// - Returns: true if the text field should implement its default behavior for the return button; otherwise, false.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                if(string.count == 1){
                    return false
                }
            }
        }
        return true
    }
}
