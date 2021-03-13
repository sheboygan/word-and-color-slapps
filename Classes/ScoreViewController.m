    //
//  ScoreViewController.m
//  Game
//
//  Created by sandra on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreViewController.h"


@implementation ScoreViewController

@synthesize sBean, _vType;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	tfView.text = sBean._score;
    lbWordsMissing.text = NSLocalizedString(@"Words missed", nil);
	lbScore.text = [NSString stringWithFormat:@"%d / %d = %d%%", sBean._right, sBean._total, sBean._right*100/sBean._total];
    
	if(_vType == 2)  //farm pack
	{
		bgImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"farm background" ofType:@"png"]];
	}else if(_vType == 1)  //vehicle pack
	{
		bgImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vehicleBg" ofType:@"png"]];
	}else {
		bgImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bgPlay" ofType:@"png"]];
	}
	
	[super viewDidLoad];
}





@end
