//
//  UpdateProfileVC.swift
//  i2-Donate

import UIKit
import TKFormTextField
import Alamofire
import AlamofireImage
import MBProgressHUD

/**
 `UpdateProfileVC` is a view controller responsible for updating user profile information. It manages the user interface elements related to profile editing and interacts with backend services to save changes.

 */
class UpdateProfileVC: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet var maleBtn: UIButton!
    @IBOutlet var femaleBtn: UIButton!
    @IBOutlet var otherBtn: UIButton!
    @IBOutlet var countryBtn: UIButton!
    @IBOutlet var updateBtn: UIButton!
    @IBOutlet var skipBtn: UIButton!
    @IBOutlet var businessBtn: UIButton!
    @IBOutlet var individualBtn: UIButton!
    @IBOutlet var nameText: TKFormTextField!
    @IBOutlet var emailText: TKFormTextField!
    @IBOutlet var mobileText: TKFormTextField!
    @IBOutlet var businessName: TKFormTextField!
    @IBOutlet weak var nameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var businessBtnLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var termsView: UIView!
    @IBOutlet var registerAsLabel: UILabel!
    
    // MARK: - Properties
    
    let picker = UIImagePickerController()
    var updateArray: loginModelArray?
    var UpdateModelResponse: UpdateModel?
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    var yAxix: CGFloat = 10
    var height: CGFloat = 10
    var genderText: String = ""
    var updateType: String = ""
    var userName: String = ""
    var userEmail: String = ""
    var loginType: String = ""
    var registeredType = String()
    var comingFromTypes = false
    var termCondition: Bool = false
    
    // MARK: - Enum
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        // Add gesture recognizer to profile image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.numberOfTapsRequired = 1
        // Round profile image
        self.profileImage.layer.cornerRadius = 60
        self.profileImage.clipsToBounds = true
        // Set menu button frame
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        // Add target for menu button
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        // Add gesture recognizer to container view
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        // Observe keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Set up text fields
        setUpTextfield()
        // Update UI based on update type
        if(updateType == "update") {
            self.skipBtn.isHidden = true
            registerAsLabel.text = "Registered as"
            self.businessBtn.isUserInteractionEnabled = false
            self.individualBtn.isUserInteractionEnabled = false
            comingFromTypes = true
        }
        // Fetch profile details
        updateProfileDetails()
        // Set update button visibility
        self.updateBtn.isHidden = false
        // Add error updating targets for text fields
        self.addTargetForErrorUpdating(self.emailText)
        self.addTargetForErrorUpdating(self.mobileText)
        self.addTargetForErrorUpdating(self.nameText)
        // Hide business button for social login
        if (loginType == "Social") {
            self.businessBtn.isHidden = true
            self.skipBtn.isHidden = true
        }
    }
    
    // MARK: - Methods
    
    /**
     Adds error updating targets for TKFormTextField instances.
     
     - Parameter textField: The TKFormTextField instance to add targets for.
     */
    func addTargetForErrorUpdating(_ textField: TKFormTextField) {
        textField.addTarget(self, action: #selector(clearErrorIfNeeded), for: .editingChanged)
        textField.addTarget(self, action: #selector(updateError), for: .editingDidEnd)
    }
    
    /**
     Updates error for the specified TKFormTextField instance.
     
     - Parameter textField: The TKFormTextField instance.
     */
    @objc func updateError(textField: TKFormTextField) {
        textField.error = validationError(textField)
    }
    
    /**
     Clears error if needed for the specified TKFormTextField instance.
     
     - Parameter textField: The TKFormTextField instance.
     */
    @objc func clearErrorIfNeeded(textField: TKFormTextField) {
        if validationError(textField) == nil {
            textField.error = nil
        }
    }
    
    /**
     Validates text field and returns error message if validation fails.
     
     - Parameter textField: The TKFormTextField instance.
     - Returns: Optional error message.
     */
    private func validationError(_ textField: TKFormTextField) -> String? {
        if textField == nameText {
            return TKDataValidator.isValidText(textfield: textField)
        }
        return nil
    }
    
    /**
     Handles tap action on profile image view.
     
     - Parameter sender: The tap gesture recognizer.
     */
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        // Show image selection options
        let alert = UIAlertController(title: "Take A Photo To Upload", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        // Add actions to alert controller
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = profileImage
            presenter.sourceRect = profileImage.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     
     Opens the photo gallery for selecting an image.
     
     This function configures the UIImagePickerController to allow editing and sets its source type to the photo library.
     It
     
     **/
    func openGallery(){
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    
    
    
    
    
    /**
     Handles the viewWillAppear event to set up UI elements based on stored data and login type.
     
     This method is called when the view is about to appear on the screen. It checks if a country name is stored in UserDefaults and sets the title of the country button accordingly. Additionally, it hides the business button if the login type is "Social".
     */
    override func viewWillAppear(_ animated: Bool) {
        if let selectedName = UserDefaults.standard.value(forKey: "selectedname") as? String {
            countryBtn.setTitle(selectedName, for: .normal)
        }
        if loginType == "Social" {
            businessBtn.isHidden = true
        }
    }
    
    
    
    /**
     Opens the camera for capturing photos.
     
     This method checks if the device has a camera available. If the camera is available, it sets up the image picker controller to capture photos, allows editing, and presents it. If the camera is not available, it presents a warning alert informing the user that the device doesn't have a camera.
     */
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    /**
     Sets up the text fields with appropriate placeholder, font, and color configurations.
     
     This method configures the email, name, business name, and mobile number text fields with placeholder text, font settings, color configurations, and accessibility identifiers.
     */
    func setUpTextfield() {
        // Configure email text field
        emailText.placeholder = "Email"
        emailText.enablesReturnKeyAutomatically = true
        emailText.returnKeyType = .next
        emailText.delegate = self
        emailText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        emailText.font = UIFont.systemFont(ofSize: 18)
        emailText.selectedTitleColor = UIColor.darkGray
        emailText.titleColor = UIColor.darkGray
        emailText.placeholderColor = UIColor.darkGray
        emailText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        emailText.accessibilityIdentifier = "email-textfield"
        emailText.lineColor = UIColor(red:0.96, green:0.87, blue:0.94, alpha:1.0)
        emailText.selectedLineColor = UIColor(red:0.82, green:0.59, blue:0.77, alpha:1.0)
        
        // Configure name text field
        
        self.nameText.placeholder = "Name"
        self.nameText.enablesReturnKeyAutomatically = true
        self.nameText.returnKeyType = .done
        self.nameText.delegate = self
        self.nameText.isSecureTextEntry = false
        
        // Configure buisness text field
        
        self.businessName.placeholder = "Business Name"
        self.businessName.enablesReturnKeyAutomatically = true
        self.businessName.returnKeyType = .done
        self.businessName.delegate = self
        self.businessName.isSecureTextEntry = false
        
        // Configure Mobile text field
        
        self.mobileText.placeholder = "Mobile number"
        self.mobileText.enablesReturnKeyAutomatically = true
        self.mobileText.returnKeyType = .next
        self.mobileText.delegate = self
        
        // Configure EMail text field
        
        self.emailText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.emailText.font = UIFont.systemFont(ofSize: 18)
        self.emailText.selectedTitleColor = UIColor.darkGray
        self.emailText.titleColor = UIColor.darkGray
        self.emailText.placeholderColor = UIColor.darkGray;
        self.emailText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        
        // Configure buisness name text field
        
        self.businessName.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.businessName.font = UIFont.systemFont(ofSize: 18)
        self.businessName.selectedTitleColor = UIColor.darkGray
        self.businessName.titleColor = UIColor.darkGray
        self.businessName.placeholderColor = UIColor.darkGray;
        self.businessName.errorLabel.font = UIFont.systemFont(ofSize: 18)
        
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
        self.nameText.accessibilityIdentifier = "name-textfield"
        self.mobileText.accessibilityIdentifier = "mobile-textfield"
        self.businessName.accessibilityIdentifier = "business-textfield"
        
        self.emailText.lineColor = UIColor(red:0.96, green:0.87, blue:0.94, alpha:1.0)
        self.emailText.selectedLineColor = UIColor(red:0.82, green:0.59, blue:0.77, alpha:1.0)
        self.businessName.lineColor = UIColor(red:0.96, green:0.87, blue:0.94, alpha:1.0)
        self.businessName.selectedLineColor = UIColor(red:0.82, green:0.59, blue:0.77, alpha:1.0)
        self.mobileText.lineColor = UIColor(red:0.96, green:0.87, blue:0.94, alpha:1.0)
        self.mobileText.selectedLineColor = UIColor(red:0.82, green:0.59, blue:0.77, alpha:1.0)
        self.nameText.lineColor = UIColor(red:0.96, green:0.87, blue:0.94, alpha:1.0)
        self.nameText.selectedLineColor  = UIColor(red:0.82, green:0.59, blue:0.77, alpha:1.0)
        // self.addTargetForErrorUpdating(self.mobileText)
    }
    
    
    /**
     Handles the action when the business button is tapped.
     
     This method sets the state of the business button to selected, hides the individual button, and adjusts the top constraint of the name text field to accommodate the business name text field.
     
     - Parameter sender: The button that triggered the action.
     */
    @IBAction func businessAction(_ sender: UIButton) {
        businessBtn.isSelected = true
        individualBtn.isSelected = false
        nameTopConstraint.constant = 80
        businessName.isHidden = false
    }
    
    /**
     Handles the action when the individual button is tapped.
     
     This method sets the state of the individual button to selected, hides the business name text field, and adjusts the top constraint of the name text field.
     
     - Parameter sender: The button that triggered the action.
     */
    @IBAction func indiualAction(_ sender: UIButton) {
        businessBtn.isSelected = false
        individualBtn.isSelected = true
        nameTopConstraint.constant = 30
        businessName.isHidden = true
    }
    
    /**
     Handles the gesture recognizer to dismiss the keyboard.
     
     This method resigns the first responder status of the active text field when a tap gesture is recognized.
     
     - Parameter gesture: The tap gesture recognizer.
     */
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    /**
     Handles the action when the male, female, or other button is tapped.
     
     This method updates the selected state of the gender buttons and sets the gender text accordingly.
     
     - Parameter sender: The button that triggered the action.
     */
    @IBAction func maleOrFemaleAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            femaleBtn.isSelected = false
            otherBtn.isSelected = false
            maleBtn.isSelected = true
            genderText = "M"
        case 1:
            femaleBtn.isSelected = true
            maleBtn.isSelected = false
            otherBtn.isSelected = false
            genderText = "F"
        case 2:
            femaleBtn.isSelected = false
            maleBtn.isSelected = false
            otherBtn.isSelected = true
            genderText = "O"
        default:
            break
        }
    }
    
    
    /**
     Updates the profile details based on stored user information.
     
     This method retrieves user information from UserDefaults and updates the UI elements accordingly. It sets the name, email, mobile number, business name (if applicable), selected country, profile image, gender, and terms acceptance status. It also handles button selections for individual and business types, and sets up the visibility of UI elements based on the user's profile type.
     */
    func updateProfileDetails() {
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            // Update UI with user information
            print("Printing user info....")
            print(myPeopleList.name)
            print(myPeopleList.type)
            print(myPeopleList.businessName)
            
            // Update UI elements based on user type
            if myPeopleList.type == "individual" {
                self.nameText.text = myPeopleList.name
                userEmail = myPeopleList.email
                if !myPeopleList.email.isEmpty {
                    self.emailText.text = myPeopleList.email
                }
                self.mobileText.text = myPeopleList.mobileNUmber
            } else if myPeopleList.type == "business" {
                self.nameText.text = myPeopleList.name
                self.businessName.text = myPeopleList.businessName
                self.emailText.text = myPeopleList.email
                self.mobileText.text = myPeopleList.mobileNUmber
            }
            
            // Update UI elements based on user type and terms acceptance
            if myPeopleList.type == "" || myPeopleList.type == "individual" {
                self.registeredType = "individual"
                self.individualBtn.isSelected = true
                self.businessBtn.isSelected = false
            }
            if myPeopleList.type == "" || myPeopleList.type == "business" {
                self.registeredType = "Business"
                nameTopConstraint.constant = 80
                self.businessName.isHidden = false
                self.businessBtn.isSelected = true
                self.individualBtn.isSelected = false
            }
            
            // Update UI elements based on terms acceptance status
            if myPeopleList.terms == "" || myPeopleList.terms == "No" {
                self.termsView.isHidden = false
                self.skipBtn.isHidden = true
                termCondition = false
            } else {
                termCondition = true
                self.termsView.isHidden = true
            }
            
            // Update UI elements based on gender
            switch myPeopleList.gender {
            case "F":
                femaleBtn.isSelected = true
                genderText = "F"
            case "M":
                maleBtn.isSelected = true
                genderText = "M"
            case "O":
                otherBtn.isSelected = true
                genderText = "O"
            default:
                break
            }
            
            // Update profile image
            if myPeopleList.profileUrl == "" {
                self.profileImage.image = UIImage(named: "profile")
            } else {
                let imgUrl = String(format: "%@%@", UPLOAD_URL, myPeopleList.profileUrl)
                let profileImage = URL(string: imgUrl)!
                debugPrint("fully url", profileImage)
                self.profileImage.contentMode = .scaleAspectFill
                self.profileImage.af.setImage(withURL: profileImage, placeholderImage: #imageLiteral(resourceName: "defaultImageCharity"))
            }
            
            // Update selected country
            if myPeopleList.country != "" {
                let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: myPeopleList.country])
                if let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) {
                    UserDefaults.standard.setValue(name, forKey: "selectedname")
                    UserDefaults.standard.setValue(myPeopleList.country, forKey: "selectedcountry")
                    self.countryBtn.setTitle(name, for: .normal)
                }
            } else {
                UserDefaults.standard.setValue("US", forKey: "selectedcountry")
                UserDefaults.standard.setValue("United States", forKey: "selectedname")
                self.countryBtn.setTitle(UserDefaults.standard.value(forKey: "selectedname") as? String ?? "US" , for: .normal)
            }
            
            
            // Enable text fields for editing
            self.nameText.isUserInteractionEnabled = true
            self.emailText.isUserInteractionEnabled = true
        }
    }
    /**
     Displays an alert with the given message.
     
     - Parameter message: The message to be displayed in the alert.
     */
    func showErrorAlert(message:String){
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
        
        let messageAttrString = NSMutableAttributedString(string:message, attributes: messageFont)
        
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
        
        let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            
        }
        
        alertController.addAction(contact)
        
        self.present(alertController, animated: true, completion: nil)
    }
    /**
     Method to handle updating user profile details.
     
     This method fetches the user's details from UserDefaults, compares them with the updated values, and sends a request to update the user's profile if any changes are detected.
     
     - Note: This method checks if there are changes in the user's name, email, phone number, gender, profile photo, business name, country, and terms acceptance status. If there are changes, it constructs a request payload with the updated data and sends a network request to update the user's profile.
     
     - Important: This method also performs validation for required fields (name and terms acceptance), and displays alert messages if validation fails.
     
     - Parameter sender: The button triggering the update action.
     */
    @IBAction func updateAction(_ sender: UIButton) {
        var alertMessage = ""
        
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            let imageData = profileImage.image?.jpegData(compressionQuality: 0.25)
            
            let photoString = imageData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
            let updatedName = nameText.text ?? ""
            let originalName = myPeopleList.name
            
            let updatedEmail = emailText.text ?? ""
            let originalEmail = myPeopleList.email
            let updatedPhone = mobileText.text ?? ""
            let originalPhone = myPeopleList.mobileNUmber
            let updatedGender = genderText ?? ""
            let originalGender = myPeopleList.gender
            let updatedPhoto =  photoString ?? ""
            let originalPhoto = myPeopleList.profileUrl
            let updatedBuisness =  businessName.text ?? ""
            let originalBuisness = myPeopleList.businessName
            let updatedTerms =  termCondition == false ? "No" : "Yes"
            let originalTerms = myPeopleList.terms
            let updatedCountry =  UserDefaults.standard.value(forKey: "selectedcountry") as? String ?? "US"
            let originalCountry = myPeopleList.country
            // Check if values have changed
            if updatedName != originalName || updatedEmail != originalEmail || updatedPhone != originalPhone || updatedGender != originalGender || updatedPhoto != originalPhoto || updatedBuisness != originalBuisness || updatedCountry != originalCountry || updatedTerms != originalTerms{
                // Only include changed fields in the request payload
                var updateData: [String: Any] = [:]
                if updatedName != originalName {
                    updateData["name"] = updatedName
                }
                if updatedEmail != originalEmail || updatedEmail != "" {
                    updateData["email"] = updatedEmail
                }
                if updatedPhone != originalPhone || updatedPhone != ""{
                    updateData["phone"] = updatedPhone
                }
                if updatedGender != originalGender {
                    updateData["gender"] = updatedGender
                }
                if updatedPhoto != originalPhoto {
                    updateData["photo"] = updatedPhoto
                }
                if updatedCountry != originalCountry {
                    updateData["country"] = updatedCountry
                }
                if updatedBuisness != originalBuisness {
                    updateData["business_name"] = updatedBuisness
                }
                if updatedTerms != originalTerms {
                    updateData["terms"] = updatedTerms
                }
                updateData["user_id"] = myPeopleList.userID
                
                updateData["token"] = myPeopleList.token
                
                guard let name = nameText.text, name != "" else {
                    
                    
                    
                    let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
                    
                    let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                    
                    let messageAttrString = NSMutableAttributedString(string:"Please enter the name", attributes: messageFont)
                    
                    alertController.setValue(messageAttrString, forKey: "attributedMessage")
                    
                    let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                        
                    }
                    
                    alertController.addAction(contact)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                    
                }
                
                
                
                
                
                guard termCondition != false else {
                    
                    
                    let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
                    
                    let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                    
                    let messageAttrString = NSMutableAttributedString(string:"Please check the terms and conditions", attributes: messageFont)
                    
                    alertController.setValue(messageAttrString, forKey: "attributedMessage")
                    
                    let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                        
                    }
                    
                    alertController.addAction(contact)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                    
                    return
                    
                }
                
                let updateProfileUrl = String(format: URLHelper.iDonateUpdateProfile)
                
                let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
                
                loadingNotification.mode = MBProgressHUDMode.indeterminate
                
                loadingNotification.label.text = "Loading"
                
                
                
                if let data = UserDefaults.standard.data(forKey: "people"),
                   
                    let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
                    
                    userEmail = self.emailText.text ?? ""
                    
                    var postDict = ["name": name, //myPeopleList.name,
                                    
                                    "email": userEmail,
                                    
                                    "user_id": myPeopleList.userID,
                                    
                                    "token": myPeopleList.token,
                                    
                                    "type": myPeopleList.type,
                                    
                                    "phone":mobileText.text ?? "",
                                    
                                    "country":UserDefaults.standard.value(forKey: "selectedcountry") as? String ?? "US",
                                    
                                    "gender":genderText,
                                    
                                    "photo":photoString,
                                    
                                    "business_name":businessName.text ?? "",
                                    
                                    "terms":termCondition == false ? "No" : "Yes"] as [String : Any]
                    postDict = updateData
                    
                    debugPrint("postDict => ",postDict)
                    WebserviceClass.sharedAPI.performRequest(type: UpdateModel.self, urlString: updateProfileUrl, methodType: HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
                        
                        self.UpdateModelResponse = response
                        
                        self.updateArray = self.UpdateModelResponse?.data
                        
                        self.responsemMethod()
                        
                        print("Result: \(String(describing: response))") // response serialization result
                        
                        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                        
                        
                        
                    }) { (response) in
                        
                        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                        
                    }
                    
                }
            }}
    }
    
    /**
     Converts the given UIImage to a base64-encoded string.
     
     - Parameter image: The UIImage to be converted.
     
     - Returns: A base64-encoded string representing the provided image.
     
     - Important: The returned base64 string can be used to transmit the image data over networks or store it in databases.
     */
    func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    /**
     Method to handle the response received after attempting to update the user's profile.
     
     This method checks the status of the response received from the server. If the status is 1 (indicating success), it updates the local user's profile details with the newly received data and navigates the user to the appropriate screen based on the login type. If the status is not 1, indicating a failure, it displays an alert with the error message.
     
     - Note: This method is typically called after sending a request to update the user's profile details.
     
     - Important: The success scenario includes updating the local user's profile details and navigating to the appropriate screen based on the login type. The failure scenario involves displaying an alert with the error message received from the server.
     
     - SeeAlso: `updateAction(_:)` for initiating the profile update request.
     **/
    func responsemMethod()  {
        if(self.UpdateModelResponse?.status == 1) {
            
            let newPerson = UserDetails(name: self.updateArray!.name ?? "", email: self.updateArray!.email!, mobileNUmber: self.updateArray?.phone_number ?? "", gender: self.updateArray?.gender ?? "", profileUrl:(self.updateArray?.photo)!, country: self.updateArray?.country ?? "",token: self.updateArray!.token!,userID:self.updateArray?.user_id ?? "", type: self.updateArray?.type ?? "", businessName: self.updateArray?.business_name ?? "",terms: self.updateArray?.terms ?? "No")
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: newPerson)
            UserDefaults.standard.set(encodedData, forKey: "people")
            UserDefaults.standard.synchronize()
            
            if self.loginType == "Social" {
                if comingFromTypes == false{
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
                else {
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdvancedVC") as? AdvancedVC
                    self.navigationController?.popToViewController(vc!, animated: true)
                }
            }
            else{
                
                let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
                let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                let messageAttrString = NSMutableAttributedString(string:(self.UpdateModelResponse?.message)!, attributes: messageFont)
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                }
                alertController.addAction(contact)
                self.present(alertController, animated: true, completion: nil)
                
                
                //                let vc = (UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController)!
                //                self.navigationController?.pushViewController(vc, animated: true)
                //                self.present(vc, animated: true, completion: nil)
            }
            
        }
        else
        {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:(self.UpdateModelResponse?.message)!, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     Action method triggered when the user taps the skip button.
     
     - Parameter sender: The UIButton that triggered the action.
     */
    @IBAction func skipAction(_ sender: UIButton) {
        self.updateAction(sender)
    }
    
    /**
     Action method triggered when the user taps the back button.
     
     - Parameter _sender: The UIButton that triggered the action.
     */
    @objc func backAction(_sender:UIButton)  {
        self.view.endEditing(true)
        if self.loginType == "Social" {
            self.navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    /**
     Adjusts the scroll view's content inset when the keyboard appears.
     
     - Parameter notification: The notification containing keyboard information.
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 100
        scrollView.contentInset = contentInset
    }
    
    /**
     Resets the scroll view's content inset when the keyboard hides.
     
     - Parameter notification: The notification containing keyboard information.
     */
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    /**
     Notifies the delegate that editing began in the specified text field.
     
     - Parameter textField: The text field in which an editing session began.
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
    }
    
    /**
     Asks the delegate if editing should begin in the specified text field.
     
     - Parameter textField: The text field whose return button was pressed.
     
     - Returns: true if editing should begin; otherwise, false.
     */
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    /**
     Asks the delegate if the text field should process the pressing of the return button.
     
     - Parameter textField: The text field whose return button was pressed.
     
     - Returns: true if the text field should implement its default behavior for the return button; otherwise, false.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     Notifies the delegate that the user picked an image.
     
     - Parameters:
     - picker: The image picker controller that picked the image.
     - info: A dictionary containing the original image.
     
     - Important: This method dismisses the image picker controller and sets the selected image to the profile image view.
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        profileImage.image = selectedImage
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    /**
     Presents the Terms and Conditions view controller when the terms button is tapped.
     
     - Parameter sender: The UIButton that triggered the action.
     */
    @IBAction func showTermsAndCondition(_ sender:UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as? TermsAndConditionsViewController
        vc?.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    /**
     Action method triggered when the user taps the agree button to accept terms and conditions.
     
     - Parameter sender: The UIButton that triggered the action.
     */
    @IBAction func agreeaction(_ sender: UIButton){
        if(sender.isSelected == true){
            sender.isSelected = false
            termCondition = false
        } else {
            sender.isSelected = true
            termCondition = true
        }
    }
    
    
    
}
