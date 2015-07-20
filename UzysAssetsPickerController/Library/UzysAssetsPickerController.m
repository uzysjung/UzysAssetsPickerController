//
//  UzysAssetsPickerController.m
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//
#import "UzysAssetsPickerController.h"
#import "UzysAssetsViewCell.h"
#import "UzysWrapperPickerController.h"
#import "UzysGroupPickerView.h"
#import <ImageIO/ImageIO.h>

@interface UzysAssetsPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
//View
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTitleArrow;
@property (weak, nonatomic) IBOutlet UIButton *btnTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIView *navigationTop;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *labelSelectedMedia;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@property (nonatomic, strong) UIView *noAssetView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UzysWrapperPickerController *picker;
@property (nonatomic, strong) UzysGroupPickerView *groupPicker;
//@property (nonatomic, strong) UzysGroupPickerViewController *groupPicker;

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;
@property (nonatomic, assign) NSInteger maximumNumberOfSelection;
@property (nonatomic, assign) NSInteger curAssetFilterType;

@property (nonatomic, strong) NSMutableArray *orderedSelectedItem;

- (IBAction)btnAction:(id)sender;
- (IBAction)indexDidChangeForSegmentedControl:(id)sender;

@end

@implementation UzysAssetsPickerController

@synthesize location;

#pragma mark - ALAssetsLibrary

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^
                  {
                      library = [[ALAssetsLibrary alloc] init];
                  });
    return library;
}


- (id)init
{
    self = [super initWithNibName:@"UzysAssetsPickerController" bundle:[NSBundle bundleForClass:[UzysAssetsPickerController class]]];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryUpdated:) name:ALAssetsLibraryChangedNotification object:nil];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
    self.assetsLibrary = nil;
    self.assetsGroup = nil;
    self.assets = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initVariable];
    [self initImagePicker];
    [self setupOneMediaTypeSelection];
    
    __weak typeof(self) weakSelf = self;
    [self setupGroup:^{
        [weakSelf.groupPicker.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    } withSetupAsset:YES];
    [self setupLayout];
    [self setupCollectionView];
    [self setupGroupPickerview];
    [self initNoAssetView];
    
}

