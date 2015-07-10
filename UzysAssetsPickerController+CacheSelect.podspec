Pod::Spec.new do |s|

  s.name         = "UzysAssetsPickerController+CacheSelect"
  s.version      = "1.0.0"
  s.summary      = "Alternative UIImagePickerController , You can take a picture with camera and pick multiple photos and videos."
  s.author       = { "UzysJung" => "uzysjung@gmail.com" }

  s.homepage     = "https://github.com/lexiaoyao20/UzysAssetsPickerController"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.platform     = :ios , '7.0'
  s.source       = { :git => "https://github.com/lexiaoyao20/UzysAssetsPickerController.git", :tag => "1.0.0" }
  s.requires_arc = true
  s.source_files = "UzysAssetsPickerController/Library"
  s.resources = ["UzysAssetsPickerController/Library/*.{xib}","UzysAssetsPickerController/Library/UzysAssetPickerController.bundle"]
  s.public_header_files = "UzysAssetsPickerController/Library/*.{h}"
  s.ios.frameworks = "QuartzCore" , "MobileCoreServices" , "AVFoundation" , "AssetsLibrary" , "CoreGraphics"

end
