//
//  MAImagePickerFinalViewController.m
//  instaoverlay
//
//  Created by Maximilian Mackh on 11/10/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import "MAImagePickerFinalViewController.h"

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import "MAOpenCV.h"
#import "MADrawRect.h"
#import "UIImageView+ContentFrame.h"

@interface MAImagePickerFinalViewController ()
@property(nonatomic, strong) MADrawRect* viewCrop;
@property (strong, nonatomic) UIImage *adjustedImage;

@property (strong, nonatomic) UIButton *firstSettingIcon;
@property (strong, nonatomic) UIButton *secondSettingIcon;
@property (strong, nonatomic) UIButton *thirdSettingIcon;
@property (strong, nonatomic) UIButton *fourthSettingIcon;

@property (strong, nonatomic) UIBarButtonItem *rotateButton;

@property (strong, nonatomic) UIImageView *activityIndicator;
@property (strong, nonatomic) UIActivityIndicatorView *progressIndicator;

@property (strong, nonatomic) UIImageView *finalImageView;
@end

@implementation MAImagePickerFinalViewController

@synthesize firstSettingIcon = _firstSettingIcon;
@synthesize secondSettingIcon = _secondSettingIcon;
@synthesize thirdSettingIcon = _thirdSettingIcon;
@synthesize fourthSettingIcon = _fourthSettingIcon;

@synthesize activityIndicator = _activityIndicator;
@synthesize progressIndicator = _progressIndicator;

@synthesize finalImageView = _finalImageView;
@synthesize adjustedImage = _adjustedImage;
@synthesize sourceImage = _sourceImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupToolbar];
    [self setupEditor];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _adjustedImage = _sourceImage;
    
    _finalImageView = [[UIImageView alloc] init];
    _finalImageView.userInteractionEnabled = YES;
    [_finalImageView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - (kCameraToolBarHeight + 70))];
    [_finalImageView setContentMode:UIViewContentModeScaleAspectFit];
    [_finalImageView setUserInteractionEnabled:YES];
    [_finalImageView setImage:_sourceImage];
    
    self.viewCrop = [[MADrawRect alloc] initWithFrame:_finalImageView.bounds];
    [_finalImageView addSubview:self.viewCrop];
    
    UIScrollView * imgScrollView = [[UIScrollView alloc] initWithFrame:_finalImageView.frame];
    [imgScrollView setScrollEnabled:YES];
    [imgScrollView setUserInteractionEnabled:YES];
    [imgScrollView addSubview:_finalImageView];
    [imgScrollView setMinimumZoomScale:1.0f];
    [imgScrollView setMaximumZoomScale:3.0f];
    [imgScrollView setDelegate:self];
    [self.view addSubview:imgScrollView];
    
    _progressIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_progressIndicator setFrame:CGRectMake(imgScrollView.frame.size.width / 2 - kActivityIndicatorSize / 2, imgScrollView.frame.size.height / 2 - kActivityIndicatorSize / 2, kActivityIndicatorSize, kActivityIndicatorSize)];
    [_progressIndicator setHidesWhenStopped:YES];
    [_progressIndicator stopAnimating];
    [self.view addSubview:_progressIndicator];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _finalImageView;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    int selectThis = 2;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"maimagepickercontrollerlasteditchoice"])
    {
        selectThis = [[NSUserDefaults standardUserDefaults] integerForKey:@"maimagepickercontrollerlasteditchoice"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"maimagepickercontrollerlasteditchoice"];
        selectThis = 2;
    }
    
    switch (selectThis) {
        case 1:
            [_firstSettingIcon sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        case 2:
            [_secondSettingIcon sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        case 3:
            [_thirdSettingIcon sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        case 4:
            [_fourthSettingIcon sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
    }
}

- (void)popCurrentViewController
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)comfirmFinishedImage
{
    [self storeImageToCache];
}

- (void)adjustPreviewImage
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        _adjustedImage = _sourceImage;
        
        if (currentlySelected == 1)
        {
            
        }
        
        if (currentlySelected != 1)
        {
            
            cv::Mat original;
            
            if (currentlySelected == 2)
            {
                if (_imageFrameEdited)
                {
                    original = [MAOpenCV cvMatGrayFromAdjustedUIImage:_sourceImage];
                }
                else
                {
                    original = [MAOpenCV cvMatGrayFromUIImage:_sourceImage];
                }
                
                cv::GaussianBlur(original, original, cvSize(11,11), 0);
                cv::adaptiveThreshold(original, original, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 5, 2);
                _adjustedImage = [MAOpenCV UIImageFromCVMat:original];
                
                original.release();
            }
            
            if (currentlySelected == 3)
            {
                if (_imageFrameEdited)
                {
                    original = [MAOpenCV cvMatGrayFromAdjustedUIImage:_sourceImage];
                }
                else
                {
                    original = [MAOpenCV cvMatGrayFromUIImage:_sourceImage];
                }
                
                cv::Mat new_image = cv::Mat::zeros( original.size(), original.type() );
                
                original.convertTo(new_image, -1, 1.4, -50);
                original.release();
                
                _adjustedImage = [MAOpenCV UIImageFromCVMat:new_image];
                new_image.release();
            }
            
            if (currentlySelected == 4)
            {
                if (_imageFrameEdited)
                {
                    original = [MAOpenCV cvMatFromAdjustedUIImage:_sourceImage];
                }
                else
                {
                    original = [MAOpenCV cvMatFromUIImage:_sourceImage];
                }
                
                cv::Mat new_image = cv::Mat::zeros( original.size(), original.type() );
                
                original.convertTo(new_image, -1, 1.9, -80);
                
                original.release();
                
                _adjustedImage = [MAOpenCV UIImageFromCVMat:new_image];
                new_image.release();
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self updateImageView];
                       });
    });
}

