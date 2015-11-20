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

@property (nonatomic, strong) UIColor *finishSelectionButtonColor;
@property (nonatomic, assign) NSInteger assetsCountInALine;
@property (nonatomic, assign) CGFloat cellSpacing;

+ (instancetype)sharedConfig;
@end