- (void)initVariable
{
    //    self.assetsFilter = [ALAssetsFilter allPhotos];
    [self setAssetsFilter:[ALAssetsFilter allPhotos] type:1];
    self.maximumNumberOfSelection = self.maximumNumberOfSelectionPhoto;
    self.view.clipsToBounds = YES;
    self.orderedSelectedItem = [[NSMutableArray alloc] init];
}
- (void)initImagePicker
{
    UzysWrapperPickerController *picker = [[UzysWrapperPickerController alloc] init];
    //    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSArray *availableMediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeCamera];
        NSMutableArray *mediaTypes = [NSMutableArray arrayWithArray:availableMediaTypes];
        
        if (_maximumNumberOfSelectionMedia == 0)
        {
            if (_maximumNumberOfSelectionPhoto == 0)
                [mediaTypes removeObject:@"public.image"];
            else if (_maximumNumberOfSelectionVideo == 0)
                [mediaTypes removeObject:@"public.movie"];
        }
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = mediaTypes;
    }
    self.picker = picker;
}
- (void)setupLayout
{
    UzysAppearanceConfig *appearanceConfig = [UzysAppearanceConfig sharedConfig];
    [self.btnCamera setImage:[UIImage Uzys_imageNamed:appearanceConfig.cameraImageName] forState:UIControlStateNormal];
    [self.btnClose setImage:[UIImage Uzys_imageNamed:appearanceConfig.closeImageName] forState:UIControlStateNormal];
    self.btnDone.layer.cornerRadius = 15;
    self.btnDone.clipsToBounds = YES;
    [self.btnDone setBackgroundColor:appearanceConfig.finishSelectionButtonColor];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
    lineView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15f];
    [self.bottomView addSubview:lineView];
}
- (void)setupGroupPickerview
{
    __weak typeof(self) weakSelf = self;
    self.groupPicker = [[UzysGroupPickerView alloc] initWithGroups:self.groups];
    self.groupPicker.blockTouchCell = ^(NSInteger row){
        [weakSelf changeGroup:row];
    };
    
    [self.view insertSubview:self.groupPicker aboveSubview:self.bottomView];
    [self.view bringSubviewToFront:self.navigationTop];
    [self menuArrowRotate];
    
}
- (void)setupOneMediaTypeSelection
{
    if(_maximumNumberOfSelectionMedia > 0)
    {
        //        self.assetsFilter = [ALAssetsFilter allAssets];
        [self setAssetsFilter:[ALAssetsFilter allAssets] type:0];
        self.maximumNumberOfSelection = self.maximumNumberOfSelectionMedia;
        self.segmentedControl.hidden = YES;
        self.labelSelectedMedia.hidden = NO;
        if(_maximumNumberOfSelection > 1)
            self.labelSelectedMedia.text = NSLocalizedStringFromTable(@"Choose media", @"UzysAssetsPickerController", nil);
        else
            self.labelSelectedMedia.text = NSLocalizedStringFromTable(@"Choose a media", @"UzysAssetsPickerController", nil);
        
    }
    else
    {
        if(_maximumNumberOfSelectionPhoto == 0)
        {
            //            self.assetsFilter = [ALAssetsFilter allVideos];
            [self setAssetsFilter:[ALAssetsFilter allVideos] type:2];
            
            self.maximumNumberOfSelection = self.maximumNumberOfSelectionVideo;
            self.segmentedControl.hidden = YES;
            self.labelSelectedMedia.hidden = NO;
            if(_maximumNumberOfSelection > 1)
                self.labelSelectedMedia.text = NSLocalizedStringFromTable(@"Choose videos", @"UzysAssetsPickerController", nil);
            else
                self.labelSelectedMedia.text = NSLocalizedStringFromTable(@"Choose a video", @"UzysAssetsPickerController", nil);
        }
        else if(_maximumNumberOfSelectionVideo == 0)
        {
            //            self.assetsFilter = [ALAssetsFilter allPhotos];
            [self setAssetsFilter:[ALAssetsFilter allPhotos] type:1];
            
            self.segmentedControl.selectedSegmentIndex = 0;
            self.maximumNumberOfSelection = self.maximumNumberOfSelectionPhoto;
            self.segmentedControl.hidden = YES;
            self.labelSelectedMedia.hidden = NO;
            if(_maximumNumberOfSelection >1)
                self.labelSelectedMedia.text = NSLocalizedStringFromTable(@"Choose photos", @"UzysAssetsPickerController", nil);
            else
                self.labelSelectedMedia.text = NSLocalizedStringFromTable(@"Choose a photo", @"UzysAssetsPickerController", nil);
        }
        else
        {
            self.segmentedControl.hidden = NO;
            self.labelSelectedMedia.hidden = YES;
        }
        
    }
}

- (void)setupCollectionView
{
    
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    
    UzysAppearanceConfig *appearanceConfig = [UzysAppearanceConfig sharedConfig];
    
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - appearanceConfig.cellSpacing * ((CGFloat)appearanceConfig.assetsCountInALine - 1.0f)) / (CGFloat)appearanceConfig.assetsCountInALine;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.sectionInset                 = UIEdgeInsetsMake(1.0, 0, 0, 0);
    layout.minimumInteritemSpacing      = 1.0;
    layout.minimumLineSpacing           = appearanceConfig.cellSpacing;
  
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 -48) collectionViewLayout:layout];
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[UzysAssetsViewCell class]
            forCellWithReuseIdentifier:kAssetsViewCellIdentifier];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.scrollsToTop = YES;

    [self.view insertSubview:self.collectionView atIndex:0];
}
#pragma mark - Property
- (void)setAssetsFilter:(ALAssetsFilter *)assetsFilter type:(NSInteger)type
{
    _assetsFilter = assetsFilter;
    _curAssetFilterType = type;
}
#pragma mark - public methods
+ (void)setUpAppearanceConfig:(UzysAppearanceConfig *)config
{
    UzysAppearanceConfig *appearanceConfig = [UzysAppearanceConfig sharedConfig];
    appearanceConfig.assetSelectedImageName = config.assetSelectedImageName;
    appearanceConfig.assetDeselectedImageName = config.assetDeselectedImageName;
    appearanceConfig.cameraImageName = config.cameraImageName;
    appearanceConfig.finishSelectionButtonColor = config.finishSelectionButtonColor;
    appearanceConfig.assetsGroupSelectedImageName = config.assetsGroupSelectedImageName;
    appearanceConfig.closeImageName = config.closeImageName;
    appearanceConfig.assetsCountInALine = config.assetsCountInALine;
    appearanceConfig.cellSpacing = config.cellSpacing;
}

