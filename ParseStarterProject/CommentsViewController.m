

#import "CommentsViewController.h"

@interface CommentsViewController ()

@end

@implementation CommentsViewController
@synthesize commentsTextView;
@synthesize delegate;
@synthesize commentsText;
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
    [commentsTextView becomeFirstResponder];
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemDone target:self action:@selector(dismissView:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];   
    
}
-(void)dismissView:(id)sender
{
    [self.delegate commentsDidReturnWithText:commentsTextView.text];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

- (void)viewDidUnload
{
    [self setCommentsTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [commentsTextView release];
    [super dealloc];
}
@end