- (void) updateImageView
{
    [_finalImageView setNeedsDisplay];
    [_finalImageView setImage:_adjustedImage];
    
    [_progressIndicator stopAnimating];
    [self.view setUserInteractionEnabled:YES];
}

- (void) updateImageViewAnimated
{
    UIView *view = [_rotateButton valueForKey:@"view"];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI ];
    rotationAnimation.duration = 0.4;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    [UIView transitionWithView:_finalImageView
                      duration:0.4f
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        _finalImageView.image = _adjustedImage;
                    } completion:NULL];
    
    [_progressIndicator stopAnimating];
    [self.view setUserInteractionEnabled:YES];
}


- (void)storeImageToCache
{
    NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"maimagepickercontollerfinalimage.jpg"];
    NSData* imageData = UIImageJPEGRepresentation(_adjustedImage, 0.8);
    [imageData writeToFile:tmpPath atomically:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MAIPCSuccessInternal" object:tmpPath];
}

- (IBAction) filterChanged:(id) sender withEvent:(UIEvent *) event
{
    
    UIControl *control = sender;
    
    if (control.tag != currentlySelected)
    {
        [self.view setUserInteractionEnabled:NO];
        [_progressIndicator setHidden:NO];
        [_progressIndicator startAnimating];
        
        currentlySelected = control.tag;
        [[NSUserDefaults standardUserDefaults] setInteger:currentlySelected forKey:@"maimagepickercontrollerlasteditchoice"];
        
        [_firstSettingIcon setSelected:NO];
        [_secondSettingIcon setSelected:NO];
        [_thirdSettingIcon setSelected:NO];
        [_fourthSettingIcon setSelected:NO];
        
        [_firstSettingIcon setEnabled:YES];
        [_secondSettingIcon setEnabled:YES];
        [_thirdSettingIcon setEnabled:YES];
        [_fourthSettingIcon setEnabled:YES];
        
        int activityIndicatorOffset;
        
        
        switch (control.tag) {
            case 1:
                [_firstSettingIcon setSelected:YES];
                [_firstSettingIcon setEnabled:NO];
                activityIndicatorOffset = 22;
                break;
            case 2:
                [_secondSettingIcon setSelected:YES];
                [_secondSettingIcon setEnabled:NO];
                activityIndicatorOffset = 102;
                break;
            case 3:
                [_thirdSettingIcon setSelected:YES];
                [_thirdSettingIcon setEnabled:NO];
                activityIndicatorOffset = 182;
                break;
            case 4:
                [_fourthSettingIcon setSelected:YES];
                [_fourthSettingIcon setEnabled:NO];
                activityIndicatorOffset = 262;
                break;
        }
        
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void) {
                             [_activityIndicator setFrame:CGRectMake(activityIndicatorOffset, 52, 43, 8)];
                         }
                         completion:NULL];
        
        [self adjustPreviewImage];
    }
    
}