- (void)changeGroup:(NSInteger)item
{
    self.assetsGroup = self.groups[item];
    [self setupAssets:nil];
    [self.groupPicker.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:item inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.groupPicker dismiss:YES];
    [self.orderedSelectedItem removeAllObjects];
    [self menuArrowRotate];
}
- (void)changeAssetType:(BOOL)isPhoto endBlock:(voidBlock)endBlock
{
    if(isPhoto)
    {
        self.maximumNumberOfSelection = self.maximumNumberOfSelectionPhoto;
        //        self.assetsFilter = [ALAssetsFilter allPhotos];
        [self setAssetsFilter:[ALAssetsFilter allPhotos] type:1];
        
        [self setupAssets:endBlock];
    }
    else
    {
        self.maximumNumberOfSelection = self.maximumNumberOfSelectionVideo;
        //        self.assetsFilter = [ALAssetsFilter allVideos];
        [self setAssetsFilter:[ALAssetsFilter allVideos] type:2];
        
        [self setupAssets:endBlock];
        
    }
}
- (void)setupGroup:(voidBlock)endblock withSetupAsset:(BOOL)doSetupAsset
{
    if (!self.assetsLibrary)
    {
        self.assetsLibrary = [self.class defaultAssetsLibrary];
    }
    
    if (!self.groups)
        self.groups = [[NSMutableArray alloc] init];
    else
        [self.groups removeAllObjects];
    
    
    __weak typeof(self) weakSelf = self;
    
    ALAssetsFilter *assetsFilter = self.assetsFilter; // number of Asset 메쏘드 호출 시에 적용.
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (group)
        {
            [group setAssetsFilter:assetsFilter];
            NSInteger groupType = [[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
            if(groupType == ALAssetsGroupSavedPhotos)
            {
                [strongSelf.groups insertObject:group atIndex:0];
                if(doSetupAsset)
                {
                    strongSelf.assetsGroup = group;
                    [strongSelf setupAssets:nil];
                }
            }
            else
            {
                if (group.numberOfAssets > 0)
                    [strongSelf.groups addObject:group];
            }
        }
        //traverse to the end, so reload groupPicker.
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.groupPicker reloadData];
                NSUInteger selectedIndex = [weakSelf indexOfAssetGroup:weakSelf.assetsGroup inGroups:weakSelf.groups];
                if (selectedIndex != NSNotFound) {
                    [weakSelf.groupPicker.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                }
                if(endblock)
                    endblock();
            });
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //접근이 허락 안되었을 경우
        [strongSelf showNotAllowed];
        strongSelf.segmentedControl.enabled = NO;
        strongSelf.btnDone.enabled = NO;
        strongSelf.btnCamera.enabled = NO;
        [strongSelf setTitle:NSLocalizedStringFromTable(@"Not Allowed", @"UzysAssetsPickerController",nil)];
        //        [self.btnTitle setTitle:NSLocalizedStringFromTable(@"Not Allowed", @"UzysAssetsPickerController",nil) forState:UIControlStateNormal];
        [strongSelf.btnTitle setImage:nil forState:UIControlStateNormal];
        
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
}

- (void)setupAssets:(voidBlock)successBlock
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        [self.assets removeAllObjects];
    
    if(!self.assetsGroup)
    {
        self.assetsGroup = self.groups[0];
    }
    [self.assetsGroup setAssetsFilter:self.assetsFilter];
    __weak typeof(self) weakSelf = self;
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (asset)
        {
            [strongSelf.assets addObject:asset];
            
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            
            if ([type isEqual:ALAssetTypePhoto])
                strongSelf.numberOfPhotos ++;
            if ([type isEqual:ALAssetTypeVideo])
                strongSelf.numberOfVideos ++;
        }
        
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
                if(successBlock)
                    successBlock();
                
            });
            
        }
    };
    [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:resultsBlock];
}
- (void)reloadData
{
    [self.collectionView reloadData];
    [self.btnDone setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.collectionView.indexPathsForSelectedItems
                            .count] forState:UIControlStateNormal];
    [self showNoAssetsIfNeeded];
}
- (void)setAssetsCountWithSelectedIndexPaths:(NSArray *)indexPaths
{
    [self.btnDone setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)indexPaths.count] forState:UIControlStateNormal];
}

