//
//  uzysGroupViewCell.m
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 13..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//
#import "UzysAssetsPickerController_Configuration.h"
#import "UzysGroupViewCell.h"
@implementation UzysGroupViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:17];
        self.detailTextLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:11];
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_checkMark"]];
        self.selectedBackgroundView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if(selected)
    {
        self.accessoryView.hidden = NO;
    }
    else
    {
        self.accessoryView.hidden = YES;
    }

}


- (void)applyData:(ALAssetsGroup *)assetsGroup
{
    self.assetsGroup            = assetsGroup;
    
    CGImageRef posterImage      = assetsGroup.posterImage;
    size_t height               = CGImageGetHeight(posterImage);
    float scale                 = height / kThumbnailLength;
    
    self.imageView.image        = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    self.textLabel.text         = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.detailTextLabel.text   = [NSString stringWithFormat:@"%ld", (long)[assetsGroup numberOfAssets]];
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
}
@end
