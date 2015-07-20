UzysAssetsPickerController
==========================
[![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://raw.githubusercontent.com/uzysjung/UzysAssetsPickerController/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/UzysAssetsPickerController.svg?style=flat)](https://github.com/uzysjung/UzysAssetsPickerController)
[![License MIT](https://img.shields.io/badge/contact-@Uzysjung-blue.svg?style=flat)](http://uzys.net)


Alternative UIImagePickerController , You can take a picture with camera and choose multiple photos and videos

![Screenshot](https://raw.githubusercontent.com/uzysjung/UzysAssetsPickerController/master/UzysAssetsPickerController.gif)

![Screenshot](https://raw.githubusercontent.com/uzysjung/UzysAssetsPickerController/master/UzysAssetsPickerController1.png)![Screenshot](https://raw.githubusercontent.com/uzysjung/UzysAssetsPickerController/master/UzysAssetsPickerController2.png)
**UzysAssetsPickerController features:**

* Easy customization using Inferface Builder. (XIB - 'UzysAssetsPickerController.xib')
* With Assetpicker, taking pictures and or making videos are also possible.
* UzysAssetPickerController automatically update photos that has been taken & saved with other apps  
* ARC Only (if your project doesn't use ARC , Project -> Build Phases Tab -> Compile Sources Section -> Double Click on the file name Then add -fno-objc-arc to the popup window.)

## Installation
1. Just add `pod 'UzysAssetsPickerController'` to your Podfile.
2. Copy over the files libary folder to your project folder

## Usage
###Import header.

``` objective-c
#import "UzysAssetsPickerController.h"
```

### Customize Appearance of UzysAssetsPickerController
if you want to customize the appearance of UzysAssetsPickerController, you can init UzysAppearanceConfig instance, and config its property,
then call

``` objective-c
    + (void)setUpAppearanceConfig:(UzysAppearanceConfig *)config
```  
of UzysAssetsPickerController before you init UzysAssetsPickerController

sample code is like this:

``` objective-c
    UzysAppearanceConfig *appearanceConfig = [[UzysAppearanceConfig alloc] init];
    appearanceConfig.finishSelectionButtonColor = [UIColor blueColor];
    appearanceConfig.assetsGroupSelectedImageName = @"checker";
    [UzysAssetsPickerController setUpAppearanceConfig:appearanceConfig];
```

for more configable properties, please refer to `UzysAppearanceConfig.h`

### open UzysAssetsPickerController
``` objective-c
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionMedia = 2;
    [self presentViewController:picker animated:YES completion:^{

    }];
```
### UzysAssetPickerControllerDelegate
``` objective-c
- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    __weak typeof(self) weakSelf = self;
    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
            [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ALAsset *representation = obj;

                    UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullResolutionImage
                                                       scale:representation.defaultRepresentation.scale
                                                 orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
                weakSelf.imageView.image = img;
                *stop = YES;
            }];


    }
    else //Video
    {
        ALAsset *alAsset = assets[0];

        UIImage *img = [UIImage imageWithCGImage:alAsset.defaultRepresentation.fullResolutionImage
                                           scale:alAsset.defaultRepresentation.scale
                                     orientation:(UIImageOrientation)alAsset.defaultRepresentation.orientation];
        weakSelf.imageView.image = img;



        ALAssetRepresentation *representation = alAsset.defaultRepresentation;
        NSURL *movieURL = representation.url;
        NSURL *uploadURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"test"] stringByAppendingString:@".mp4"]];
        AVAsset *asset      = [AVURLAsset URLAssetWithURL:movieURL options:nil];
        AVAssetExportSession *session =
        [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetMediumQuality];

        session.outputFileType  = AVFileTypeQuickTimeMovie;
        session.outputURL       = uploadURL;

        [session exportAsynchronouslyWithCompletionHandler:^{

            if (session.status == AVAssetExportSessionStatusCompleted)
            {
                NSLog(@"output Video URL %@",uploadURL);
            }

        }];

    }
}
```

### filter option
#### images only
``` objective-c
  UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
  picker.delegate = self;
  picker.maximumNumberOfSelectionVideo = 0;
  picker.maximumNumberOfSelectionPhoto = 3;

```

#### videos only
``` objective-c
  UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
  picker.delegate = self;
  picker.maximumNumberOfSelectionVideo = 3;
  picker.maximumNumberOfSelectionPhoto = 0;
```
#### images or videos
``` objective-c
  UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
  picker.delegate = self;
  picker.maximumNumberOfSelectionVideo = 4;
  picker.maximumNumberOfSelectionPhoto = 3;
```

#### both images and videos
``` objective-c
  UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
  picker.delegate = self;
  picker.maximumNumberOfSelectionMedia = 5;
```

### Customization
- You can easily modify UzysAssetsPickerController Design using InterfaceBuilder
- check out 'UzysAssetsPickerController.xib'

## ChangeLog
- V0.9.6 - changing Delegate Method name because of supporting Swift. [#28](https://github.com/uzysjung/UzysAssetsPickerController/pull/28)
- V0.9.7 - fixed self retain bug
- V0.9.8 - implement selection order; settings to change cellspacing columns number; support cocoapod on SWIFT 

## Contact
 - [Uzys.net](http://uzys.net)
 - This Library was designed by [minjee Hahm](http://www.linkedin.com/pub/minjee-hahm/63/73/5a)

## License
 - See [LICENSE](https://github.com/uzysjung/UzysAssetsPickerController/blob/master/LICENSE).