#pragma mark - Asset Exception View
- (void)initNoAssetView
{
    UIView *noAssetsView    = [[UIView alloc] initWithFrame:self.collectionView.bounds];
    
    CGRect rect             = CGRectInset(self.collectionView.bounds, 10, 10);
    UILabel *title          = [[UILabel alloc] initWithFrame:rect];
    UILabel *message        = [[UILabel alloc] initWithFrame:rect];
    
    title.text              = NSLocalizedStringFromTable(@"No Photos or Videos", @"UzysAssetsPickerController", nil);
    title.font              = [UIFont systemFontOfSize:19.0];
    title.textColor         = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    title.tag               = kTagNoAssetViewTitleLabel;
    
    message.text            = NSLocalizedStringFromTable(@"You can sync photos and videos onto your iPhone using iTunes.", @"UzysAssetsPickerController",nil);
    message.font            = [UIFont systemFontOfSize:15.0];
    message.textColor       = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    message.tag             = kTagNoAssetViewMsgLabel;
    
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_no_image"]];
    titleImage.contentMode = UIViewContentModeCenter;
    titleImage.tag = kTagNoAssetViewImageView;
    
    [title sizeToFit];
    [message sizeToFit];
    
    title.center            = CGPointMake(noAssetsView.center.x, noAssetsView.center.y - 10 - title.frame.size.height / 2 + 40);
    message.center          = CGPointMake(noAssetsView.center.x, noAssetsView.center.y + 10 + message.frame.size.height / 2 + 20);
    titleImage.center       = CGPointMake(noAssetsView.center.x, noAssetsView.center.y - 10 - titleImage.frame.size.height /2);
    [noAssetsView addSubview:title];
    [noAssetsView addSubview:message];
    [noAssetsView addSubview:titleImage];
    
    [self.collectionView addSubview:noAssetsView];
    self.noAssetView = noAssetsView;
    self.noAssetView.hidden = YES;
}

- (void)showNotAllowed
{
    self.title              = nil;
    
    UIView *lockedView      = [[UIView alloc] initWithFrame:self.collectionView.bounds];
    UIImageView *locked     = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_no_access"]];
    locked.contentMode      = UIViewContentModeCenter;
    
    CGRect rect             = CGRectInset(self.collectionView.bounds, 8, 8);
    UILabel *title          = [[UILabel alloc] initWithFrame:rect];
    UILabel *message        = [[UILabel alloc] initWithFrame:rect];
    
    title.text              = NSLocalizedStringFromTable(@"This app does not have access to your photos or videos.", @"UzysAssetsPickerController",nil);
    title.font              = [UIFont boldSystemFontOfSize:17.0];
    title.textColor         = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    message.text            = NSLocalizedStringFromTable(@"You can enable access in Privacy Settings.", @"UzysAssetsPickerController",nil);
    message.font            = [UIFont systemFontOfSize:14.0];
    message.textColor       = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    
    [title sizeToFit];
    [message sizeToFit];
    
    locked.center           = CGPointMake(lockedView.center.x, lockedView.center.y - locked.bounds.size.height /2 - 20);
    title.center            = locked.center;
    message.center          = locked.center;
    
    rect                    = title.frame;
    rect.origin.y           = locked.frame.origin.y + locked.frame.size.height + 10;
    title.frame             = rect;
    
    rect                    = message.frame;
    rect.origin.y           = title.frame.origin.y + title.frame.size.height + 5;
    message.frame           = rect;
    
    [lockedView addSubview:locked];
    [lockedView addSubview:title];
    [lockedView addSubview:message];
    [self.collectionView addSubview:lockedView];
}

