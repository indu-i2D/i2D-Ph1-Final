//
//  RegisterVC.swift
//  i2-Donate

import UIKit
import TKFormTextField
import MBProgressHUD
import Alamofire
import GoogleSignIn
import FBSDKLoginKit
import UniformTypeIdentifiers
import AuthenticationServices
import KeychainSwift

// MARK: - Extension for UITableViewDelegate and UITableViewDataSource
extension RegisterVC: UITableViewDelegate, UITableViewDataSource {
    
    /// Determines the number of rows in the table view section.
    ///
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - section: The section index in the table view.
    /// - Returns: The number of rows in the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    /// Determines the height for the rows in the table view.
    ///
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - indexPath: The index path of the row.
    /// - Returns: The height of the row at the specified index path.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height
    }
    
    /// Provides a cell to insert in a particular location of the table view.
    ///
    /// - Parameters:
    ///   - tableView: The table view requesting this cell.
    ///   - indexPath: The index path that specifies the location of the cell.
    /// - Returns: A configured cell object.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessRegCell", for: indexPath) as! BusinessRegCell
        return cell
    }
    
}
/// This class manages the user registration process in the i2-Donate application.
// MARK: - Register View Controller
class RegisterVC: BaseViewController,GIDSignInDelegate {
    @IBOutlet var maleBtn: UIButton! // UIButton for selecting male gender.
    @IBOutlet var femaleBtn: UIButton! // UIButton for selecting female gender.
    @IBOutlet var businessBtn: UIButton! // UIButton for selecting business type.
    @IBOutlet var individualBtn: UIButton! // UIButton for selecting individual type.
    @IBOutlet var otherBtn: UIButton! // UIButton for selecting other type.
    @IBOutlet var countryBtn: UIButton! // UIButton for selecting country.
    @IBOutlet var containerView: UIView! // UIView containing the registration form.
    @IBOutlet var scrollView: UIScrollView! // UIScrollView for scrolling the registration form.
    @IBOutlet var agreeBtn: UIView! // UIView for agreeing to terms and conditions.
    @IBOutlet var nameText: TKFormTextField! // TKFormTextField for entering user's name.
    @IBOutlet var emailText: TKFormTextField! // TKFormTextField for entering user's email.
    @IBOutlet var mobileText: TKFormTextField! // TKFormTextField for entering user's mobile number.
    @IBOutlet var passwordText1: TKFormTextField! // TKFormTextField for entering user's password.
    @IBOutlet var countryText: TKFormTextField! // TKFormTextField for entering country name.
    @IBOutlet var businessName: TKFormTextField! // TKFormTextField for entering business name.
    @IBOutlet var showhidebtn: UIButton! // UIButton for showing/hiding password.
    @IBOutlet var passwordHint: UILabel! // UILabel for displaying password hint.
    @IBOutlet var genderLabel: UILabel! // UILabel for displaying gender.
    @IBOutlet var countryLabel: UILabel! // UILabel for displaying country.
    @IBOutlet var countrydropdown: UIView! // UIView for selecting country from dropdown.
    @IBOutlet var countryLine: UILabel! // UILabel for displaying line below country dropdown.
    @IBOutlet var appleLoginBtn:UIButton! // UIButton for logging in using Apple ID.

    @IBOutlet var businessView: UIView! // UIView containing business registration fields.
    @IBOutlet var firstName: TKFormTextField! // TKFormTextField for entering first name.
    @IBOutlet var lastName: TKFormTextField! // TKFormTextField for entering last name.
    @IBOutlet var businessAddress: TKFormTextField! // TKFormTextField for entering business address.
    @IBOutlet var businessemail:TKFormTextField! // TKFormTextField for entering business email.
    @IBOutlet var street: TKFormTextField! // TKFormTextField for entering street name.
    @IBOutlet var optionalStreet: TKFormTextField! // TKFormTextField for entering optional street name.
    @IBOutlet var state: TKFormTextField! // TKFormTextField for entering state.
    @IBOutlet var city: TKFormTextField! // TKFormTextField for entering city.
    @IBOutlet var zipCode: TKFormTextField! // TKFormTextField for entering zip code.
    @IBOutlet var taxField: TKFormTextField! // TKFormTextField for entering tax information.
    @IBOutlet var businessPhone: TKFormTextField! // TKFormTextField for entering business phone number.
    @IBOutlet var businessPassword: TKFormTextField! // TKFormTextField for entering business password.
    @IBOutlet var businessVisibilityBtn: TKFormTextField! // TKFormTextField for showing/hiding business password.
    @IBOutlet var street1: TKFormTextField! // TKFormTextField for entering street1.

    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint! // NSLayoutConstraint for setting content height.
    @IBOutlet weak var nameTopConstraint: NSLayoutConstraint! // NSLayoutConstraint for setting top constraint of name field.
    @IBOutlet weak var fileOptionsHeight: NSLayoutConstraint! // NSLayoutConstraint for setting file options height.
    @IBOutlet weak var fileViews: UIView! // UIView containing file options.
    @IBOutlet var inCorporationDocName: UIButton! // UIButton for selecting incorporation document.
    @IBOutlet var taxIDName: UIButton! // UIButton for selecting tax ID document.
    @IBOutlet var businessCertifi: UIButton! // UIButton for selecting business certificate.
    @IBOutlet var otherDocName: UIButton! // UIButton for selecting other document.
    @IBOutlet var tableview: UITableView! // UITableView for displaying registration form.

