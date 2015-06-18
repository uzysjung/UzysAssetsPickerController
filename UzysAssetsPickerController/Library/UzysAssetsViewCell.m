//
//  UzysAssetsViewCell.m
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

#import "UzysAssetsViewCell.h"
#import "UzysAppearanceConfig.h"

@interface UzysAssetsViewCell()
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *videoImage;
@end
@implementation UzysAssetsViewCell

static UIFont *videoTimeFont = nil;

static CGFloat videoTimeHeight;
static UIImage *videoIcon;
static UIColor *videoTitleColor;
static UIImage *checkedIcon;
static UIImage *uncheckedIcon;
static UIColor *selectedColor;
static CGFloat thumnailLength;
+ (void)initialize
{
    UzysAppearanceConfig *appearanceConfig = [UzysAppearanceConfig sharedConfig];

    videoTitleColor      = [UIColor whiteColor];
    videoTimeFont       = [UIFont systemFontOfSize:12];
    videoTimeHeight     = 20.0f;
    videoIcon       = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_assets_video"];
    
    checkedIcon     = [UIImage Uzys_imageNamed:appearanceConfig.assetSelectedImageName];
    uncheckedIcon   = [UIImage Uzys_imageNamed:appearanceConfig.assetDeselectedImageName];
    selectedColor   = [UIColor colorWithWhite:1 alpha:0.3];
    
    thumnailLength = ([UIScreen mainScreen].bounds.size.width - appearanceConfig.cellSpacing * ((CGFloat)appearanceConfig.assetsCountInALine - 1.0f)) / (CGFloat)appearanceConfig.assetsCountInALine;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.opaque = YES;
        
    }
    return self;
}
- (void)applyData:(ALAsset *)asset
{
    self.asset  = asset;
    self.image  = [UIImage imageWithCGImage:asset.thumbnail];
    self.type   = [asset valueForProperty:ALAssetPropertyType];
    self.title  = [UzysAssetsViewCell getTimeStringOfTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
    
    if(selected)
    {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformMakeScale(0.97, 0.97);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformMakeScale(1.03, 1.03);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }];
        
    }
}


- (void)drawRect:(CGRect)rect
{
    // Image
    [self.image drawInRect:CGRectMake(-.5f, -1.0f, thumnailLength+1.5f, thumnailLength+1.0f)];
    
    // Video title
    if ([self.type isEqual:ALAssetTypeVideo])
    {
        // Create a gradient from transparent to black
        CGFloat colors [] =
        {
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.8,
            0.0, 0.0, 0.0, 1.0
        };
        
        CGFloat locations [] = {0.0, 0.75, 1.0};
        
        CGColorSpaceRef baseSpace   = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient      = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 2);
        CGContextRef context    = UIGraphicsGetCurrentContext();
        
        CGFloat height          = rect.size.height;
        CGPoint startPoint      = CGPointMake(CGRectGetMidX(rect), height - videoTimeHeight);
        CGPoint endPoint        = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
        
        NSDictionary *attributes = @{NSFontAttributeName:videoTimeFont,NSForegroundColorAttributeName:videoTitleColor};
        CGSize titleSize        = [self.title sizeWithAttributes:attributes];
        [self.title drawInRect:CGRectMake(rect.size.width - (NSInteger)titleSize.width - 2 , startPoint.y + (videoTimeHeight - 12) / 2, thumnailLength, height) withAttributes:attributes];
        
        [videoIcon drawAtPoint:CGPointMake(2, startPoint.y + (videoTimeHeight - videoIcon.size.height) / 2)];
        
    }
    
    if (self.selected)
    {
        CGContextRef context    = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context, selectedColor.CGColor);
		CGContextFillRect(context, rect);
        [checkedIcon drawAtPoint:CGPointMake(CGRectGetMaxX(rect) - checkedIcon.size.width -2, CGRectGetMinY(rect)+2)];
    }
    else
    {
        [uncheckedIcon drawAtPoint:CGPointMake(CGRectGetMaxX(rect) - uncheckedIcon.size.width -2, CGRectGetMinY(rect)+2)];
        
    }
}


+ (NSString *)getTimeStringOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *dateRef = [[NSDate alloc] init];
    NSDate *dateNow = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:dateRef];
    
    unsigned int uFlags =
    NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit |
    NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;

    
    NSDateComponents *components = [calendar components:uFlags
                                               fromDate:dateRef
                                                 toDate:dateNow
                                                options:0];
    NSString *retTimeInterval;
    if (components.hour > 0)
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)components.hour, (long)components.minute, (long)components.second];
    }
    
    else
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld", (long)components.minute, (long)components.second];
    }
    return retTimeInterval;
}


@end
