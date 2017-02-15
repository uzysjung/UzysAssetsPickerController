//
//  UIImage+UzysExtension.m
//  UzysAssetsPickerController
//
//  Created by jianpx on 8/26/14.
//  Copyright (c) 2014 Uzys. All rights reserved.
//

#import "UIImage+UzysExtension.h"
#import "UzysAssetsPickerController.h"

@implementation UIImage (UzysExtension)

+ (UIImage *)Uzys_imageNamed:(NSString *)imageName
{
    return [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[UzysAssetsPickerController class]] compatibleWithTraitCollection:nil];
}
@end
