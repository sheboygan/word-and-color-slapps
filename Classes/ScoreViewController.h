//
//  ScoreViewController.h
//  Game
//
//  Created by sandra on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonVC.h"
#import "ScoreBean.h"

@interface ScoreViewController : CommonVC {
    IBOutlet UITextView *tfView;
	IBOutlet UILabel *lbScore;
	IBOutlet UIImageView *bgImage;
    IBOutlet UILabel *lbWordsMissing;
	NSInteger _vType;   // store the type so can use the corresponding background
	
	ScoreBean *sBean;
}

@property(nonatomic, strong) ScoreBean *sBean;
@property(nonatomic, assign) NSInteger _vType;

@end