    @IBOutlet weak var agreeBtnYPos: NSLayoutConstraint! // NSLayoutConstraint for setting agree button position.

    @IBOutlet weak var connectWithLabel: UILabel! // UILabel for displaying social login options.
    @IBOutlet weak var socialLoginView: UIView! // UIView containing social login options.
    @IBOutlet weak var lineOne: UIView! // UIView for separating UI elements.
    @IBOutlet weak var lineTwo: UIView! // UIView for separating UI elements.
     
    
    var activeField: UITextField? // Keeps track of the active UITextField.
    var lastOffset: CGPoint? // Stores the last content offset of the UIScrollView.
    var keyboardHeight: CGFloat! // Height of the keyboard.
    var genderText: String? // Stores the selected gender.
    var RegisterArray: RegisterModelArray? // Array to store registration models.
    var RegisterModelResponse: RegisterModel? // Stores the registration model response.
    var faceBookDict: [String:Any] = [:] // Dictionary to store Facebook data.
    var termcondition: Bool = false // Flag indicating whether terms and conditions are accepted.
    var userName: String = "" // Stores the user's name.
    var email: String = "" // Stores the user's email.
    var profileUrl: String = "" // Stores the user's profile URL.
    var loginType: String = "" // Stores the login type (e.g., Facebook, Apple).
    var loginArray: loginModelArray? // Array to store login models.
    var loginModelResponse: loginModel? // Stores the login model response.
    var selectedFiles = [Int:Any]() // Dictionary to store selected files.
    var selectedFilesTypes = [String:String]() // Dictionary to store types of selected files.
    var selectedFileTag = 0 // Tag to identify selected file.
    var fileMetaData = [Int:String]() // Dictionary to store file metadata.
    var isSkipUpdateProfile = false // Flag indicating whether to skip updating the profile.
    // MARK: - Actions

    @IBAction func showCityAction(sender: UIButton) {
        debugPrint("showCityAction")
    }

    @IBAction func showStateAction(sender: UIButton) {
        debugPrint("showStateAction")
    }

