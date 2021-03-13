//
//  GameViewController.m
//  Game
//
//  Created by Sunny on 11/4/10.
//  Copyright CoSoft 2010. All rights reserved.
//

#import "MainMenuVC.h"
#import "SettingsVC.h"
#import "ViewFolderVC.h"
#import "RecordAudioViewController.h"
#import "SelectFolderVC.h"
#import "GameAppDelegate.h"
#import "CreditsVC.h"
#import "ScoreListViewController.h"
#import "SelectImagesFromFolderVC.h"

@implementation MainMenuVC


- (void)viewDidLoad
{
    [super viewDidLoad];

	arrayImages = [[NSMutableArray alloc] init];
	self.navigationController.navigationBar.hidden = YES;
	
	
    selectedLevel = 3;
	sqlite3 *database = [appDelegate getDatabase];
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql = "select level from setting";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			if(sqlite3_step(statements) == SQLITE_ROW) {
			    selectedLevel = sqlite3_column_int(statements, 0);
			}
			sqlite3_finalize(statements);
			statements = nil;
		}	
	}	
	
    [levelsContainer.subviews enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        [obj addTarget: self
                action: @selector(levelPressed:)
      forControlEvents: UIControlEventTouchUpInside];
    }];

    
    [self initLevel];
    UIButton* selectedLevelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    selectedLevelButton.tag = selectedLevel;
    [selectedLevelButton setTitle: @"fake" forState: UIControlStateNormal];
    [self levelPressed: selectedLevelButton];
    
    
    
    if ([SharedObjects objects].isColorSlapps)
    {
        [btResults removeFromSuperview];
        
        CGRect r = levelsContainer.frame;
        r.origin.x += r.size.width/4.0f;
        r.size.width /= 2.0f;
        levelsContainer.frame = r;
    }
    else
    {
        [btBuyFull removeFromSuperview];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
	[self initLevel];
}


#pragma mark - Actions

-(IBAction)settingsPressed: (id)sender
{
	SettingsVC* s = [[SettingsVC alloc] init];
	[self.navigationController pushViewController: s animated:YES];
}

-(IBAction)info:(id)sender
{
	CreditsVC* c = [[CreditsVC alloc] init];
	[self.navigationController pushViewController: c animated:YES];
}

-(IBAction)category: (id)sender
{
    if ([SharedObjects objects].isColorSlapps)
    {
        SelectImagesFromFolderVC *selImage = [[SelectImagesFromFolderVC alloc] init];
        selImage.cateID = 2;
        [self.navigationController pushViewController:selImage animated:YES];
        return;
    }
	SelectFolderVC* f = [[SelectFolderVC alloc] init];
	[self.navigationController pushViewController: f animated:YES];
}

-(IBAction)viewResult: (id)sender
{
	ScoreListViewController* res = [[ScoreListViewController alloc] init];
	[self.navigationController pushViewController: res animated:YES];
}

- (IBAction)buyFullPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/word-slapps/id413888079?at=10lb2P&ct=Zorten"] options: @{} completionHandler:NULL];
}

-(IBAction)levelPressed:(UIButton*)sender
{

    if (![SharedObjects objects].isPro && sender.tag > 3)
    {
        [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Word SLapPS"
                                                             message: @"This level is not available in the lite version"
                                                         actionTitle: @"Buy Full" onCompletion:^{
                                                             [appDelegate presentAppStoreFullVersion];
                                                         }];
        return;
    }
    
    if (sender.tag > arrayImages.count && ![SharedObjects objects].isPro)
    {
        if (![sender.titleLabel.text hasPrefix: @"fake"])
        {
            [self ShowAlertMessage: @"Please choose additional images for the category you selected!"
                        AlertTitle: @"Warning!"];
            failedToSetLevel = YES;
            return;
        }
        else
        {
            sender.tag = arrayImages.count;
        }
    }
    
    selectedLevel = (int)[sender tag];
    
    [levelsContainer.subviews enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        obj.selected = (sender.tag == obj.tag);
    }];
	
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "update setting set level=? where id=?";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 1, (int)[sender tag]);
		sqlite3_bind_int(statements, 2, 1);
	}
	int success = sqlite3_step(statements);
	if (success == SQLITE_ERROR) {
		NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
	}    
	sqlite3_finalize(statements);
	statements = nil;
	
}

