# Uncomment the next line to define a global platform for your project

platform :ios, '14.0'
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
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
    pod 'GooglePlaces'
    pod 'GoogleMaps/Maps'

#    pod 'BraintreeDropIn'
#    pod "BraintreeDropIn/UIKit"
    pod 'SwiftyJSON'
    pod 'TwitterKit5'
    pod 'TwitterCore'
    pod 'IQKeyboardManagerSwift'
    pod 'KeychainSwift', '~> 20.0'
    
#    pod 'PayPal-iOS-SDK'

end


