//
//  JSON_DemoAppDelegate.h
//  JSON Demo
//
//  Created by Donn Straight on 7/7/10.
//  Copyright Liberty Mutual - Open Seas Innovation 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSON_DemoViewController;

@interface JSON_DemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    JSON_DemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet JSON_DemoViewController *viewController;

@end