- (void)setupEditor
{
    UIView *editorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - (kCameraToolBarHeight + 60), self.view.bounds.size.width, 60)];
    
    UIImageView *editorViewBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 31, self.view.bounds.size.width, 29)];
    [editorViewBackground setImage:[UIImage imageNamed:@"f-setting-tray"]];
    
    
    UIView *firstSetting = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, editorView.frame.size.height)];
    _firstSettingIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    _firstSettingIcon.accessibilityLabel = @"No Filter";
    [_firstSettingIcon setFrame:CGRectMake(12, 0, 57, 58)];
    [_firstSettingIcon setBackgroundImage:[UIImage imageNamed:@"f-setting-1"] forState:UIControlStateNormal];
    [_firstSettingIcon setBackgroundImage:[UIImage imageNamed:@"f-setting-1-active"] forState:UIControlStateHighlighted];
    [_firstSettingIcon setTag:1];
    [_firstSettingIcon addTarget:self action:@selector(filterChanged:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [firstSetting addSubview:_firstSettingIcon];
    
    UIView *secondSetting = [[UIView alloc] initWithFrame:CGRectMake(80, 0, 80, editorView.frame.size.height)];
    _secondSettingIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    _secondSettingIcon.accessibilityLabel = @"Text Only Enhance Filter";
    [_secondSettingIcon setFrame:CGRectMake(12, 0, 57, 58)];
    [_secondSettingIcon setBackgroundImage:[UIImage imageNamed:@"f-setting-2"] forState:UIControlStateNormal];
    [_secondSettingIcon setBackgroundImage:[UIImage imageNamed:@"f-setting-2-active"] forState:UIControlStateHighlighted];
    [_secondSettingIcon setTag:2];
    [_secondSettingIcon addTarget:self action:@selector(filterChanged:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [secondSetting addSubview:_secondSettingIcon];
    
    UIView *thirdSetting = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 80, editorView.frame.size.height)];
    _thirdSettingIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    _thirdSettingIcon.accessibilityLabel = @"Photo and Text Enhance Filter (Black and White)";
    [_thirdSettingIcon setFrame:CGRectMake(12, 0, 57, 58)];
    [_thirdSettingIcon setBackgroundImage:[UIImage imageNamed:@"f-setting-3"] forState:UIControlStateNormal];
    [_thirdSettingIcon setBackgroundImage:[UIImage imageNamed:@"f-setting-3-active"] forState:UIControlStateHighlighted];
    [_thirdSettingIcon setTag:3];
    [_thirdSettingIcon addTarget:self action:@selector(filterChanged:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [thirdSetting addSubview:_thirdSettingIcon];
    
    UIView *fourthSetting = [[UIView alloc] initWithFrame:CGRectMake(240, 0, 80, editorView.frame.size.height)];
    _fourthSettingIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    _fourthSettingIcon.accessibilityLabel = @"Photo Only Enhance Filter";
    [_fourthSettingIcon setFrame:CGRectMake(12, 0, 57, 58)];
    [_fourthSettingIcon setBackgroundImage:[UIImage imageNamed:@"f-setting-4"] forState:UIControlStateNormal];
    [_fourthSettingIcon setBackgroundImage:[UIImage imageNamed:@"f-setting-4-active"] forState:UIControlStateHighlighted];
    [_fourthSettingIcon setTag:4];
    [_fourthSettingIcon addTarget:self action:@selector(filterChanged:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [fourthSetting addSubview:_fourthSettingIcon];
    
    _activityIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"f-setting-indicator-active"]];
    
    [editorView addSubview:editorViewBackground];
    
    [editorView addSubview:firstSetting];
    [editorView addSubview:secondSetting];
    [editorView addSubview:thirdSetting];
    [editorView addSubview:fourthSetting];
    [editorView addSubview:_activityIndicator];
    
    [self.view addSubview:editorView];
}

- (void)setupToolbar
{
    UIToolbar *finishToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kCameraToolBarHeight, self.view.bounds.size.width, kCameraToolBarHeight)];
    [finishToolBar setBackgroundImage:[UIImage imageNamed:@"camera-bottom-bar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *undoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-icon-crop"] style:UIBarButtonItemStylePlain target:self action:@selector(popCurrentViewController)];
    undoButton.accessibilityLabel = @"Return to Frame Adjustment View";
    
    _rotateButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"f-setting-rotate"] style:UIBarButtonItemStylePlain target:self action:@selector(rotateImage)];
    _rotateButton.accessibilityLabel = @"Rotate Image by 90 Degrees";
    
    UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm-button"] style:UIBarButtonItemStylePlain target:self action:@selector(comfirmFinishedImage)];
    confirmButton.accessibilityLabel = @"Confirm adjusted Image";
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixedSpace setWidth:10.0f];
    
    [finishToolBar setItems:[NSArray arrayWithObjects:fixedSpace,undoButton,flexibleSpace,_rotateButton,flexibleSpace,confirmButton,fixedSpace, nil]];
    
    [self.view addSubview:finishToolBar];
}

