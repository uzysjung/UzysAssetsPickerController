//
//  uzysViewController.m
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "uzysViewController.h"
#import "UzysAssetsPickerController.h"
@interface uzysViewController () <UzysAssetsPickerControllerDelegate>
@property (nonatomic,strong) UIButton *btnImage;
@property (nonatomic,strong) UIButton *btnVideo;
@property (nonatomic,strong) UIButton *btnImageOrVideo;
@property (nonatomic,strong) UIButton *btnImageAndVideo;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *labelDescription;
@end

@implementation uzysViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[UIButton appearance] setTintColor:[UIColor darkTextColor]];
    [UIButton appearance].titleLabel.font = [UIFont systemFontOfSize:14];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 50, 200, 200)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor lightGrayColor];
    self.imageView.center = CGPointMake(self.view.center.x, self.imageView.center.y);
    [self.view addSubview:self.imageView];

    self.labelDescription = [[UILabel alloc] initWithFrame:CGRectMake(60, 260, 200, 20)];
    self.labelDescription.textAlignment = NSTextAlignmentCenter;
    self.labelDescription.font = [UIFont systemFontOfSize:12];
    self.labelDescription.textColor = [UIColor lightGrayColor];
    [self.view addSubview:self.labelDescription];
    
    CGRect frame = CGRectMake(60, 290, 200, 30);
    self.btnImage = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.btnImage setTitle:NSLocalizedStringFromTable(@"Image Only", @"UzysAssetsPickerController", nil) forState:UIControlStateNormal];
    [self.btnImage addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.btnImage.frame = frame;
    self.btnImage.center = CGPointMake(self.view.center.x, self.btnImage.center.y);
    [self.view addSubview:self.btnImage];
    
    self.btnVideo = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.btnVideo setTitle:NSLocalizedStringFromTable(@"Video Only", @"UzysAssetsPickerController", nil) forState:UIControlStateNormal];
    [self.btnVideo addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    frame.origin.y = frame.origin.y + 40;
    self.btnVideo.frame = frame;
    self.btnVideo.center = CGPointMake(self.view.center.x, self.btnVideo.center.y);
    [self.view addSubview:self.btnVideo];
    
    self.btnImageOrVideo = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.btnImageOrVideo setTitle:NSLocalizedStringFromTable(@"Image or Video", @"UzysAssetsPickerController", nil) forState:UIControlStateNormal];
    [self.btnImageOrVideo addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    frame.origin.y = frame.origin.y + 40;
    self.btnImageOrVideo.frame = frame;
    self.btnImageOrVideo.center = CGPointMake(self.view.center.x, self.btnImageOrVideo.center.y);
    [self.view addSubview:self.btnImageOrVideo];
    
    self.btnImageAndVideo = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.btnImageAndVideo setTitle:NSLocalizedStringFromTable(@"Image and Video", @"UzysAssetsPickerController", nil) forState:UIControlStateNormal];
    [self.btnImageAndVideo addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    frame.origin.y = frame.origin.y + 40;
    self.btnImageAndVideo.frame = frame;
    self.btnImageAndVideo.center = CGPointMake(self.view.center.x, self.btnImageAndVideo.center.y);
    [self.view addSubview:self.btnImageAndVideo];
}
-(void)viewDidAppear:(BOOL)animated
{

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)btnAction:(id)sender
{
    //if you want to checkout how to config appearance, just uncomment the following 4 lines code.
#if 0
    UzysAppearanceConfig *appearanceConfig = [[UzysAppearanceConfig alloc] init];
    appearanceConfig.finishSelectionButtonColor = [UIColor blueColor];
    appearanceConfig.assetsGroupSelectedImageName = @"checker.png";
    appearanceConfig.cellSpacing = 1.0f;
    appearanceConfig.assetsCountInALine = 5;
    [UzysAssetsPickerController setUpAppearanceConfig:appearanceConfig];
#endif

    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    if([sender isEqual:self.btnImage])
    {
        picker.maximumNumberOfSelectionVideo = 0;
        picker.maximumNumberOfSelectionPhoto = 3;
    }
    else if([sender isEqual:self.btnVideo])
    {
        picker.maximumNumberOfSelectionVideo = 2;
        picker.maximumNumberOfSelectionPhoto = 0;
    }
    else if([sender isEqual:self.btnImageOrVideo])
    {
        picker.maximumNumberOfSelectionVideo = 2;
        picker.maximumNumberOfSelectionPhoto = 3;
    }
    else if([sender isEqual:self.btnImageAndVideo])
    {
        picker.maximumNumberOfSelectionMedia = 2;
    }
    [self presentViewController:picker animated:YES completion:^{
        
    }];

}

#pragma mark - UzysAssetsPickerControllerDelegate methods
- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    self.imageView.backgroundColor = [UIColor clearColor];
    DLog(@"assets %@",assets);
    if(assets.count ==1)
    {
        self.labelDescription.text = [NSString stringWithFormat:@"%ld asset selected",(unsigned long)assets.count];
    }
    else
    {
        self.labelDescription.text = [NSString stringWithFormat:@"%ld assets selected",(unsigned long)assets.count];
    }
    __weak typeof(self) weakSelf = self;
    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
            [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ALAsset *representation = obj;
                
                    UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullResolutionImage
                                                       scale:representation.defaultRepresentation.scale
                                                 orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
                weakSelf.imageView.image = img;
                *stop = YES;
            }];
        
        
    }
    else //Video
    {
        ALAsset *alAsset = assets[0];
        
        UIImage *img = [UIImage imageWithCGImage:alAsset.defaultRepresentation.fullResolutionImage
                                           scale:alAsset.defaultRepresentation.scale
                                     orientation:(UIImageOrientation)alAsset.defaultRepresentation.orientation];
        weakSelf.imageView.image = img;

        
        
        ALAssetRepresentation *representation = alAsset.defaultRepresentation;
        NSURL *movieURL = representation.url;
        NSURL *uploadURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"test"] stringByAppendingString:@".mp4"]];
        AVAsset *asset      = [AVURLAsset URLAssetWithURL:movieURL options:nil];
        AVAssetExportSession *session =
        [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        
        session.outputFileType  = AVFileTypeQuickTimeMovie;
        session.outputURL       = uploadURL;
        
        [session exportAsynchronouslyWithCompletionHandler:^{
            
            if (session.status == AVAssetExportSessionStatusCompleted)
            {
                DLog(@"output Video URL %@",uploadURL);
            }
            
        }];
        
    }
    
}

- (void)uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:(UzysAssetsPickerController *)picker
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedStringFromTable(@"Exceed Maximum Number Of Selection", @"UzysAssetsPickerController", nil)
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
