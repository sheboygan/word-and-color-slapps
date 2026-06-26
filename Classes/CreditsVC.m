    //
//  CreditViewController.m
//  Game
//
//  Created by sandra on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CreditsVC.h"


@implementation CreditsVC


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



-(IBAction)back:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)visit:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://zorten.com"] options: @{} completionHandler:NULL];
}

-(IBAction)Website: (id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://zorten.com"] options: @{} completionHandler:NULL];
}

-(IBAction)Gamesite: (id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://zorten.com"] options: @{} completionHandler:NULL];
}

@end
