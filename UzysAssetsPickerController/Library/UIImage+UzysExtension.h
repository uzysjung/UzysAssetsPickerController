//
//  UIImage+UzysExtension.h
//  UzysAssetsPickerController
//
//  Created by jianpx on 8/26/14.
//  Copyright (c) 2014 Uzys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UzysExtension)

/**
 *  First search main bundle, if find the image return it, otherwise search the UzysAssertPickerController.bundle to get the image.
 *
 *  @param imageName name of the image.
 *
 *  @return UIImage instance or nil
 */
+ (UIImage *)Uzys_imageNamed:(NSString *)imageName;
@end
