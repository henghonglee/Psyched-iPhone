//
//  RouteLocationViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 19/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RouteLocationViewController.h"



@implementation RouteLocationViewController

@synthesize locationText;
@synthesize locationTextField;
@synthesize locationTable;
@synthesize delegate;
@synthesize locationArray;
@synthesize gpLoc;
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
    self.navigationItem.title = @"Add Location";
    locationArray = [[NSMutableArray alloc]init ];
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemDone target:self action:@selector(dismissView:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release]; 
    PFQuery* locationQuery = [PFQuery queryWithClassName:@"Route"];
    [locationQuery whereKey:@"routelocation" nearGeoPoint:gpLoc withinKilometers:2.0];
    [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            [locationArray removeAllObjects];
        for (PFObject* route in objects) {
            NSLog(@"route location = %@", [route objectForKey:@"location"]);
            if (![locationArray containsObject:[route objectForKey:@"location"]]){
                [locationArray addObject:[route objectForKey:@"location"]];
            }
            
            
        } 
     [locationTable reloadData];
        }
    }];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)dismissView:(id)sender{
    [self.delegate LocationDidReturnWithText:locationTextField.text];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    [self setLocationTextField:nil];
    [self setLocationTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyIdentifier"]; 
    }
    // Set up the cell
    if ([locationArray count]) {
        
        cell.imageView.image = [UIImage imageNamed:@"locationpin.png"];
        cell.textLabel.text = [locationArray objectAtIndex:indexPath.row];

    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    locationTextField.text = ((UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath]).textLabel.text ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
    return [locationArray count];    
    }
    return 0;
}

- (void)dealloc {
    [locationArray release];
    [locationTextField release];
    [locationTable release];
    [super dealloc];
}
@end
