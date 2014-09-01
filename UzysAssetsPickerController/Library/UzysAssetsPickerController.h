//
//  UzysAssetsPickerController.h
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysAssetsPickerController_Configuration.h"
#import "UzysAppearanceConfig.h"

@class UzysAssetsPickerController;
@protocol UzysAssetsPickerControllerDelegate<NSObject>
- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets;
@optional
- (void)UzysAssetsPickerControllerDidCancel:(UzysAssetsPickerController *)picker;
- (void)UzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:(UzysAssetsPickerController *)picker;
- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker wantsCropViewForImage:(UIImage *)image;
@end

@interface UzysAssetsPickerController : UIViewController
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionVideo;
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionPhoto;
//--------------------------------------------------------------------
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionMedia;

@property (nonatomic, weak) id <UzysAssetsPickerControllerDelegate> delegate;
+ (ALAssetsLibrary *)defaultAssetsLibrary;
/**
 *  setup the appearance, including the all the properties in UzysAppearanceConfig, check UzysAppearanceConfig.h out for details.
 *
 *  @param config UzysAppearanceConfig instance.
 */
+ (void)setUpAppearanceConfig:(UzysAppearanceConfig *)config;

@end
