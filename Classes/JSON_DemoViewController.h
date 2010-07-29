//
//  JSON_DemoViewController.h
//  JSON Demo
//
//  Created by Donn Straight on 7/7/10.
//  Copyright Liberty Mutual - Open Seas Innovation 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "ZoomedImageView.h"

@interface JSON_DemoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {

	UITextField     *searchTextField;
	UITableView     *theTableView;
	NSMutableArray  *photoTitles;         // Titles of images
	NSMutableArray  *photoSmallImageData; // Image data (thumbnail)
	NSMutableArray  *photoURLsLargeImage; // URL to larger image 
	
	ZoomedImageView  *fullImageViewController;
	UIActivityIndicatorView *activityIndicator;      

}

@property (nonatomic, assign) IBOutlet NSMutableArray *photoTitles;
@property (nonatomic, assign) IBOutlet NSMutableArray *photoSmallImageData;
@property (nonatomic, assign) IBOutlet NSMutableArray *photoURLsLargeImage;

- (void)searchFlickrPhotos:(NSString *)text;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end