- (void)showNoAssetsIfNeeded
{
    __weak typeof(self) weakSelf = self;
    
    voidBlock setNoImage = ^{
        UIImageView *imgView = (UIImageView *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewImageView];
        imgView.contentMode = UIViewContentModeCenter;
        imgView.image = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_no_image"];
        
        UILabel *title = (UILabel *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewTitleLabel];
        title.text = NSLocalizedStringFromTable(@"No Photos", @"UzysAssetsPickerController",nil);
        UILabel *msg = (UILabel *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewMsgLabel];
        msg.text = NSLocalizedStringFromTable(@"You can sync photos onto your iPhone using iTunes.",@"UzysAssetsPickerController", nil);
    };
    voidBlock setNoVideo = ^{
        UIImageView *imgView = (UIImageView *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewImageView];
        imgView.image = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_no_video"];
        DLog(@"no video");
        UILabel *title = (UILabel *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewTitleLabel];
        title.text = NSLocalizedStringFromTable(@"No Videos", @"UzysAssetsPickerController",nil);
        UILabel *msg = (UILabel *)[weakSelf.noAssetView viewWithTag:kTagNoAssetViewMsgLabel];
        msg.text = NSLocalizedStringFromTable(@"You can sync videos onto your iPhone using iTunes.",@"UzysAssetsPickerController", nil);
        
    };
    
    if(self.assets.count ==0)
    {
        self.noAssetView.hidden = NO;
        if(self.segmentedControl.hidden == NO)
        {
            if(self.segmentedControl.selectedSegmentIndex ==0)
            {
                setNoImage();
            }
            else
            {
                setNoVideo();
            }
        }
        else
        {
            if(self.maximumNumberOfSelectionMedia >0)
            {
                UIImageView *imgView = (UIImageView *)[self.noAssetView viewWithTag:kTagNoAssetViewImageView];
                imgView.image = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_no_image"];
                DLog(@"no media");
                UILabel *title = (UILabel *)[self.noAssetView viewWithTag:kTagNoAssetViewTitleLabel];
                title.text = NSLocalizedStringFromTable(@"No Videos", @"UzysAssetsPickerController",nil);
                UILabel *msg = (UILabel *)[self.noAssetView viewWithTag:kTagNoAssetViewMsgLabel];
                msg.text = NSLocalizedStringFromTable(@"You can sync media onto your iPhone using iTunes.",@"UzysAssetsPickerController", nil);
                
            }
            else if(self.maximumNumberOfSelectionPhoto == 0)
            {
                setNoVideo();
            }
            else if(self.maximumNumberOfSelectionVideo == 0)
            {
                setNoImage();
            }
        }
    }
    else
    {
        self.noAssetView.hidden = YES;
    }
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kAssetsViewCellIdentifier;
    
    UzysAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell applyData:[self.assets objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL didExceedMaximumNumberOfSelection = [collectionView indexPathsForSelectedItems].count >= self.maximumNumberOfSelection;
    if (didExceedMaximumNumberOfSelection && self.delegate && [self.delegate respondsToSelector:@selector(uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:)]) {
        [self.delegate uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:self];
    }
    return !didExceedMaximumNumberOfSelection;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *selectedAsset = [self.assets objectAtIndex:indexPath.item];
    [self.orderedSelectedItem addObject:selectedAsset];
    [self setAssetsCountWithSelectedIndexPaths:collectionView.indexPathsForSelectedItems];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *deselectedAsset = [self.assets objectAtIndex:indexPath.item];
    
    [self.orderedSelectedItem removeObject:deselectedAsset];
    [self setAssetsCountWithSelectedIndexPaths:collectionView.indexPathsForSelectedItems];
}


#pragma mark - Actions

- (void)finishPickingAssets
{
    NSMutableArray *assets = [[NSMutableArray alloc] initWithArray:self.orderedSelectedItem];
    //
    //    for (NSIndexPath *index in self.orderedSelectedItem)
    //    {
    //        [assets addObject:[self.assets objectAtIndex:index.item]];
    //    }
    //
    if([assets count]>0)
    {
        UzysAssetsPickerController *picker = (UzysAssetsPickerController *)self;
        
        if([picker.delegate respondsToSelector:@selector(uzysAssetsPickerController:didFinishPickingAssets:)])
            [picker.delegate uzysAssetsPickerController:picker didFinishPickingAssets:assets];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}
#pragma mark - Helper methods
- (NSDictionary *)queryStringToDictionaryOfNSURL:(NSURL *)url
{
    NSArray *urlComponents = [url.query componentsSeparatedByString:@"&"];
    if (urlComponents.count <= 0)
    {
        return nil;
    }
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        [queryDict setObject:pairComponents[1] forKey:pairComponents[0]];
    }
    return [queryDict copy];
}

- (NSUInteger)indexOfAssetGroup:(ALAssetsGroup *)group inGroups:(NSArray *)groups
{
    NSString *targetGroupId = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
    __block NSUInteger index = NSNotFound;
    [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ALAssetsGroup *g = obj;
        NSString *gid = [g valueForProperty:ALAssetsGroupPropertyPersistentID];
        if ([gid isEqualToString:targetGroupId])
        {
            index = idx;
            *stop = YES;
        }
        
    }];
    return index;
}

