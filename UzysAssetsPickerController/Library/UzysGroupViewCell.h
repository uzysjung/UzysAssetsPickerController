//
//  UzysGroupViewCell.h
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 13..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysAssetsPickerController_Configuration.h"
@interface UzysGroupViewCell : UITableViewCell
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
- (void)applyData:(ALAssetsGroup *)assetsGroup;
@end
