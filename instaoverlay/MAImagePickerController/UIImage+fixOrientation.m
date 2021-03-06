//
//  UIImage+fixOrientation.m
//  instaoverlay
//
//  Created by Maximilian Mackh on 11/11/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import "UIImage+fixOrientation.h"

@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation
{
    UIImage *src = [[UIImage alloc] initWithCGImage: self.CGImage
                                                         scale: 1.0
                                                   orientation: UIImageOrientationRight];

    return src;
}

//- (CGFloat) contentScale
//{
//    CGSize imageSize = self.image.size;
//    CGFloat imageScale = fminf(CGRectGetWidth(self.bounds)/imageSize.width, CGRectGetHeight(self.bounds)/imageSize.height);
//    return imageScale;
//}

@end
