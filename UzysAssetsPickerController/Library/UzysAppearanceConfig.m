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

- (UIColor *)finishSelectionButtonColor
{
    if (!_finishSelectionButtonColor) {
        return [UIColor redColor];
    }
    return _finishSelectionButtonColor;
}

@end
