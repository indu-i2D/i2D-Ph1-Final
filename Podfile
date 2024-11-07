platform :ios, '14.0'

target 'i2-Donate' do
  use_frameworks!

  pod 'TKFormTextField'
  pod 'SideMenu'
  pod 'MBProgressHUD'
  pod 'GoogleSignIn', '~> 5.0.2'
  pod 'Alamofire', '~> 5.0'
  pod 'AlamofireImage', '~> 4.1'
  pod 'AlamofireNetworkActivityIndicator', '~> 3.1'
  pod 'GoogleMaps/Maps'
  pod 'GooglePlaces'
  pod 'SwiftyJSON'
  pod 'IQKeyboardManagerSwift'
  pod 'KeychainSwift', '~> 20.0'

  # Uncomment the following pods as needed
  # pod 'FBSDKCoreKit'
  # pod 'FBSDKShareKit'
  # pod 'Braintree/PayPal'
  # pod 'BraintreeDropIn'
  # pod 'BraintreeDropIn/UIKit'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      end
    end
  end
end
