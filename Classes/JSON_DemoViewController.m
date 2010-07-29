//
//  JSON_DemoViewController.m
//  JSON Demo
//
//  Created by Donn Straight on 7/7/10.
//  Copyright Liberty Mutual - Open Seas Innovation 2010. All rights reserved.
//

#import "JSON_DemoViewController.h"
#import "JSON.h"


// Replace with your Flickr key
NSString *const FlickrAPIKey = @"2c6c0156b6278f7c49b4119b926dda40";
NSString *const FlickrSecret = @"6447cd35b8b124d8";

@implementation JSON_DemoViewController

@synthesize photoTitles;
@synthesize photoSmallImageData;
@synthesize photoURLsLargeImage; 


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	// Store incoming data into a string
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"jsonString: %@",jsonString);
	
	// Create a dictionary from the JSON string
	NSDictionary *results = [jsonString JSONValue];
	
	// Build an array from the dictionary for easy access to each entry
	NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
	
	for (id key in results) {
		NSLog(@"key: %@", key);
		NSLog(@"value: %@", [results objectForKey:key]);
	}
	
	
	// Loop through each entry in the dictionary...
	for (NSDictionary *photo in photos)
	{
		// Get title of the image
		NSString *title = [photo objectForKey:@"title"];
		
		// Save the title to the photo titles array
		[photoTitles addObject:(title.length > 0 ? title : @"Untitled")];
		
		// Build the URL to where the image is stored (see the Flickr API)
		// In the format http://farmX.static.flickr.com/server/id/secret
		// Notice the "_s" which requests a "small" image 75 x 75 pixels
		NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
		
		//debug(@"photoURLString: %@", photoURLString);
		
		// The performance (scrolling) of the table will be much better if we
		// build an array of the image data here, and then add this data as
		// the cell.image value (see cellForRowAtIndexPath:)
		[photoSmallImageData addObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURLString]]];
		
		// Build and save the URL to the large image so we can zoom
		// in on the image if requested
		photoURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_m.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
		[photoURLsLargeImage addObject:[NSURL URLWithString:photoURLString]];        
		
		//debug(@"photoURLsLareImage: %@\n\n", photoURLString);	
	}
	
	[theTableView reloadData];
	[activityIndicator stopAnimating];
	[jsonString release];
	
}

-(void)searchFlickrPhotos:(NSString *)text
{
	// Build the string to call the Flickr API
	NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=25&format=json&nojsoncallback=1", FlickrAPIKey, text];
	
	// Create NSURL string from formatted string
	NSURL *url = [NSURL URLWithString:urlString];
	
	// Setup and start async download
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection release];
	[request release];    
}

- (id)init
{
	if (self = [super init])
	{
		self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
		
		// Create table view
		theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 240, 320, 220)];
		[theTableView setDelegate:self];
		[theTableView setDataSource:self];
		[theTableView setRowHeight:80];
		[self.view addSubview:theTableView];
		[theTableView setBackgroundColor:[UIColor grayColor]];
		[theTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
				
		// Initialize our arrays
		photoTitles = [[NSMutableArray alloc] init];
		photoSmallImageData = [[NSMutableArray alloc] init];
		photoURLsLargeImage = [[NSMutableArray alloc] init];
								
		// Create textfield for the search text
		searchTextField = [[[UITextField alloc] initWithFrame:CGRectMake(55, 100, 210, 40)] retain];
		[searchTextField setBorderStyle:UITextBorderStyleRoundedRect];
		searchTextField.placeholder = @"search";
		searchTextField.returnKeyType = UIReturnKeyDone;
		searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		searchTextField.delegate = self;
		[searchTextField becomeFirstResponder];
		[self.view addSubview:searchTextField];
		[searchTextField release];
		
		// Create activity indicator
		activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(280, 110, 15, 15)];
		activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
											  UIViewAutoresizingFlexibleRightMargin |
											  UIViewAutoresizingFlexibleTopMargin |
											  UIViewAutoresizingFlexibleBottomMargin);
		[activityIndicator sizeToFit];
		activityIndicator.hidesWhenStopped = YES; 
		[self.view addSubview:activityIndicator];
	}
	return self;
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	// Remove any content from a previous search
	[photoTitles removeAllObjects];
	[photoSmallImageData removeAllObjects];
	[photoURLsLargeImage removeAllObjects];
			
	// Begin the call to Flickr
	[self searchFlickrPhotos:searchTextField.text];
	
	// Start the busy indicator
	[activityIndicator startAnimating];
	
	return YES;
}

- (void)viewDidLoad 
{
	[super viewDidLoad];	
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int retVal = [photoTitles count];
    return retVal;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cachedCell"];
	if (cell == nil)
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cachedCell"] autorelease];
	
	
#if __IPHONE_3_0
	cell.textLabel.text = [photoTitles objectAtIndex:indexPath.row];
	cell.textLabel.font = [UIFont systemFontOfSize:13.0];
#else
	cell.text = [photoTitles objectAtIndex:indexPath.row];
	cell.font = [UIFont systemFontOfSize:13.0];
#endif
		
	NSData *imageData = [photoSmallImageData objectAtIndex:indexPath.row];
	
#if __IPHONE_3_0
	cell.imageView.image = [UIImage imageWithData:imageData];
#else
	cell.image = [UIImage imageWithData:imageData];
#endif
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	searchTextField.hidden = YES;
	
	// If we've created this VC before...
	if (fullImageViewController != nil)
	{
		// Slide this view off screen
		CGRect frame = fullImageViewController.frame;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.45];
		
		// Off screen location
		frame.origin.x = -320;
		fullImageViewController.frame = frame;
		
		[UIView commitAnimations];
	}
	
	[self performSelector:@selector(showZoomedImage:) withObject:indexPath afterDelay:0.1];
}


- (void)showZoomedImage:(NSIndexPath *)indexPath
{
	// Remove from view (and release)
	if ([fullImageViewController superview])
		[fullImageViewController removeFromSuperview];
	
	fullImageViewController = [[ZoomedImageView alloc] initWithURL:[photoURLsLargeImage objectAtIndex:indexPath.row]];
	
	[self.view addSubview:fullImageViewController];
	
    // Slide this view off screen
	CGRect frame = fullImageViewController.frame;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.45];
	
	// Slide the image to its new location (onscreen)
	frame.origin.x = 0;
	fullImageViewController.frame = frame;
	
	[UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	// Show enable the search textfield again
	searchTextField.hidden = NO;	
}


- (void)dealloc 
{
	[searchTextField release];
	[theTableView release];
	[photoTitles release];
	[photoSmallImageData release];
	[photoURLsLargeImage release];
	[activityIndicator release];
	
	[super dealloc];
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


@end
