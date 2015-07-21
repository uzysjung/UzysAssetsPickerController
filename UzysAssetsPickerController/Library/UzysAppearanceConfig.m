//
//  UzysAppearanceConfig.m
//  UzysAssetsPickerController
//
//  Created by jianpx on 8/26/14.
//  Copyright (c) 2014 Uzys. All rights reserved.
//

#import "UzysAppearanceConfig.h"

@implementation UzysAppearanceConfig

+ (instancetype)sharedConfig
{
    static UzysAppearanceConfig *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.assetsCountInALine = 4;
        self.cellSpacing = 1.0f;
    }

    return self;
}

- (NSString *)assetSelectedImageName
{
    if (!_assetSelectedImageName) {
        return @"uzysAP_ico_photo_thumb_check";
    }
    return _assetSelectedImageName;
}

- (NSString *)assetDeselectedImageName
{
    if (!_assetDeselectedImageName) {
        return @"uzysAP_ico_photo_thumb_uncheck";
    }
    return _assetDeselectedImageName;
}

- (NSString *)assetsGroupSelectedImageName
{
    if (!_assetsGroupSelectedImageName) {
        return @"uzysAP_ico_checkMark";
    }
    return _assetsGroupSelectedImageName;
}

- (NSString *)cameraImageName
{
    if (!_cameraImageName) {
        return @"uzysAP_ico_upload_camera";
    }
    return _cameraImageName;
}

- (NSString *)closeImageName
{
    if (!_closeImageName) {
        return @"uzysAP_navi_icon_close";
    }
    return _closeImageName;
}

- (UIColor *)finishSelectionButtonColor
{
    if (!_finishSelectionButtonColor) {
        return [UIColor redColor];
    }
    return _finishSelectionButtonColor;
}

@end