-(IBAction)play: (id)sender
{
	if (arrayImages.count == 0)
    {
		[self ShowAlertMessage:@"Please choose images for the category you selected!" AlertTitle:@"Warning!"];
        return;
    }
    PlayVC* playViewController = [[PlayVC alloc] init];
    playViewController.level = selectedLevel;
    [self.navigationController pushViewController: playViewController animated: YES];

}

-(void)initLevel
{
	[arrayImages removeAllObjects];
	
	NSInteger categoryID = 1;
	NSInteger _visualType = 0;
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql = "select cateID, visualType from setting";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			if(sqlite3_step(statements) == SQLITE_ROW) {
			    categoryID = sqlite3_column_int(statements, 0);
				_visualType = sqlite3_column_int(statements, 1);
			}
			sqlite3_finalize(statements);
			statements = nil;
		}	
	}	
	[self initBackground:_visualType];
	
	if (statements == nil) {
		char *sql = "select selected from image WHERE category=? ORDER BY id ASC";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			sqlite3_bind_int(statements, 1, (int)categoryID);
			while(sqlite3_step(statements) == SQLITE_ROW)
            {
                int _id = sqlite3_column_int(statements, 0);
                [arrayImages addObject:[NSString stringWithFormat:@"%d", _id]];		
			}
			sqlite3_finalize(statements);
		}	
	}
    
    [arrayImages removeObject: @"0"];
	
    [levelsContainer.subviews enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        if (arrayImages.count <= obj.tag - 1)
        {
            obj.enabled = NO;
        }
        else
        {
            obj.enabled = YES;
        }
        
        if (![SharedObjects objects].isPro)
        {
            obj.alpha = (obj.tag <= LiteVersionMaxLevels)?1.0:0.7;
            obj.enabled = YES;
        }
    }];
    
    
    if (arrayImages.count < selectedLevel || failedToSetLevel)
    {
        failedToSetLevel = NO;
        UIButton* selectedLevelButton = (UIButton*)[levelsContainer viewWithTag: arrayImages.count];
        [self levelPressed: selectedLevelButton];
    }

}


-(void)initBackground: (NSInteger)_vType
{
    NSString* butInfoName = @"info";
    NSString* mainBgName = @"Grass background";
    NSString* butCategoryName = @"Categories Cloud";
    NSString* butPlayName = @"Play Sunflower";
    
    
    if ([SharedObjects objects].isColorSlapps)
    {
        butCategoryName = @"Color Cloud";
    }
    
    if (![SharedObjects objects].isPro)
    {
        btPlay.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    switch (_vType)
    {
        case 1:
            butInfoName = @"vehicles-ibt.png";
            mainBgName = @"vehicles main";
            butPlayName = @"Vehicle play";
            butCategoryName = @"Vehicles categories";
            chooseLevel.hidden = YES;
            btCategory.frame = CGRectMake(148, 122, 557, 265);
            btPlay.frame = CGRectMake(704, 264, 280, 262);
            break;
        case 2:
            mainBgName = @"farm playBg";
            butPlayName = @"Farm play";
            butCategoryName = @"farm Categories";
            chooseLevel.hidden = YES;
            btCategory.frame = CGRectMake(320, 191, 288, 84);
            btPlay.frame = CGRectMake(699, 197, 352, 492);

            break;
        default:
            chooseLevel.hidden = NO;
            btCategory.frame = CGRectMake(146, 63, 645, 351);
            btPlay.frame = CGRectMake(672, 256, 352, 492);
            break;
    }
    
    UIImage* butInfoImage = [UIImage imageNamed: butInfoName];

    [btInfo setImage:butInfoImage forState:UIControlStateNormal];
    [btInfo setImage:butInfoImage forState:UIControlStateHighlighted];
    mainBgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource: mainBgName ofType: @"png"]];

    UIImage* butCategoryImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: butCategoryName ofType: @"png"]];
    UIImage* butPlayImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: butPlayName ofType: @"png"]];
    
    [btCategory setImage: butCategoryImage forState:UIControlStateNormal];
    [btPlay setImage: butPlayImage forState:UIControlStateNormal];
}

@end
