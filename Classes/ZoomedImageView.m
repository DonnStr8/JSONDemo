//
//  ZoomImageViewController.m
//
//  Created by John on 4/30/09.
//  Copyright 2009 iPhoneDeveloperTips.com. All rights reserved.
//

#import "ZoomedImageView.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Private interface definitions
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
@interface ZoomedImageView(private)
- (void)slideViewOffScreen;
@end

@implementation ZoomedImageView

/**************************************************************************
*
* Private implementation section
*
**************************************************************************/

#pragma mark -
#pragma mark Private Methods - Managing Events

/*-------------------------------------------------------------
*
*------------------------------------------------------------*/
- (void)slideViewOffScreen
{
  // Get the frame of this view
  CGRect frame = self.frame;
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:.45];

  // Set view to this offscreen location
  frame.origin.x = -320;
  self.frame = frame;

  // Slide view
  [UIView commitAnimations];
}

/**************************************************************************
*
* Class implementation section
*
**************************************************************************/

#pragma mark -
#pragma mark Initialization

/*-------------------------------------------------------------
*
*------------------------------------------------------------*/
- (id)initWithURL:(NSURL *)url
{
  if (self = [super init])
  {
    // Create the view offscreen (to the right)
    self.frame = CGRectMake(320, 0, 320, 240);

    // Setup image
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    fullsizeImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
        
    // Center the image...
    int width = fullsizeImage.frame.size.width;
    int height = fullsizeImage.frame.size.height; 
    
    int x = (320 - width) / 2;
    int y = (240 - height) / 2;
    
    [fullsizeImage setFrame:CGRectMake(x, y, width, height)];     
    fullsizeImage.userInteractionEnabled = YES;                                      
    [self addSubview:fullsizeImage];
    
  }
  
  return self;  
}

#pragma mark -
#pragma mark Event Mgmt

/*-------------------------------------------------------------
*
*------------------------------------------------------------*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
  [self slideViewOffScreen];
  
  // We now send the same event up to the next responder
  // (the JSONFlickrViewController) so we can show enable
  // the search textfield again
  [self.nextResponder touchesBegan:touches withEvent:event];
  
}

#pragma mark -
#pragma mark Cleanup

/*-------------------------------------------------------------
*
*------------------------------------------------------------*/
- (void)dealloc 
{
  [fullsizeImage release];
  [super dealloc];
}

@end
