//
//  MAImagePickerFinalViewController.h
//  instaoverlay
//
//  Created by Maximilian Mackh on 11/10/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAConstants.h"

@interface MAImagePickerFinalViewController : UIViewController <UIScrollViewDelegate>
{
    int currentlySelected;
    UIImageOrientation sourceImageOrientation;
}

@property BOOL imageFrameEdited;

@property (strong, nonatomic) UIImage *sourceImage;

@end
