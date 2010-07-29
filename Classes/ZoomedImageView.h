//
//  ZoomImageViewController.h
//
//  Created by John on 4/30/09.
//  Copyright 2009 iPhoneDeveloperTips.com. All rights reserved.
//

@interface ZoomedImageView : UIView
{
  UIImageView *fullsizeImage;
}

- (id)initWithURL:(NSURL *)url;

@end
