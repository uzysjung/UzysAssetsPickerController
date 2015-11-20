//
//  UzysStringsConfig.m
//  UzysAssetsPickerController
//
//  Created by Alberto Gragera Cerrajero on 20/11/15.
//  Copyright © 2015 Uzys. All rights reserved.
//

#import "UzysStringsConfig.h"

@implementation UzysStringsConfig

- (NSString *)notAllowedTitle
{
    if (!_notAllowedTitle) {
        _notAllowedTitle = NSLocalizedStringFromTable(@"Not Allowed", @"UzysAssetsPickerController",nil);
    }
    return _notAllowedTitle;
}

- (NSString *)noMediaItemsTitle
{
    if (!_noMediaItemsTitle) {
        _noMediaItemsTitle = NSLocalizedStringFromTable(@"No Photos", @"UzysAssetsPickerController",nil);
    }
    return _noMediaItemsTitle;
}

- (NSString *)noMediaItemsMessage
{
    if (!_noMediaItemsMessage) {
        _noMediaItemsMessage = NSLocalizedStringFromTable(@"You can sync photos and videos onto your iPhone using iTunes.", @"UzysAssetsPickerController",nil);
    }
    
    return _noMediaItemsMessage;
}

- (NSString *)noMediaAccessErrorTitle
{
    if (!_noMediaAccessErrorTitle) {
        _noMediaAccessErrorTitle = NSLocalizedStringFromTable(@"This app does not have access to your photos or videos.", @"UzysAssetsPickerController",nil);

    }
    
    return _noMediaAccessErrorTitle;
}

- (NSString *)noMediaAccessErrorMessage
{
    if (!_noMediaAccessErrorMessage) {
        _noMediaAccessErrorMessage = NSLocalizedStringFromTable(@"This app does not have access to your photos or videos.", @"UzysAssetsPickerController",nil);
        
    }
    
    return _noMediaAccessErrorMessage;
}

- (NSString *)noCameraPresentErrorTitle
{
    if (!_noCameraPresentErrorTitle) {
        _noCameraPresentErrorTitle = NSLocalizedStringFromTable(@"Error", @"UzysAssetsPickerController", nil);
        
    }
    
    return _noCameraPresentErrorTitle;
}

- (NSString *)noCameraPresentErrorMessage
{
    if (!_noCameraPresentErrorMessage) {
        _noCameraPresentErrorMessage = NSLocalizedStringFromTable(@"Device has no camera", @"UzysAssetsPickerController", nil);
        
    }
    
    return _noCameraPresentErrorMessage;
}

@end
