/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "CameraImageHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

#pragma mark Show Alert Utility
void showAlert(id formatstring,...)
{
	NSString *outstring;
	va_list arglist;
	{
		if (!formatstring) return;
		va_start(arglist, formatstring);
		outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	}
	va_end(arglist);
    
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:nil message:outstring delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
	[av show];
}

#pragma mark -

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
{
	IBOutlet UIImageView *imageView;
}
@end

@implementation TestBedViewController

- (void) snap
{
	// 720x1280 image on my iPhone 4
	imageView.image = [CameraImageHelper image];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		showAlert(@"Sorry. This demo requires a camera");
	else 
	{
		// Start the capture
		[CameraImageHelper startRunning];
		
		// Snap images as needed from the session
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Snap", @selector(snap));
		
		// Live preview in the title bar
		self.navigationItem.titleView = [CameraImageHelper previewWithBounds:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
	}
}
@end

#pragma mark -

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
	UINavigationController *nav;
}
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	nav = [[UINavigationController alloc] initWithRootViewController:[[[TestBedViewController alloc] init] autorelease]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}
- (void) dealloc
{
	[nav.view removeFromSuperview];	[nav release];	[window release];	[super dealloc];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}