    @IBAction func showBUVisibilityAction(sender: UIButton) {
        debugPrint("showBUVisibilityAction")
        if sender.isSelected {
            self.businessPassword.isSecureTextEntry = false
            sender.isSelected = false
        } else {
            self.businessPassword.isSecureTextEntry = true
            sender.isSelected = true
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLayoutSubviews() {
        // Set scroll view content size
        // self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 2500)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure text fields
        setUpTextfield()
        
        // Set initial state
        self.individualBtn.isSelected = true
        self.navigationController?.isNavigationBarHidden = true
        self.appleLoginBtn.layer.cornerRadius = appleLoginBtn.frame.size.width / 2
        self.appleLoginBtn.clipsToBounds = true
        self.appleLoginBtn.backgroundColor = .black

        // Register business view
        self.registerBusinessView()
        
        // Set up tap gesture to dismiss keyboard
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
    }

    // MARK: - Apple ID Login

    @IBAction func handleAuthorizationAppleIDButtonPress(sender: Any) {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let keychain = KeychainSwift()
            if let userID = keychain.get("Apple_user") {
                appleIDProvider.getCredentialState(forUserID: userID) {  (credentialState, error) in
                    switch credentialState {
                    case .authorized:
                        // The Apple ID credential is valid.
                        debugPrint("AppleLoginDetails authorized")
                        DispatchQueue.main.async {
                            let email = keychain.get("Apple_email")
                            let name = keychain.get("Apple_name")
                            self.userName = keychain.get("Apple_name") ?? ""
                            self.email = keychain.get("Apple_email") ?? ""
                            self.profileUrl = ""
                            self.isSkipUpdateProfile = true
                            self.socialLogin(socialType: "Apple")
                        }
                    case .revoked:
                        // The Apple ID credential is revoked.
                        self.appleLogin()
                    case .notFound:
                        // No credential was found, so show the sign-in UI.
                        self.appleLogin()
                    default:
                        break
                    }
                }
            } else {
                self.appleLogin()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    func registerBusinessView(){
           self.tableview.register(UINib(nibName: "BusinessRegCell", bundle: nil), forCellReuseIdentifier: "BusinessRegCell")
       }
    func appleLogin() {
        // Initiating Apple ID login
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }


    func setUpTextfield() {
        // Setting up text fields
        self.emailText.placeholder = "Email*"
        self.emailText.enablesReturnKeyAutomatically = true
        self.emailText.returnKeyType = .done
        self.emailText.delegate = self
        
        self.passwordText1.placeholder = "Password*"
        self.passwordText1.enablesReturnKeyAutomatically = true
        self.passwordText1.returnKeyType = .done
        self.passwordText1.delegate = self
        self.passwordText1.isSecureTextEntry = true
        
        self.nameText.placeholder = "Name*"
        self.nameText.enablesReturnKeyAutomatically = true
        self.nameText.returnKeyType = .done
        self.nameText.delegate = self
        
        self.mobileText.placeholder = "Mobile number"
        self.mobileText.enablesReturnKeyAutomatically = true
        self.mobileText.returnKeyType = .done
        self.mobileText.delegate = self
        
        self.businessName.placeholder = "Business Name*"
        self.businessName.enablesReturnKeyAutomatically = true
        self.businessName.returnKeyType = .done
        self.businessName.delegate = self
        
        // Validation logic
        self.addTargetForErrorUpdating(self.emailText)
        self.addTargetForErrorUpdating(self.passwordText1)
        self.addTargetForErrorUpdating(self.nameText)
        self.addTargetForErrorUpdating(self.mobileText)
        self.addTargetForErrorUpdating(self.businessName)
        self.addTargetForErrorUpdating(self.businessPhone)
        self.addTargetForErrorUpdating(self.businessPassword)
        self.addTargetForErrorUpdating(self.street1)
        self.addTargetForErrorUpdating(self.state)
        self.addTargetForErrorUpdating(self.city)
        self.addTargetForErrorUpdating(self.zipCode)
        self.addTargetForErrorUpdating(self.taxField)
        self.addTargetForErrorUpdating(self.firstName)
        self.addTargetForErrorUpdating(self.lastName)
        
        // Customize labels
        self.businessName.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.businessName.font = UIFont.systemFont(ofSize: 18)
        self.businessName.selectedTitleColor = UIColor.darkGray
        self.businessName.titleColor = UIColor.darkGray
        self.businessName.placeholderColor = UIColor.darkGray
        self.emailText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.emailText.font = UIFont.systemFont(ofSize: 18)
        self.emailText.selectedTitleColor = UIColor.darkGray
        self.emailText.titleColor = UIColor.darkGray
        self.emailText.placeholderColor = UIColor.darkGray;
        self.emailText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        self.passwordText1.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.passwordText1.font = UIFont.systemFont(ofSize: 18)
        self.passwordText1.errorLabel.font = UIFont.systemFont(ofSize: 18)
        self.passwordText1.selectedTitleColor = UIColor.darkGray
        self.passwordText1.titleColor = UIColor.darkGray
        self.passwordText1.placeholderColor = UIColor.darkGray
        self.nameText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.nameText.font = UIFont.systemFont(ofSize: 18)
        self.nameText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        self.nameText.selectedTitleColor = UIColor.darkGray
        self.nameText.titleColor = UIColor.darkGray
        self.nameText.placeholderColor = UIColor.darkGray
        self.mobileText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.mobileText.font = UIFont.systemFont(ofSize: 18)
        self.mobileText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        self.mobileText.selectedTitleColor = UIColor.darkGray
        self.mobileText.titleColor = UIColor.darkGray
        self.mobileText.placeholderColor = UIColor.darkGray
        
        
        self.emailText.accessibilityIdentifier = "email-textfield"
        self.passwordText1.accessibilityIdentifier = "password-textfield"
        self.nameText.accessibilityIdentifier = "name-textfield"
        self.mobileText.accessibilityIdentifier = "mobile-textfield"
        self.businessName.accessibilityIdentifier = "business-textfield"
        
        
        self.emailText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.emailText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.emailText.selectedLineHeight = 2
        self.passwordText1.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.passwordText1.selectedLineColor  = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.passwordText1.selectedLineHeight = 2
        self.mobileText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.mobileText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.mobileText.selectedLineHeight = 2
        self.nameText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.nameText.selectedLineColor  = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.nameText.selectedLineHeight = 2
        self.businessName.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.businessName.selectedLineColor  = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.businessName.selectedLineHeight = 2
    }
    /**
     Adds targets for error updating to the given text field.

     - Parameter textField: The text field to add targets to.
     */
    func addTargetForErrorUpdating(_ textField: TKFormTextField) {
        textField.addTarget(self, action: #selector(clearErrorIfNeeded), for: .editingChanged)
        textField.addTarget(self, action: #selector(updateError), for: .editingDidEnd)
    }
    /**
     Updates error message for the given text field.

     - Parameter textField: The text field to update error message for.
     */
    @objc func updateError(textField: TKFormTextField) {
        textField.error = validationError(textField)
        
    }
    /**
     Clears error message for the given text field if needed.

     - Parameter textField: The text field to clear error message for.
     */
    @objc func clearErrorIfNeeded(textField: TKFormTextField) {
        if validationError(textField) == nil {
            textField.error = nil
        }
        
    }
    /**
     Validates the input text in the given text field.

     - Parameter textField: The text field to validate.
     - Returns: The error message if validation fails, otherwise nil.
     */
    private func validationError(_ textField: TKFormTextField) -> String? {
        // Validation logic for different text fields

        if textField == emailText {
            return TKDataValidator.email(text: textField.text)
        }
        if textField == passwordText1 {
            return TKDataValidator.password(text: textField.text)
        }
        if textField == nameText
        {
            return TKDataValidator.name(text: textField.text)
        }
        if textField == mobileText {
            return TKDataValidator.mobileNumber(text: textField.text)
        }
        if textField == businessName{
            return TKDataValidator.businessName(text: textField.text)
        }
        if textField == self.businessPhone {
            return TKDataValidator.mobileNumber(text: textField.text)
        }
        if textField == self.businessPassword {
            return TKDataValidator.password(text: textField.text)
        }
        if textField == self.street1 {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.city {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.state {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.zipCode {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.firstName {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.lastName {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.taxField {
            return TKDataValidator.isValidTaxIDText(textfield: textField)
        }
        return nil
    }
    /**
     Dismisses the keyboard when tapping outside the active text field.

     - Parameter gesture: The gesture recognizer.
     */
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    /**
     Handles the action when the user selects male, female, or other gender.

     - Parameter sender: The button triggering the action.
     */
    @IBAction func maleOrFemaleAction(_ sender: UIButton) {
        if(sender.tag == 0)
        {
            femaleBtn.isSelected = false
            otherBtn.isSelected = false
            maleBtn.isSelected = true
            genderText = "M"
        }
        else if(sender.tag == 1)
        {
            
            femaleBtn.isSelected = true
            maleBtn.isSelected = false
            otherBtn.isSelected = false
            genderText = "F"
        }
        else
        {
            femaleBtn.isSelected = false
            maleBtn.isSelected = false
            otherBtn.isSelected = true
            genderText = "O"
        }
        
    }
    /**
     Handles the action when the user selects business or individual registration.

     - Parameter sender: The button triggering the action.
     */
    @IBAction func businessAction(_ sender: UIButton){
        // Toggling visibility of business view
        businessBtn.isSelected = true
        individualBtn.isSelected = false
        self.showBusinessView(show: true)
       
    }
    /**
     Shows or hides the business view based on the input parameter.

     - Parameter show: Boolean value indicating whether to show or hide the business view.
     */
    func showBusinessView(show:Bool){
        // Toggling visibility of business-related UI elements based on the input parameter
        self.businessView.isHidden = show ? false : true
        self.businessName.isHidden = show ? false : true
        
        // individual
        self.lineOne.isHidden = show ? true : false
        self.lineTwo.isHidden = show ? true : false
        self.connectWithLabel.isHidden = show ? true : false
        self.socialLoginView.isHidden = show ? true : false
        self.nameText.isHidden = show ? true : false
        self.emailText.isHidden = show ? true : false
        self.mobileText.isHidden = show ? true : false
        self.passwordText1.isHidden = show ? true : false
        self.showhidebtn.isHidden = show ? true : false
        self.passwordHint.isHidden = show ? true : false
        self.maleBtn.isHidden = show ? true : false
        self.femaleBtn.isHidden = show ? true : false
        self.otherBtn.isHidden = show ? true : false
        self.countryBtn.isHidden = show ? true : false
       // self.countryText.isHidden = show ? true : false
        self.genderLabel.isHidden = show ? true : false
        self.countryLabel.isHidden = show ? true : false
        self.countryLine.isHidden = show ? true : false
        self.countrydropdown.isHidden = show ? true : false
        self.agreeBtnYPos.constant = show ? 880 : 16

    
    }
    
    /**
     Handles the action when the user selects individual registration.

     - Parameter sender: The button triggering the action.
     */
    @IBAction func individualAction(_ sender: UIButton){
        businessBtn.isSelected = false
        individualBtn.isSelected = true
        // Hiding business-related UI elements and adjusting constraints
        self.fileOptionsHeight.constant = 0
        self.fileViews.isHidden = true
        self.businessName.isHidden = true
        self.nameText.isHidden = false
        
        // Hiding business view
        self.showBusinessView(show: false)
    }

    /**
     Updates the file selection UI based on the selected files.

     */
    
    func updateFileSelection(){
        // Updating file selection UI elements based on selected files
        if self.fileMetaData[0] != nil {
            self.inCorporationDocName.setTitle(self.fileMetaData[0], for: .normal)
            self.inCorporationDocName.setTitleColor(.blue, for: .normal)
        }else{
            self.inCorporationDocName.setTitle("No file choosen", for: .normal)
            self.inCorporationDocName.setTitleColor(.black, for: .normal)
        }
        if self.fileMetaData[1] != nil {
            self.taxIDName.setTitle(self.fileMetaData[1], for: .normal)
            self.taxIDName.setTitleColor(.blue, for: .normal)
        }else{
            self.taxIDName.setTitle("No file choosen", for: .normal)
            self.taxIDName.setTitleColor(.black, for: .normal)
        }
        if self.fileMetaData[2] != nil {
            self.businessCertifi.setTitle(self.fileMetaData[2], for: .normal)
            self.businessCertifi.setTitleColor(.blue, for: .normal)
        }else{
            self.businessCertifi.setTitle("No file choosen", for: .normal)
            self.businessCertifi.setTitleColor(.black, for: .normal)
        }
        if self.fileMetaData[3] != nil {
            self.otherDocName.setTitle(self.fileMetaData[3], for: .normal)
            self.otherDocName.setTitleColor(.blue, for: .normal)
        }else{
            self.otherDocName.setTitle("No file choosen", for: .normal)
            self.otherDocName.setTitleColor(.black, for: .normal)
        }
    }
    
    
    /**
     Handles the action when the user taps on the file upload button.

     - Parameter sender: The button triggering the action.
     */
    @IBAction func onFileUploadAction(sender:UIButton){
        debugPrint("onFileUploadAction",sender.tag)
        self.selectedFileTag = sender.tag
        self.openFilePicker(tag: sender.tag)
    }
    
    /**
     Opens the file picker for selecting documents.

     - Parameter tag: The tag to identify the file upload button.
     */
    func openFilePicker(tag:Int){
        // Configuring document picker and presenting it

        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item", "public.content","public.text", "public.data","public.composite-content","public.png","public.jpeg"], in: .import)

        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    /**
     Checks if all required files are uploaded.

     - Returns: A boolean indicating whether all files are uploaded.
     */
    func isAllFilesUpdated() -> Bool {
        let keys = self.selectedFiles.keys
        if keys.contains(0) && keys.contains(1) && keys.contains(2) {
            return true
        }
        return false
    }

    /**
     Returns the key name based on the file upload button tag.

     - Parameter tag: The tag identifying the file upload button.
     - Returns: The corresponding key name for the file.
     */
    func getKeyName(tag:Int) -> String {
        switch tag{
        case 0:
            return "incorp_doc"
        case 1:
            return "tax_id_doc"
        case 2:
            return "good_standing_doc"
        case 3:
            return "oth_doc"
        default:
            return ""
        }
    }

    func isAllFieldsValid() -> Bool {
        //|| self.optionalStreet.text!.isBlankOrEmpty()
        if self.businessBtn.isSelected {
            if self.businessName.text!.isBlankOrEmpty() || self.firstName.text!.isBlankOrEmpty()
                || self.lastName.text!.isBlankOrEmpty() || self.businessemail.text!.isBlankOrEmpty()
                || self.businessPhone.text!.isBlankOrEmpty()
                || self.businessPassword.text!.isBlankOrEmpty()
                || self.street1.text!.isBlankOrEmpty()
                
                || self.state.text!.isBlankOrEmpty()
                || self.city.text!.isBlankOrEmpty()
                || self.zipCode.text!.isBlankOrEmpty() || self.taxField.text!.isBlankOrEmpty()
                || self.isAllFilesUpdated() == false {
                return false
            }
                
        }
        else {
            
            if ((nameText.text == "") || (emailText.text == "") || (passwordText1.text == "" || (TKDataValidator.password(text: passwordText1.text) != nil))) {
                return false
            }
            
        }
        
        return true
    }
    
    @IBAction func registerAction(_ sender: UIButton){
        self.view.endEditing(true)
        
        // Check if the user has accepted the terms and conditions
        if termcondition == false {
            showAlertWithMessage("Please select term and condition")
            return
        }
        
        // Check if all fields are valid
        if !isAllFieldsValid() {
            showAlertWithMessage("Fill all required fields")
            return
        }
        
        // If the registration is for a business, validate the business password
        if businessBtn.isSelected {
            if let passwordError = TKDataValidator.password(text: self.businessPassword.text) {
                showAlertWithMessage(passwordError)
                return
            }
        }
        
        // Construct parameters dictionary based on registration type
        var postDict: Parameters = [
            "name": nameText.text ?? "",
            "email": emailText.text ?? "",
            "password": passwordText1.text ?? "",
            "phone": mobileText.text ?? "",
            "country": UserDefaults.standard.value(forKey: "selectedcountry") ?? "US",
            "gender": genderText ?? "",
            "type": businessBtn.isSelected ? "business" : "individual",
            "business_name": businessName.text ?? "",
            "terms": "Yes"
        ]
        
        // Additional parameters for business registration
        if businessBtn.isSelected {
            postDict["ein"] = taxField.text!
            postDict["email"] = businessemail.text!
            postDict["name"] = "\(firstName.text ?? "") \(lastName.text ?? "")"
            postDict["phone"] = businessPhone.text!
            postDict["address1"] = street1.text!
            postDict["address2"] = optionalStreet.text!
            postDict["city"] = city.text!
            postDict["state"] = state.text!
            postDict["zip"] = zipCode.text!
            postDict["password"] = businessPassword.text!
            
            // Add file parameters
            for (key, val) in selectedFiles {
                let keyName = getKeyName(tag: key)
                postDict[keyName] = val
            }
            // Add file types parameters
            for (key, val) in selectedFilesTypes {
                postDict[key] = val
            }
        }
        
        // Perform API request
        let registerUrl = URLHelper.iDonateRegister
        showLoadingHUD()
        WebserviceClass.sharedAPI.performRequest(isFileAdded: businessBtn.isSelected, type: RegisterModel.self, urlString: registerUrl, methodType: .post, parameters: postDict, success: { (response) in
            self.RegisterModelResponse = response
            self.RegisterArray = self.RegisterModelResponse?.registerArray
            self.registerResponse()
            self.hideLoadingHUD()
        }) { (response) in
            self.hideLoadingHUD()
        }
    }
    /**
     Handles the response received after attempting user registration.

     This function displays an alert based on the registration status:
     - If the registration is successful (status = 1), it presents an alert with a success message and navigates the user to the login view controller.
     - If the registration fails (status ≠ 1), it presents an alert with a failure message.

     - Note: This function assumes that `RegisterModelResponse` contains the response data from the registration attempt.**/
    func registerResponse() {
        if let status = RegisterModelResponse?.status {
            if status == 1 {
                let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
                let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                let messageAttrString = NSMutableAttributedString(string: RegisterModelResponse?.message ?? "", attributes: messageFont)
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                        self.navigationController?.pushViewController(loginVC, animated: true)
                    }
                }
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
                let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                let messageAttrString = NSMutableAttributedString(string: RegisterModelResponse?.message ?? "", attributes: messageFont)
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                let okAction = UIAlertAction(title: "Ok", style: .default) { _ in

                }
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }


    // Helper function to show alert with message
    func showAlertWithMessage(_ message: String) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
        let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont)
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
        let contact = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(contact)
        self.present(alertController, animated: true, completion: nil)
    }

    // Helper function to show loading HUD
    func showLoadingHUD() {
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = .indeterminate
        loadingNotification.label.text = "Loading"
    }

    // Helper function to hide loading HUD
    func hideLoadingHUD() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
    }

    
    // MARK: - Functions

    /// Handles the action when the user taps a button to go back.
    /// - Parameter _sender: The UIButton triggering the action.
    @objc func backAction(_sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Returning To Login Without Making Changes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.view.endEditing(true)
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    /// Adjusts the content inset of a scroll view when the keyboard is about to be shown.
    /// - Parameter notification: The NSNotification object containing information about the keyboard.
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 100
        scrollView.contentInset = contentInset
    }

    /// Resets the content inset of a scroll view when the keyboard is about to be hidden.
    /// - Parameter notification: The NSNotification object containing information about the keyboard.
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

    /// Prepares the view controller for display.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Observe keyboard changes
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Set country button title if selected
        if let selectedName = UserDefaults.standard.value(forKey: "selectedname") as? String {
            countryBtn.setTitle(selectedName, for: .normal)
        }
        
        // Set Google sign-in delegate
        GIDSignIn.sharedInstance().delegate = self
    }

    /// Cleans up resources before the view controller's view is removed from the view hierarchy.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    /// Checks if a given string is a valid email address.
    /// - Parameter testStr: The string to be validated.
    /// - Returns: A Boolean value indicating whether the string is a valid email address.
    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    // MARK: - Actions

    /// Handles the action when the user taps a button to sign in with Google.
    /// - Parameter sender: The UIButton triggering the action.
    @IBAction func googleSignIN(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance()?.signIn()
    }

    
    @IBAction func facebookLogin(_ sender:UIButton) {
        
        let fbLoginManager : LoginManager = LoginManager()
        if let token = AccessToken.current,
           !token.isExpired {
            // User is logged in, do work such as go to next view controller.
            fbLoginManager.logOut()
        }
        fbLoginManager.logIn(permissions: ["email","public_profile"], from: self) { (result, error) in
            print(result?.isCancelled as Any)
            
            if((result?.isCancelled)!) {
                self.view .endEditing(true)
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterVC") as? RegisterVC
                self.navigationController?.pushViewController(vc!, animated: false)
            }
            
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        if((AccessToken.current) != nil){
                            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completion: { (connection, result, error) -> Void in
                                print(result!)
                                
                                if (error == nil){
                                    self.faceBookDict = result as! [String : AnyObject]
                                    print( self.faceBookDict["email"] as Any)
                                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileVC
                                    vc?.userEmail = self.faceBookDict["email"] as! String
                                    vc?.userName =  self.faceBookDict["name"] as! String
                                    let facebookID = self.faceBookDict["id"]
                                    let facebookProfile: String = "http://graph.facebook.com/\(facebookID ?? "")/picture?type=small"
                                    
                                    self.userName = self.faceBookDict["name"] as! String
                                    self.email = self.faceBookDict["email"] as! String
                                    self.profileUrl = facebookProfile
                                    
                                    self.socialLogin(socialType: "Facebook")
                                    //print(self.dict)
                                }
                            })
                        }
                    }
                }
            }
            else{
                print("cancel by user")
            }
        }
        
    }
    
    @IBAction func twitterLogin(_ sender: UIButton) {
        
        TwitterHandler.shared.loginWithTwitter(self,{ userinfo in
            self.view.isUserInteractionEnabled = true
            print(userinfo.email)
            
            self.userName = userinfo.userfName
            self.email = userinfo.email
            self.socialLogin(socialType: "Twitter")
            
        }, {
            
        })
    
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
       
        if let error = error {
            self.view .endEditing(true)
            print("\(error.localizedDescription)")
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterVC") as? RegisterVC
            self.navigationController?.pushViewController(vc!, animated: false)
        } else {
            
            print(user.userID )
            print(user.profile.name )
            
            var pictures :URL?
            if (GIDSignIn .sharedInstance().currentUser.profile.hasImage) {
                let dimension = round(100 * UIScreen.main.scale);
                pictures = user.profile.imageURL(withDimension: UInt(dimension))
            }
            
            userName = user.profile.name
            email = user.profile.email
            profileUrl = pictures?.absoluteString ?? ""
            socialLogin(socialType: "Gmail")
                        
        }
        
    }
    
    func socialLogin(socialType:String) {
        let postDict: Parameters = ["name": userName,"email":email ,"login_type":socialType,"photo":profileUrl,"type":self.businessBtn.isSelected ? "business" : "individual"]
        let socialLoginUrl = String(format: URLHelper.iDonateSocialLogin)
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        WebserviceClass.sharedAPI.performRequest(type: loginModel.self, urlString: socialLoginUrl, methodType: HTTPMethod.post, parameters: postDict,success: { (response) in
            self.loginModelResponse = response
            self.loginArray  = response.data
            self.loginType = "Social"
            UserDefaults.standard.set("Social", forKey: "loginType")
            self.loginResponsemethod()
            print("Result: \(String(describing: response))") // response serialization result
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }) { (response) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
        
    }
    
    func loginResponsemethod() {
        
        if(self.loginModelResponse?.status == 1) {
            
            let newPerson = UserDetails(name: self.loginArray!.name!, email: self.loginArray!.email!, mobileNUmber: self.loginArray?.phone_number ?? "", gender: self.loginArray?.gender ?? "", profileUrl:self.loginArray?.photo ?? "", country: self.loginArray?.country ?? "US",token: self.loginArray?.token ?? "",userID:self.loginArray?.user_id ?? "", type: self.loginArray?.type ?? "", businessName: self.loginArray?.business_name ?? "", terms: self.loginArray?.terms ?? "No")
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: newPerson)
            UserDefaults.standard.set(encodedData, forKey: "people")
            UserDefaults.standard.set( self.loginArray!.name, forKey: "username")
            
            if(loginType == "Social") &&  (self.isSkipUpdateProfile == false){
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileVC
                vc?.userName = self.userName
                vc?.userEmail = self.email
                vc?.loginType = self.loginType
                self.navigationController?.pushViewController(vc!, animated: true)
            }else {
                UserDefaults.standard.set("Login", forKey: "loginType")
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            
        }else {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:(self.loginModelResponse?.message ?? "")!, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func showTermsAndCondition(_ sender:UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as? TermsAndConditionsViewController
        vc?.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func agreeaction(_ sender: UIButton){
        if(sender.isSelected == true){
            sender.isSelected = false
            termcondition = false
        } else {
            sender.isSelected = true
            termcondition = true
        }
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension RegisterVC:UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == nameText){
            
        } else if(textField == emailText){
            
        } else if(textField == mobileText){
            
        } else if(textField == passwordText1){
            
        }
        else if(textField == businessName){
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == nameText) {
            if(nameText.text?.count == 0) {

            }
//            else{
//                let isValid = isValidText(testStr: nameText.text!)
//                if(isValid == false) {
//                    
//                }
//            }
        }
       
        else if(textField == emailText)
        {
            if(emailText.text?.count == 0)
            {
                
            }else{
                let isValid = isValidEmail(testStr: emailText.text!)
                if(isValid == false) {
                    
                }
            }
        }
        else if(textField == mobileText)
        {
            
            debugPrint("mobile validation")
            if(mobileText.text?.count == 0)
            {
                
            }
            else if((mobileText.text?.count)! < 10)
                
            {
                
            }
        }
        else if(textField == passwordText1)
        {
            if(passwordText1.text?.count == 0)
            {
                
            }
            else if((passwordText1.text?.count)! < 6)
                
            {
                
            }
        }
        else if(textField == businessName)
        {
            if(businessName.text?.count == 0)
            {
                
            }
            else if((businessName.text?.count)! < 6)
                
            {
                
            }
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //       // activeField?.resignFirstResponder()
        //        activeField = nil
        
        
    
        if(textField == self.businessPhone) {
            
            
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) {
                    print("Backspace was pressed")
                    return true
                }
            }
            if((businessPhone.text?.count)! < 10) {
                return true
            } else{
                return false
            }
            
            
            
            
            
        }
        if(textField == mobileText) {
            
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) {
                    print("Backspace was pressed")
                    return true
                }
            }
            
            if((mobileText.text?.count)! < 10) {
                return true
            } else{
                return false
            }
            
            
        } else{
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}

//extension RegisterVC:GIDSignInUIDelegate {
//
//    private func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
//
//    }
//
//    // Present a view that prompts the user to sign in with Google
//    private func signIn(signIn: GIDSignIn!,
//                        presentViewController viewController: UIViewController!) {
//        self.present(viewController, animated: true, completion: nil)
//    }
//
//    // Dismiss the "Sign in with Google" view
//    private func signIn(signIn: GIDSignIn!,
//                        dismissViewController viewController: UIViewController!) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    class func convertImageToBase64(image: UIImage) -> String {
//        let imageData = image.pngData()!
//        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
//    }
//}

extension RegisterVC:UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        debugPrint("docs.url",urls)
        let firstDoc = urls.first
        debugPrint("docs.url",firstDoc?.lastPathComponent)
        do {
            self.fileMetaData[self.selectedFileTag] = firstDoc?.lastPathComponent
            let contenType = firstDoc?.pathExtension
            self.selectedFiles[self.selectedFileTag] = try Data(contentsOf: firstDoc!).base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
            self.selectedFilesTypes[self.getKeyName(tag: self.selectedFileTag)] = contenType
           
        }
        catch {
            debugPrint("file.picker.error",error.localizedDescription)
        }
        self.updateFileSelection()
        debugPrint("selected files",self.selectedFiles.keys)
        
    }
    
}


extension String {
    func isBlankOrEmpty() -> Bool {

      // Check empty string
      if self.isEmpty {
          return true
      }
      // Trim and check empty string
      return (self.trimmingCharacters(in: .whitespaces) == "")
   }
}
@available(iOS 13.0, *)
extension RegisterVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugPrint("authorizationController:didCompleteWithError",error.localizedDescription)
        
        var alert = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            debugPrint("Apple fullName",fullName?.givenName)
            debugPrint("Apple email",email)
            debugPrint("Apple userIdentifier",userIdentifier)
            let keychain = KeychainSwift()
            
            if userIdentifier != nil {
                keychain.set(email ?? "", forKey: "Apple_email")
                keychain.set(userIdentifier, forKey: "Apple_user")
                keychain.set(fullName?.givenName ?? "", forKey: "Apple_name")
            }
            
            
            self.doAppleLogin(email:email ?? "",name: fullName?.givenName)
           
            
           
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
           
            let username = passwordCredential.user
            let password = passwordCredential.password
            debugPrint("Apple username",username)
            let keychain = KeychainSwift()
            keychain.set("", forKey: "Apple_email")
            keychain.set(username, forKey: "Apple_user")
            keychain.set("", forKey: "Apple_name")
            self.doAppleLogin(email: "",name: "")
           
        default:
            break
        }
    }
    
    func doAppleLogin(email:String? = "",name:String? = "") {
        self.isSkipUpdateProfile = true
        self.userName = name ?? ""
        self.email = email ?? ""
        self.profileUrl = ""
        
        self.socialLogin(socialType: "Apple")

    }
}

@available(iOS 13.0, *)
extension RegisterVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
   
}
