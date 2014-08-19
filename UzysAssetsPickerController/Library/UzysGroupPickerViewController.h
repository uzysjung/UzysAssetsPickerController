//
//  UzysGroupPickerViewController.h
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 13..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UzysGroupPickerViewController : UIViewController
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;
- (id)initWithGroups:(NSMutableArray *)groups;

- (void)show;
- (void)dismiss:(BOOL)animated;
- (void)toggle;
- (void)reloadData;

@end
