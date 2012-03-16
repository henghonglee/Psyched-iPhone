//
//  ImageCropper.m
//  Created by http://github.com/iosdeveloper
//

#import "ImageCropper.h"

@implementation ImageCropper

@synthesize scrollView, imageView;
@synthesize delegate;

- (id)initWithImage:(UIImage *)image {
	self = [super init];
	
	if (self) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
		
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0, 320.0, 460.0)];
		[scrollView setBackgroundColor:[UIColor blackColor]];
		[scrollView setDelegate:self];
		[scrollView setShowsHorizontalScrollIndicator:NO];
		[scrollView setShowsVerticalScrollIndicator:NO];
		[scrollView setMaximumZoomScale:2.0];
		scrollView.contentSize = CGSizeMake(320, 620);
		imageView = [[UIImageView alloc] initWithImage:image];
		
		CGRect rect;
		rect.size.width = image.size.width;
		rect.size.height = image.size.height;
		
		[imageView setFrame:rect];
		
		[scrollView setContentSize:[imageView frame].size];
		[scrollView setMinimumZoomScale:[scrollView frame].size.width / [imageView frame].size.width];
		[scrollView setZoomScale:[scrollView minimumZoomScale]];
		[scrollView addSubview:imageView];
		
		[[self view] addSubview:scrollView];
		
		UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 420, 320.0, 44.0)];
		[navigationBar setBarStyle:UIBarStyleBlack];
		[navigationBar setTranslucent:YES];
		
		UINavigationItem *aNavigationItem = [[UINavigationItem alloc] initWithTitle:@"Move and Scale"];
		[aNavigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCropping)] autorelease]];
		[aNavigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishCropping)] autorelease]];
		
		[navigationBar setItems:[NSArray arrayWithObject:aNavigationItem]];
		
		[aNavigationItem release];
//		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 70)];
//        lineView.backgroundColor = [UIColor blackColor];
//        lineView.alpha = 0.3;
//        [self.view addSubview:lineView];
//        [lineView release];
        UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 320, self.view.bounds.size.width, 140)];
        lineView2.backgroundColor = [UIColor blackColor];
        lineView2.alpha = 0.3;
        [self.view addSubview:lineView2];
        [lineView2 release];
        
        
        
        
		[[self view] addSubview:navigationBar];
        
		[navigationBar release];
	}
	
	return self;
}

- (void)cancelCropping {
	[delegate imageCropperDidCancel:self]; 
}

- (void)finishCropping {
	float zoomScale = 1.0 / [scrollView zoomScale];
	
	CGRect rect;
    NSLog(@"zoomScale=%f",zoomScale);
    NSLog(@"[scrollView contentOffset].x  = %f",[scrollView contentOffset].x );
    NSLog(@"[scrollView contentOffset].y  = %f",[scrollView contentOffset].y);
    NSLog(@"[scrollView bounds].size.width  = %f",[scrollView bounds].size.width );
    NSLog(@"[scrollView bounds].size.height  = %f",[scrollView bounds].size.height );
    
	rect.origin.x = [scrollView contentOffset].x * zoomScale;
	rect.origin.y = [scrollView contentOffset].y* zoomScale;
	rect.size.width = 320 * zoomScale;
	rect.size.height = 320 * zoomScale;
    NSLog(@"rect = %@",NSStringFromCGRect(rect) );
	CGImageRef cr = CGImageCreateWithImageInRect([[imageView image] CGImage], rect);
	
	UIImage *cropped = [UIImage imageWithCGImage:cr];
    NSLog(@"orig size = %f,%f",[imageView image].size.width,[imageView image].size.height);
    NSLog(@"cropped.size = %f,%f",cropped.size.width,cropped.size.height);
    CGImageRelease(cr);
	
	
	
	[delegate imageCropper:self didFinishCroppingWithImage:cropped];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView;
}

- (void)dealloc {
	[imageView release];
	[scrollView release];
	
    [super dealloc];
}

@end