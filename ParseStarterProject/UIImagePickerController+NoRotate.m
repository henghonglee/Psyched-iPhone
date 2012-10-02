//
//  UIImagePickerController+NoRotate.m
//  PsychedApp
//
//  Created by HengHong Lee on 19/3/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import "UIImagePickerController+NoRotate.h"

@implementation UIImagePickerController (NoRotate)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end