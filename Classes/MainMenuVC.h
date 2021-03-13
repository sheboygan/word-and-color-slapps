//
//  GameViewController.h
//  Game
//
//  Created by Sunny on 11/4/10.
//  Copyright CoSoft 2010. All rights reserved.
//

#import "CommonVC.h"
#import "PlayVC.h"

@interface MainMenuVC : CommonVC {
	IBOutlet UIImageView *mainBgView;
	IBOutlet UIImageView *chooseLevel;
	IBOutlet UIButton *btCategory;
	IBOutlet UIButton *btLevel;
	IBOutlet UIButton *btPlay;
	IBOutlet UIButton *btInfo;
	
    IBOutlet UIButton *btBuyFull;
    IBOutlet UIView *levelsContainer;
	int selectedLevel;
	NSMutableArray *arrayImages;
    
    IBOutlet UIButton *btResults;
    BOOL failedToSetLevel;
}
- (IBAction)levelPressed:(id)sender;
- (IBAction)settingsPressed: (id)sender;
- (IBAction)info:(id)sender;
- (IBAction)category: (id)sender;
- (IBAction)play: (id)sender;
- (IBAction)viewResult: (id)sender;
- (IBAction)buyFullPressed:(id)sender;

@end