- (void)rotateImage
{
    
    switch (_adjustedImage.imageOrientation)
    {
        case UIImageOrientationRight:
            _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationDown];
            break;
        case UIImageOrientationDown:
            _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationLeft];
            break;
        case UIImageOrientationLeft:
            _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationUp];
            break;
        case UIImageOrientationUp:
            _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationRight];
            break;
        default:
            break;
    }
    
    
    [self updateImageViewAnimated];
    
}

- (void)confirmedImage
{
    BOOL edited;
    if ([self.viewCrop frameEdited])
    {
        //cv::GaussianBlur(original, original, cvSize(11,11), 0);
        //cv::adaptiveThreshold(original, original, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 5, 2);
        
        CGFloat scaleFactor =  [self.finalImageView contentScale];
        CGPoint ptBottomLeft = [self.viewCrop coordinatesForPoint:1 withScaleFactor:scaleFactor];
        CGPoint ptBottomRight = [self.viewCrop coordinatesForPoint:2 withScaleFactor:scaleFactor];
        CGPoint ptTopRight = [self.viewCrop coordinatesForPoint:3 withScaleFactor:scaleFactor];
        CGPoint ptTopLeft = [self.viewCrop coordinatesForPoint:4 withScaleFactor:scaleFactor];
        
        CGFloat w1 = sqrt( pow(ptBottomRight.x - ptBottomLeft.x , 2) + pow(ptBottomRight.x - ptBottomLeft.x, 2));
        CGFloat w2 = sqrt( pow(ptTopRight.x - ptTopLeft.x , 2) + pow(ptTopRight.x - ptTopLeft.x, 2));
        
        CGFloat h1 = sqrt( pow(ptTopRight.y - ptBottomRight.y , 2) + pow(ptTopRight.y - ptBottomRight.y, 2));
        CGFloat h2 = sqrt( pow(ptTopLeft.y - ptBottomLeft.y , 2) + pow(ptTopLeft.y - ptBottomLeft.y, 2));
        
        CGFloat maxWidth = (w1 < w2) ? w1 : w2;
        CGFloat maxHeight = (h1 < h2) ? h1 : h2;
        
        cv::Point2f src[4], dst[4];
        src[0].x = ptTopLeft.x;
        src[0].y = ptTopLeft.y;
        src[1].x = ptTopRight.x;
        src[1].y = ptTopRight.y;
        src[2].x = ptBottomRight.x;
        src[2].y = ptBottomRight.y;
        src[3].x = ptBottomLeft.x;
        src[3].y = ptBottomLeft.y;
        
        dst[0].x = 0;
        dst[0].y = 0;
        dst[1].x = maxWidth - 1;
        dst[1].y = 0;
        dst[2].x = maxWidth - 1;
        dst[2].y = maxHeight - 1;
        dst[3].x = 0;
        dst[3].y = maxHeight - 1;
        
        cv::Mat undistorted = cv::Mat( cvSize(maxWidth,maxHeight), CV_8UC1);
        cv::Mat original = [MAOpenCV cvMatFromUIImage:_adjustedImage];
        cv::warpPerspective(original, undistorted, cv::getPerspectiveTransform(src, dst), cvSize(maxWidth, maxHeight));
        original.release();
        
        _adjustedImage = [MAOpenCV UIImageFromCVMat:undistorted];
        undistorted.release();
        edited = YES;
    }
    else
    {
        edited = NO;
    }
    
    MAImagePickerFinalViewController *finalView = [[MAImagePickerFinalViewController alloc] init];
    finalView.sourceImage = _adjustedImage;
    finalView.imageFrameEdited = edited;
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.4;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:finalView animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
