//
//  UzysAppearanceConfig.h
//  UzysAssetsPickerController
//
//  Created by jianpx on 8/26/14.
//  Copyright (c) 2014 Uzys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+UzysExtension.h"
@interface UzysAppearanceConfig : NSObject
//selected photo/video checkmark
@property (nonatomic, strong) NSString *assetSelectedImageName;
//deselected photo/video checkmark
@property (nonatomic, strong) NSString *assetDeselectedImageName;
@property (nonatomic, strong) NSString *assetsGroupSelectedImageName;
@property (nonatomic, strong) NSString *cameraImageName;
@property (nonatomic, strong) NSString *closeImageName;
@property (nonatomic, strong) UIColor *finishSelectionButtonColor;
//
@property (nonatomic, assign) NSInteger assetsCountInALine;
@property (nonatomic, assign) CGFloat cellSpacing;

+ (instancetype)sharedConfig;
@end