- (NSString *)getUTCFormattedDate:(NSDate *)localDate {
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    }
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}

// Mostly from here: http://stackoverflow.com/questions/3884060/need-help-in-saving-geotag-info-with-photo-on-ios4-1
- (void)addGPSLocation:(NSMutableDictionary *)metaData {
    
    if (self.location != nil) {
        
        CLLocationDegrees exifLatitude  = location.coordinate.latitude;
        CLLocationDegrees exifLongitude = location.coordinate.longitude;
        
        NSString *latRef;
        NSString *lngRef;
        if (exifLatitude < 0.0) {
            exifLatitude = exifLatitude * -1.0f;
            latRef = @"S";
        } else {
            latRef = @"N";
        }
        
        if (exifLongitude < 0.0) {
            exifLongitude = exifLongitude * -1.0f;
            lngRef = @"W";
        } else {
            lngRef = @"E";
        }
        
        NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];
        if ([metaData objectForKey:(NSString*)kCGImagePropertyGPSDictionary]) {
            [locDict addEntriesFromDictionary:[metaData objectForKey:(NSString*)kCGImagePropertyGPSDictionary]];
        }
        [locDict setObject:[self getUTCFormattedDate:location.timestamp] forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
        [locDict setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
        [locDict setObject:lngRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];
        [locDict setObject:[NSNumber numberWithFloat:location.horizontalAccuracy] forKey:(NSString*)kCGImagePropertyGPSDOP];
        [locDict setObject:[NSNumber numberWithFloat:location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
        
        [metaData setObject:locDict forKey:(NSString*)kCGImagePropertyGPSDictionary];
    }
}

#pragma mark - Notification

- (void)assetsLibraryUpdated:(NSNotification *)notification
{
    //recheck here
    if(![notification.name isEqualToString:ALAssetsLibraryChangedNotification])
    {
        return ;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        NSDictionary* info = [notification userInfo];
        NSSet *updatedAssets = [info objectForKey:ALAssetLibraryUpdatedAssetsKey];
        NSSet *updatedAssetGroup = [info objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
        NSSet *deletedAssetGroup = [info objectForKey:ALAssetLibraryDeletedAssetGroupsKey];
        NSSet *insertedAssetGroup = [info objectForKey:ALAssetLibraryInsertedAssetGroupsKey];
        DLog(@"-------------+");
        DLog(@"updated assets:%@", updatedAssets);
        DLog(@"updated asset group:%@", updatedAssetGroup);
        DLog(@"deleted asset group:%@", deletedAssetGroup);
        DLog(@"inserted asset group:%@", insertedAssetGroup);
        DLog(@"-------------=");
        
        if(info == nil)
        {
            //AllClear
            [strongSelf setupGroup:nil withSetupAsset:YES];
            return;
        }
        
        if(info.count == 0)
        {
            return;
        }
        
        if (deletedAssetGroup.count > 0 || insertedAssetGroup.count > 0 || updatedAssetGroup.count >0)
        {
            BOOL currentAssetsGroupIsInDeletedAssetGroup = NO;
            BOOL currentAssetsGroupIsInUpdatedAssetGroup = NO;
            NSString *currentAssetGroupId = [strongSelf.assetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
            //check whether user deleted a chosen assetGroup.
            for (NSURL *groupUrl in deletedAssetGroup)
            {
                NSDictionary *queryDictionInURL = [strongSelf queryStringToDictionaryOfNSURL:groupUrl];
                if ([queryDictionInURL[@"id"] isEqualToString:currentAssetGroupId])
                {
                    currentAssetsGroupIsInDeletedAssetGroup = YES;
                    break;
                }
            }
            for (NSURL *groupUrl in updatedAssetGroup)
            {
                NSDictionary *queryDictionInURL = [strongSelf queryStringToDictionaryOfNSURL:groupUrl];
                if ([queryDictionInURL[@"id"] isEqualToString:currentAssetGroupId])
                {
                    currentAssetsGroupIsInUpdatedAssetGroup = YES;
                    break;
                }
            }
            
            if (currentAssetsGroupIsInDeletedAssetGroup || [strongSelf.assetsGroup numberOfAssets]==0)
            {
                //if user really deletes a chosen assetGroup, make it self.groups[0] to be default selected.
                [strongSelf setupGroup:^{
                    [strongSelf.groupPicker reloadData];
                    [strongSelf.groupPicker.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                } withSetupAsset:YES];
                return;
            }
            else
            {
                if(currentAssetsGroupIsInUpdatedAssetGroup)
                {
                    NSMutableArray *selectedItems = [NSMutableArray array];
                    NSArray *selectedPath = strongSelf.collectionView.indexPathsForSelectedItems;
                    
                    for (NSIndexPath *idxPath in selectedPath)
                    {
                        [selectedItems addObject:[strongSelf.assets objectAtIndex:idxPath.row]];
                    }
                    NSInteger beforeAssets = strongSelf.assets.count;
                    [strongSelf setupAssets:^{
                        for (ALAsset *item in selectedItems)
                        {
                            BOOL isExist = false;
                            for(ALAsset *asset in strongSelf.assets)
                            {
                                if([[[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString] isEqualToString:[[item valueForProperty:ALAssetPropertyAssetURL] absoluteString]])
                                {
                                    NSUInteger idx = [strongSelf.assets indexOfObject:asset];
                                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:idx inSection:0];
                                    [strongSelf.collectionView selectItemAtIndexPath:newPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                                    isExist = true;
                                }
                            }
                            if(isExist ==false)
                            {
                                [strongSelf.orderedSelectedItem removeObject:item];
                            }
                        }
                        
                        [strongSelf setAssetsCountWithSelectedIndexPaths:strongSelf.collectionView.indexPathsForSelectedItems];
                        if(strongSelf.assets.count > beforeAssets)
                        {
                            [strongSelf.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
                        }
                        
                    }];
                    [strongSelf setupGroup:^{
                        [strongSelf.groupPicker reloadData];
                    } withSetupAsset:NO];
                    
                    
                }
                else
                {
                    [strongSelf setupGroup:^{
                        [strongSelf.groupPicker reloadData];
                    } withSetupAsset:NO];
                    return;
                }
            }
            
        }
        
        
    });
}
#pragma mark - Property
- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    [self.btnTitle setTitle:title forState:UIControlStateNormal];
    [self.btnTitle setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
    [self.btnTitle setTitleEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
    [self.btnTitle layoutIfNeeded];
}
- (void)menuArrowRotate
{
    [UIView animateWithDuration:0.35 animations:^{
        if(self.groupPicker.isOpen)
        {
            self.imageViewTitleArrow.transform = CGAffineTransformMakeRotation(M_PI);
        }
        else
        {
            self.imageViewTitleArrow.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
    }];
    
}
#pragma mark - Control Action
- (IBAction)btnAction:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    switch (btn.tag) {
        case kTagButtonCamera:
        {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                NSString *title = NSLocalizedStringFromTable(@"Error", @"UzysAssetsPickerController", nil);
                NSString *message = NSLocalizedStringFromTable(@"Device has no camera", @"UzysAssetsPickerController", nil);
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [myAlertView show];
            }
            else
            {
                __weak typeof(self) weakSelf = self;
                [self presentViewController:self.picker animated:YES completion:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    //카메라 화면으로 가면 강제로 카메라 롤로 변경.
                    NSString *curGroupName =[[strongSelf.assetsGroup valueForProperty:ALAssetsGroupPropertyURL] absoluteString];
                    NSString *cameraRollName = [[strongSelf.groups[0] valueForProperty:ALAssetsGroupPropertyURL] absoluteString];
                    
                    if(![curGroupName isEqualToString:cameraRollName] )
                    {
                        strongSelf.assetsGroup = strongSelf.groups[0];
                        [strongSelf changeGroup:0];
                    }
                }];
            }
        }
            break;
        case kTagButtonClose:
        {
            if([self.delegate respondsToSelector:@selector(uzysAssetsPickerControllerDidCancel:)])
            {
                [self.delegate uzysAssetsPickerControllerDidCancel:self];
            }
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
            break;
        case kTagButtonGroupPicker:
        {
            [self.groupPicker toggle];
            [self menuArrowRotate];
        }
            break;
        case kTagButtonDone:
            [self finishPickingAssets];
            break;
        default:
            break;
    }
}

- (IBAction)indexDidChangeForSegmentedControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if(selectedSegment ==0)
    {
        [self changeAssetType:YES endBlock:nil];
    }
    else
    {
        [self changeAssetType:NO endBlock:nil];
    }
}
- (void)saveAssetsAction:(NSURL *)assetURL error:(NSError *)error isPhoto:(BOOL)isPhoto {
    if(error)
        return;
    __weak typeof(self) weakSelf = self;
    [self.assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (asset ==nil)
            {
                return ;
            }
            if(self.curAssetFilterType == 0 || (self.curAssetFilterType ==1 && isPhoto ==YES) || (self.curAssetFilterType == 2 && isPhoto ==NO))
            {
                NSMutableArray *selectedItems = [NSMutableArray array];
                NSArray *selectedPath = self.collectionView.indexPathsForSelectedItems;
                
                for (NSIndexPath *idxPath in selectedPath)
                {
                    [selectedItems addObject:[self.assets objectAtIndex:idxPath.row]];
                }
                
                [self.assets insertObject:asset atIndex:0];
                [self reloadData];
                
                for (ALAsset *item in selectedItems)
                {
                    for(ALAsset *asset in self.assets)
                    {
                        if([[[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString] isEqualToString:[[item valueForProperty:ALAssetPropertyAssetURL] absoluteString]])
                        {
                            NSUInteger idx = [self.assets indexOfObject:asset];
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:idx inSection:0];
                            [self.collectionView selectItemAtIndexPath:newPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        }
                    }
                }
                [self.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
                
                if(self.maximumNumberOfSelection > self.collectionView.indexPathsForSelectedItems.count)
                {
                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.collectionView selectItemAtIndexPath:newPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                    [self.orderedSelectedItem addObject:asset];
                }
                [self setAssetsCountWithSelectedIndexPaths:self.collectionView.indexPathsForSelectedItems];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(assetsLibraryUpdated:) name:ALAssetsLibraryChangedNotification object:nil];
            });
            
            
        });
        
    } failureBlock:^(NSError *err){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(assetsLibraryUpdated:) name:ALAssetsLibraryChangedNotification object:nil];
        });
        
    }];
}

