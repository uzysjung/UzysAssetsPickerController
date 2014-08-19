//
//  UzysGroupPickerViewController.m
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 13..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//
#import "UzysGroupViewCell.h"
#import "UzysGroupPickerViewController.h"
#import "UzysAssetsPickerController_Configuration.h"
@interface UzysGroupPickerViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIView *containerView;
@end

@implementation UzysGroupPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithGroups:(NSMutableArray *)groups
{
    self = [super init];
    if(self) {
        self.groups = groups;
    }
    return self;
        
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupLayout];
    [self setupTableView];
    [self setupGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupLayout
{
    self.view.frame = [UIScreen mainScreen].bounds;
    //anchorPoint 를 잡는데 화살표 지점으로 잡아야함
    self.containerView = [[UIView alloc] init];
    self.containerView.layer.anchorPoint = CGPointMake(0.5, 0);
    self.containerView.frame = CGRectMake(1, 55, 318, 250);
    self.containerView.layer.cornerRadius = 4;
    self.containerView.alpha = 0;
    self.containerView.clipsToBounds = YES;
    [self.view addSubview:self.containerView];
    
    self.view.alpha = 0;
}
- (void)setupFrame
{
    CGFloat height = [self.groups count] * kGroupPickerViewCellLength;
    
    if(height > kGroupPickerViewCellLength * 5)
    {
        height = kGroupPickerViewCellLength *5;
    }
    self.containerView.layer.anchorPoint = CGPointMake(0.5, 0);
    self.containerView.frame = CGRectMake(1, 55, 318, height);
    
}
- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.containerView.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = kGroupPickerViewCellLength;
    self.tableView.contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
    [self.containerView addSubview:self.tableView];
    //    [self.tableView reloadData];
}
- (void)setupGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tap.cancelsTouchesInView = NO; // Allow touches through to a UITableView or other touchable view, as suggested by Dimajp.
    [self.view addGestureRecognizer:tap];
    self.tapGestureRecognizer = tap;
}
- (void)reloadData
{
    [self setupFrame];
    [self.tableView reloadData];
}
- (void)show
{
    [UIView animateWithDuration:0.05f delay:0.f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.view.alpha = 1;
        self.containerView.alpha = 0.3f;
        self.containerView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.containerView.alpha = 1.0f;
            self.containerView.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15f delay:0.f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.containerView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
//                NSLog(@"groups %@ frame %@ tableView frame %@ alpha %f",self.groups,NSStringFromCGRect(self.containerView.frame),NSStringFromCGRect(self.tableView.frame),self.containerView.alpha);
            }];
        }];
        
    }];
    
}
- (void)dismiss:(BOOL)animated
{
    if (!animated)
    {
        self.containerView.alpha = 0.0f;
        self.view.alpha = 0;
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.containerView.alpha = 0.1f;
            self.containerView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        } completion:^(BOOL finished) {
            self.containerView.alpha = 0.3f;
            self.view.alpha = 0;
        }];
    }
    
}
- (void)toggle
{
    if(self.containerView.alpha <0.5)
    {
        [self show];
    }
    else
    {
        [self dismiss:YES];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"kGroupViewCellIdentifier";
    
    UzysGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UzysGroupViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell applyData:[self.groups objectAtIndex:indexPath.row]];
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGroupPickerViewCellLength;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITapGestureRecognizer
- (void)tapped:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self.view];

    if (!CGRectContainsPoint(self.containerView.frame, point))
    {
        [self dismiss:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"groups"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupFrame];
        });
    }
}


@end
