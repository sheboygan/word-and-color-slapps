//
//  ScoreListViewController.h
//  Game
//
//  Created by sandra on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonVC.h"


@interface ScoreListViewController : CommonVC {
	IBOutlet UIImageView *bgImage;
	NSMutableArray *results;
	NSInteger _vType;   // store the type so can use the corresponding background
}

@end
