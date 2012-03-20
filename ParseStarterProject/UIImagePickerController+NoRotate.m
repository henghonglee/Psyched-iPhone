//
//  UIImagePickerController+NoRotate.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 19/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImagePickerController+NoRotate.h"

@implementation UIImagePickerController (NoRotate)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end