#pragma mark - UIImagerPickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak typeof(self) weakSelf = self;
    //사진 촬영 시
    if (CFStringCompare((CFStringRef) [info objectForKey:UIImagePickerControllerMediaType], kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        if(self.segmentedControl.selectedSegmentIndex ==1 && self.segmentedControl.hidden == NO)
        {
            self.segmentedControl.selectedSegmentIndex = 0;
            [self changeAssetType:YES endBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                UIImage *image = info[UIImagePickerControllerOriginalImage];
                [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:ALAssetsLibraryChangedNotification object:nil];
                
                NSMutableDictionary *metaData = [NSMutableDictionary dictionaryWithDictionary:info[UIImagePickerControllerMediaMetadata]];
                [self addGPSLocation:metaData];
                
                [strongSelf.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage metadata:metaData completionBlock:^(NSURL *assetURL, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self saveAssetsAction:assetURL error:error isPhoto:YES];
                    });
                    DLog(@"writeImageToSavedPhotosAlbum");
                }];
                
            }];
            
        }
        else
        {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
            
            NSMutableDictionary *metaData = [NSMutableDictionary dictionaryWithDictionary:info[UIImagePickerControllerMediaMetadata]];
            [self addGPSLocation:metaData];
            
            [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage metadata:metaData completionBlock:^(NSURL *assetURL, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf saveAssetsAction:assetURL error:error isPhoto:YES];
                });
                DLog(@"writeImageToSavedPhotosAlbum");
            }];
        }
    }
    else //비디오 촬영시
    {
        if(self.segmentedControl.selectedSegmentIndex ==0 && self.segmentedControl.hidden == NO)
        {
            self.segmentedControl.selectedSegmentIndex = 1;
            [self changeAssetType:NO endBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:ALAssetsLibraryChangedNotification object:nil];
                [strongSelf.assetsLibrary writeVideoAtPathToSavedPhotosAlbum:info[UIImagePickerControllerMediaURL] completionBlock:^(NSURL *assetURL, NSError *error) {
                    DLog(@"assetURL %@",assetURL);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self saveAssetsAction:assetURL error:error isPhoto:NO];
                    });
                }];
                
            }];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
            [self.assetsLibrary writeVideoAtPathToSavedPhotosAlbum:info[UIImagePickerControllerMediaURL] completionBlock:^(NSURL *assetURL, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self saveAssetsAction:assetURL error:error isPhoto:NO];
                });
                
            }];
            
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIViewController Property

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
