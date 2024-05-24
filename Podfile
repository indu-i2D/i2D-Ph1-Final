# Uncomment the next line to define a global platform for your project




target 'i2-Donate' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
    pod 'TKFormTextField'
      pod 'SideMenu'
    pod 'MBProgressHUD'
   # pod 'GoogleSignIn'
    pod 'GoogleSignIn', '~> 5.0.2'
#    pod 'FBSDKCoreKit'
#    pod 'FBSDKShareKit'
    pod 'Alamofire', '~> 5.0'
    pod 'AlamofireImage', '~> 4.1'
    pod 'AlamofireNetworkActivityIndicator', '~> 3.1'
#    pod 'Braintree/PayPal'
    pod 'GoogleMaps/Maps'
    pod 'GooglePlaces'

#    pod 'BraintreeDropIn'
#    pod "BraintreeDropIn/UIKit"
    pod 'SwiftyJSON'
    pod 'TwitterKit5'
    pod 'TwitterCore'
    pod 'IQKeyboardManagerSwift'
    pod 'KeychainSwift', '~> 20.0'
    post_install do |installer|
          installer.pods_project.build_configurations.each do |config|
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
          end
    end
#    pod 'PayPal-iOS-SDK'

end


