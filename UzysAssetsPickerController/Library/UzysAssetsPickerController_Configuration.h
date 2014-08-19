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

#define kGroupViewCellIdentifier           @"groupViewCellIdentifier"
#define kAssetsViewCellIdentifier           @"AssetsViewCellIdentifier"
#define kAssetsSupplementaryViewIdentifier  @"AssetsSupplementaryViewIdentifier"
#define kThumbnailLength    78.0f
#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)

#define kTagButtonClose 101
#define kTagButtonCamera 102
#define kTagButtonGroupPicker 103
#define kTagButtonDone 104
#define kTagNoAssetViewImageView 30
#define kTagNoAssetViewTitleLabel 31
#define kTagNoAssetViewMsgLabel 32

#define kGroupPickerViewCellLength 90
