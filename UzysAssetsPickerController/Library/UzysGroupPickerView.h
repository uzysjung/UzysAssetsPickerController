//
//  UzysGroupPickerView.h
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 13..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysAssetsPickerController_Configuration.h"
@interface UzysGroupPickerView : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (strong) NSMutableArray *groups;
@property (nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic,copy) intBlock blockTouchCell;
@property (nonatomic,assign) BOOL isOpen;
- (id)initWithGroups:(NSMutableArray *)groups;

- (void)show;
- (void)dismiss:(BOOL)animated;
- (void)toggle;
- (void)reloadData;
@end
