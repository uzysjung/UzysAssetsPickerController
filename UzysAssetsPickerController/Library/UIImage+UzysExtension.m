//
//  UIImage+UzysExtension.m
//  UzysAssetsPickerController
//
//  Created by jianpx on 8/26/14.
//  Copyright (c) 2014 Uzys. All rights reserved.
//

#import "UIImage+UzysExtension.h"

@implementation UIImage (UzysExtension)

+ (UIImage *)Uzys_imageNamed:(NSString *)imageName
{
    UIImage *image = [[self class] imageNamed:imageName];
    if (image) {
        return image;
    }
    NSString *imagePathInControllerBundle = [NSString stringWithFormat:@"UzysAssetPickerController.bundle/%@", imageName];
    image = [[self class] imageNamed:imagePathInControllerBundle];
    return image;
}
@end
