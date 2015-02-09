//
//  UzysAssetsPickerController_configuration.h
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
typedef void (^intBlock)(NSInteger);
typedef void (^voidBlock)(void);

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // iPhone and       iPod touch style UI
#define IS_IOS8 ([[UIDevice currentDevice].systemVersion floatValue]>=8)
#define IS_IPHONE_6_IOS8 (IS_IPHONE && IS_IOS8 &&([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 667.0f)
#define IS_IPHONE_6P_IOS8 (IS_IPHONE && IS_IOS8 &&([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 736.0f)


#define kGroupViewCellIdentifier           @"groupViewCellIdentifier"
#define kAssetsViewCellIdentifier           @"AssetsViewCellIdentifier"
#define kAssetsSupplementaryViewIdentifier  @"AssetsSupplementaryViewIdentifier"
#define kThumbnailLength    79.0f
#define kThumbnailLength_IPHONE6    78.0f + 15.0f
#define kThumbnailLength_IPHONE6P    78.0f + 24.5f

#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)
#define kThumbnailSize_IPHONE6 CGSizeMake(kThumbnailLength_IPHONE6,kThumbnailLength_IPHONE6)
#define kThumbnailSize_IPHONE6P CGSizeMake(kThumbnailLength_IPHONE6P ,kThumbnailLength_IPHONE6P)

#define THUMBNAIL_SIZE  if(IS_IPHONE) kThumbnailSize 

#define kTagButtonClose 101
#define kTagButtonCamera 102
#define kTagButtonGroupPicker 103
#define kTagButtonDone 104
#define kTagNoAssetViewImageView 30
#define kTagNoAssetViewTitleLabel 31
#define kTagNoAssetViewMsgLabel 32

#define kGroupPickerViewCellLength 90



#ifdef DEBUG
// for debug mode
#ifndef DLog
#define DLog(f, ...) NSLog(f, ##__VA_ARGS__)
#endif

#else

// for release mode
#ifndef DLog
#define DLog(f, ...) /* noop */
#endif

#endif
