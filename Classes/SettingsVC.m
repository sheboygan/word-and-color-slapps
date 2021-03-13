    //
//  SettingViewController.m
//  Game
//
//  Created by Sunny on 11/4/10.
//  Copyright 2010 CoSoft. All rights reserved.
//

#import "SettingsVC.h"
#import "FoldersListVC.h"
#import "GameAppDelegate.h"
#import "CreditsVC.h"
#import "Reachability.h"
#import "IAPManager.h"

@implementation SettingsVC

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

	visualType = VisualTypeBasic;

	tbView.hidden = YES;
    butRestore.alpha = 0;
    
    lbTurns.text = NSLocalizedString(@"Number of Turns", nil);
    lbMode.text = NSLocalizedString(@"Practice Mode", nil);
    lbQPromote.text = NSLocalizedString(@"Question Prompt", nil);
    lbIncorrect.text = NSLocalizedString(@"Incorrect Response", nil);
    lbCorrect.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Correct Response", nil), NSLocalizedString(@"Sounds", nil)];
    lbVisual.text = NSLocalizedString(@"Visuals", nil);
    lbTheme.text = NSLocalizedString(@"Choose Theme/Visuals", nil);
	
	btVisual.layer.cornerRadius = 5.0;
	[self initUI];
	
    if ([SharedObjects objects].isColorSlapps)
    {
        [segTurns removeSegmentAtIndex: segTurns.numberOfSegments-1 animated: NO];
        [btEdit removeFromSuperview];
        self.preview = [[UIImageView alloc] initWithFrame: self.view.bounds];
        self.preview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
        self.actView.hidesWhenStopped = YES;
    }
 
    self.content = @[NSLocalizedString(@"Basic", nil),
                     NSLocalizedString(@"Vehicles", nil),
                     NSLocalizedString(@"Farm", nil)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    if ([SharedObjects objects].isPro || ![SharedObjects objects].isColorSlapps) {
        butRestore.hidden = YES;
    }
    
    if (isFarmPurchased && isVehiclesPurchased) {
        butRestore.hidden = YES;
    }
}

-(IBAction)edit: (id)sender
{
	FoldersListVC *editFolderViewController = [[FoldersListVC alloc] init];
	[self.navigationController pushViewController:editFolderViewController animated:YES];
}


-(IBAction)info:(id)sender
{
	CreditsVC *creditViewController = [[CreditsVC alloc] init];
	[self.navigationController pushViewController:creditViewController animated:YES];
}

-(IBAction)changeTurns: (id)sender
{
	UISegmentedControl *seg = (UISegmentedControl *)sender;
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "update setting set turns=? where id=?";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 2, 1);
		if (seg.selectedSegmentIndex == 0) {
			sqlite3_bind_int(statements, 1, 5);
		}else if (seg.selectedSegmentIndex == 1) {
			sqlite3_bind_int(statements, 1, 10);
		}else {
			sqlite3_bind_int(statements, 1, 15);
		}

    }
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to update the database with message '%s'.", sqlite3_errmsg(db));
    }    	
	sqlite3_finalize(statements);
	statements = nil;	
}

-(IBAction)changeAdvance: (UISwitch*)sender
{
	UISwitch *switch_Ad = (UISwitch *)sender;
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "update setting set advance=? where id=?";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 2, 1);
		if (switch_Ad.on) {
			sqlite3_bind_int(statements, 1, 1);
		}else {
			sqlite3_bind_int(statements, 1, 0);
		}
    }
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to update the database with message '%s'.", sqlite3_errmsg(db));
    }    	
	sqlite3_finalize(statements);
	statements = nil;	
}

-(IBAction)changePromote: (UISwitch*) sender
{
	//NSLog(@"Change Promote");
	UISwitch *switch_Ad = (UISwitch *)sender;
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "update setting set qPromote=? where id=?";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 2, 1);
		if (switch_Ad.on) {
			sqlite3_bind_int(statements, 1, 1);
		}else {
			sqlite3_bind_int(statements, 1, 0);
		}
    }
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to update the database with message '%s'.", sqlite3_errmsg(db));
    }    	
	sqlite3_finalize(statements);
	statements = nil;	
}

-(IBAction)changeSounds: (UISwitch*)sender
{
	//NSLog(@"Change Sounds");
	UISwitch *switch_Ad = (UISwitch *)sender;
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "update setting set sounds=? where id=?";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 2, 1);
		if (switch_Ad.on) {
			sqlite3_bind_int(statements, 1, 1);
		}else {
			sqlite3_bind_int(statements, 1, 0);
		}
    }
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to update the database with message '%s'.", sqlite3_errmsg(db));
    }    	
	sqlite3_finalize(statements);
	statements = nil;
}

-(IBAction)changeVisual: (UISwitch*)sender
{
	//NSLog(@"Change Visual");
	UISwitch *switch_Ad = (UISwitch *)sender;
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "update setting set visuals=? where id=?";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 2, 1);
		if (switch_Ad.on) {
			sqlite3_bind_int(statements, 1, 1);
		}else {
			sqlite3_bind_int(statements, 1, 0);
		}
    }
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to update the database with message '%s'.", sqlite3_errmsg(db));
    }    	
	sqlite3_finalize(statements);
	statements = nil;
}

-(IBAction)changeScore: (UISwitch*)sender
{
	UISwitch *switch_Ad = (UISwitch *)sender;
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "update setting set score=? where id=?";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 2, 1);
		if (switch_Ad.on) {
			sqlite3_bind_int(statements, 1, 1);
		}else {
			sqlite3_bind_int(statements, 1, 0);
		}
    }
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to update the database with message '%s'.", sqlite3_errmsg(db));
    }    	
	sqlite3_finalize(statements);
	statements = nil;
}

-(IBAction)changeIncorrect: (UISwitch*)sender
{
	UISwitch *switch_Ad = (UISwitch *)sender;
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "update setting set incorrect=? where id=?";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 2, 1);
		if (switch_Ad.on) {
			sqlite3_bind_int(statements, 1, 1);
		}else {
			sqlite3_bind_int(statements, 1, 0);
		}
    }
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to update the database with message '%s'.", sqlite3_errmsg(db));
    }    	
	sqlite3_finalize(statements);
	statements = nil;
}


-(IBAction)share: (id)sender
{
    if (![MFMailComposeViewController canSendMail]) {
        [[UIApplication sharedApplication] showAlertWithTitle: nil message: @"Unable to open Mail app, setup your account first"];
        return;
    }

	MFMailComposeViewController*picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Share Word SLapPs"];
	NSString *htmlBody = @"<!DOCTYPE html><!--STATUS OK--><html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\"><title></title><style>body{margin:0;padding:6px 0 0 0;background-color:#000;color:#fff;font-family:arial;FONT-SIZE:14px;}</style><body style='-webkit-text-size-adjust:none'>";
	NSString *emailBody = @"I thought you might like <a href='http://itunes.apple.com/us/app/word-slapps/id413888079?at=10lb2P&ct=Zorten'>Word SLapPs</a> to use on your iPad!<br/>";
    
    if ([SharedObjects objects].isColorSlapps)
    {
    	[picker setSubject:@"Share Color SLapPs"];
        htmlBody = @"<!DOCTYPE html><!--STATUS OK--><html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\"><title></title><style>body{margin:0;padding:6px 0 0 0;background-color:#fff;color:#000;font-family:arial;FONT-SIZE:14px;}</style><body style='-webkit-text-size-adjust:none'>";
        emailBody = @"I thought you might like <a href='https://itunes.apple.com/us/app/color-slapps/id416365360?at=10lb2P&ct=Zorten'>Color SLapPs</a> to use on your iPad!<br/>";
    }
	htmlBody = [NSString stringWithFormat:@"%@%@</body></html>",htmlBody,emailBody];
	[picker setMessageBody:htmlBody isHTML:YES];
	
    [self presentViewController: picker animated: YES completion: nil];
	
}

-(void)initUI
{
	int turns = 5;;
	BOOL b_Advance = YES;
	BOOL b_qPromote = YES;
	BOOL b_Sounds = YES;
	BOOL b_Visuals = YES;
	BOOL b_InCorrect = YES;
	
	//get settings from DB
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql = "select turns, advance,qPromote, sounds,visuals, incorrect,visualType,farmPurchased,vehiclePurchased from setting";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			//sqlite3_bind_int(statements, 1, categoryID);
			if(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				
                turns = sqlite3_column_int(statements, 0);
				b_Advance = sqlite3_column_int(statements, 1);
				b_qPromote = sqlite3_column_int(statements, 2);
                b_Sounds = sqlite3_column_int(statements, 3);
                b_Visuals = sqlite3_column_int(statements, 4);		
				b_InCorrect = sqlite3_column_int(statements, 5);
				visualType = sqlite3_column_int(statements, 6);
				isFarmPurchased = sqlite3_column_int(statements, 7);
				isVehiclesPurchased = sqlite3_column_int(statements, 8);
			}
			sqlite3_finalize(statements);
		}	
	}
	
	//init UI
	if (turns == 5) {
		segTurns.selectedSegmentIndex = 0;
	}else if (turns == 10){
		segTurns.selectedSegmentIndex = 1;
	}else {
		segTurns.selectedSegmentIndex = 2;
	}

	swAdvance.on = b_Advance;
	swPromote.on = b_qPromote;
	swSounds.on = b_Sounds;
	swVisual.on = b_Visuals;
	swIncorrect.on = b_InCorrect;

    NSString* curThemeName = @"Basic";
    if (visualType == VisualTypeVehicles)
        curThemeName = @"Vehicles";
    if (visualType == VisualTypeFarm)
        curThemeName = @"Farm";
    
	[btVisual setTitle: NSLocalizedString(curThemeName, nil) forState:UIControlStateNormal];
	[self initBackground:visualType];
}

-(void)initBackground: (int)vType
{
	if(vType == 2)  //farm pack
	{
		[btInfo setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
		[btInfo setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateHighlighted];
		lbTurns.frame = CGRectMake(152+86, 146, 232, 40);
		segTurns.frame = CGRectMake(414+86, 144, 139, 44);
		lbMode.frame = CGRectMake(152+86, 209, 189, 38);
		swAdvance.frame = CGRectMake(414+86, 214, 94, 27);
		lbQPromote.frame = CGRectMake(152+86, 268, 216, 38);
		swPromote.frame = CGRectMake(414+86, 273, 94, 27);
		lbIncorrect.frame = CGRectMake(152+86, 325, 246, 38);
		swIncorrect.frame = CGRectMake(414+86, 330, 94, 27);
		lbCorrect.frame = CGRectMake(152+86, 380, 330, 45);
		swSounds.frame = CGRectMake(509+86, 389, 94, 27);
		lbVisual.frame = CGRectMake(392+86, 437, 90, 38);
		swVisual.frame = CGRectMake(509+86, 443, 94, 27);
		lbTheme.frame = CGRectMake(152+86, 496, 282, 38);
		btVisual.frame = CGRectMake(509+86, 497, 94, 37);
		tbView.frame = CGRectMake(509+86, 535, 248, 162);
		
		btEdit.frame = CGRectMake(640, 46, 366, 297);
		
		btTellFriend.frame = CGRectMake(718, 577, 252, 175);
		
		lbTurns.textColor = [UIColor blackColor];
		lbMode.textColor = [UIColor blackColor];
		lbQPromote.textColor = [UIColor blackColor];
		lbIncorrect.textColor = [UIColor blackColor];
		lbCorrect.textColor = [UIColor blackColor];
		lbVisual.textColor = [UIColor blackColor];
		lbTheme.textColor = [UIColor blackColor];
		
		mainBgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"farmsettingsBg" ofType:@"png"]];
		[btEdit setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Edit-addfarm" ofType:@"png"]] forState:UIControlStateNormal];
		[btEdit setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Edit-addfarm" ofType:@"png"]] forState:UIControlStateSelected];
		[btEdit setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Edit-addfarm" ofType:@"png"]] forState:UIControlStateHighlighted];
		[btTellFriend setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Tell a friend_Farm" ofType:@"png"]] forState:UIControlStateNormal];
		[btTellFriend setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Tell a friend_Farm" ofType:@"png"]] forState:UIControlStateSelected];
		[btTellFriend setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Tell a friend_Farm" ofType:@"png"]] forState:UIControlStateHighlighted];
	}else if (vType == 1)  {  //Vehicle pack
		[btInfo setImage:[UIImage imageNamed:@"vehicles-ibt.png"] forState:UIControlStateNormal];
		[btInfo setImage:[UIImage imageNamed:@"vehicles-ibt.png"] forState:UIControlStateHighlighted];
		lbTurns.frame = CGRectMake(152, 146, 232, 40);
		segTurns.frame = CGRectMake(414, 144, 139, 44);
		lbMode.frame = CGRectMake(152, 209, 189, 38);
		swAdvance.frame = CGRectMake(414, 214, 94, 27);
		lbQPromote.frame = CGRectMake(152, 268, 216, 38);
		swPromote.frame = CGRectMake(414, 273, 94, 27);
		lbIncorrect.frame = CGRectMake(152, 325, 246, 38);
		swIncorrect.frame = CGRectMake(414, 330, 94, 27);
		lbCorrect.frame = CGRectMake(152, 380, 330, 45);
		swSounds.frame = CGRectMake(509, 389, 94, 27);
		lbVisual.frame = CGRectMake(392, 437, 90, 38);
		swVisual.frame = CGRectMake(509, 443, 94, 27);
		lbTheme.frame = CGRectMake(152, 496, 282, 38);
		btVisual.frame = CGRectMake(509, 497, 94, 37);
		tbView.frame = CGRectMake(509, 535, 248, 162);
		
		btEdit.frame = CGRectMake(743, 125, 183, 158);
		
		btTellFriend.frame = CGRectMake(765, 482, 232, 266);
		
		lbTurns.textColor = [UIColor whiteColor];
		lbMode.textColor = [UIColor whiteColor];
		lbQPromote.textColor = [UIColor whiteColor];
		lbIncorrect.textColor = [UIColor whiteColor];
		lbCorrect.textColor = [UIColor whiteColor];
		lbVisual.textColor = [UIColor whiteColor];
		lbTheme.textColor = [UIColor whiteColor];
		
		mainBgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vehicleBg" ofType:@"png"]];
		[btEdit setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vehicles editadd" ofType:@"png"]] forState:UIControlStateNormal];
		[btEdit setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vehicles editadd" ofType:@"png"]] forState:UIControlStateSelected];
		[btEdit setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vehicles editadd" ofType:@"png"]] forState:UIControlStateHighlighted];
		[btTellFriend setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Vehicles Tellfriend" ofType:@"png"]] forState:UIControlStateNormal];
		[btTellFriend setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Vehicles Tellfriend" ofType:@"png"]] forState:UIControlStateSelected];
		[btTellFriend setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Vehicles Tellfriend" ofType:@"png"]] forState:UIControlStateHighlighted];
	}else {
		[btInfo setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
		[btInfo setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateHighlighted];
		lbTurns.frame = CGRectMake(152, 146, 232, 40);
		segTurns.frame = CGRectMake(414, 144, 139, 44);
		lbMode.frame = CGRectMake(152, 209, 189, 38);
		swAdvance.frame = CGRectMake(414, 214, 94, 27);
		lbQPromote.frame = CGRectMake(152, 268, 216, 38);
		swPromote.frame = CGRectMake(414, 273, 94, 27);
		lbIncorrect.frame = CGRectMake(152, 325, 246, 38);
		swIncorrect.frame = CGRectMake(414, 330, 94, 27);
		lbCorrect.frame = CGRectMake(152, 380, 330, 45);
		swSounds.frame = CGRectMake(509, 389, 94, 27);
		lbVisual.frame = CGRectMake(392, 437, 90, 38);
		swVisual.frame = CGRectMake(509, 443, 94, 27);
		lbTheme.frame = CGRectMake(152, 496, 282, 38);
		btVisual.frame = CGRectMake(509, 497, 94, 37);
		tbView.frame = CGRectMake(509, 535, 248, 162);
	
		btEdit.frame = CGRectMake(698, 114, 242, 139);
		
		btTellFriend.frame = CGRectMake(669, 490, 328, 290);
		
		lbTurns.textColor = [UIColor blackColor];
		lbMode.textColor = [UIColor blackColor];
		lbQPromote.textColor = [UIColor blackColor];
		lbIncorrect.textColor = [UIColor blackColor];
		lbCorrect.textColor = [UIColor blackColor];
		lbVisual.textColor = [UIColor blackColor];
		lbTheme.textColor = [UIColor colorWithRed:163/255.0 green:10/255.0 blue:58/255.0 alpha:1.0];
		
		mainBgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Grass background" ofType:@"png"]];
		[btEdit setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Edit add Content button" ofType:@"png"]] forState:UIControlStateNormal];
		[btEdit setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Edit add Content button" ofType:@"png"]] forState:UIControlStateSelected];
		[btEdit setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Edit add Content button" ofType:@"png"]] forState:UIControlStateHighlighted];
		[btTellFriend setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tell a friend" ofType:@"png"]] forState:UIControlStateNormal];
		[btTellFriend setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tell a friend" ofType:@"png"]] forState:UIControlStateSelected];
		[btTellFriend setImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tell a friend" ofType:@"png"]] forState:UIControlStateHighlighted];
	}
}

-(IBAction)visualList: (id)sender
{
    butRestore.alpha = 1;
	tbView.hidden = NO;
	[tbView reloadData];
}

-(void)saveType: (NSInteger)vsulType
{
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "update setting set visualType=? where id=?";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 2, 1);
		sqlite3_bind_int(statements, 1, (int)vsulType);
    }
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to update the database with message '%s'.", sqlite3_errmsg(db));
    }    	
	visualType = vsulType;
	
	sqlite3_finalize(statements);
	statements = nil;
}

- (IBAction)onRestore:(id)sender {
    [[IAPManager sharedIAPManager] restorePurchasesWithCompletion:^{
        if (!isFarmPurchased) {
            if ([[IAPManager sharedIAPManager] hasPurchased: @"com.slapps.color.farm"]) {
                [self writebuytoDB: VisualTypeFarm];
            }
        }
        if (!isVehiclesPurchased) {
            if ([[IAPManager sharedIAPManager] hasPurchased: @"com.slapps.color.vehicles"]) {
                [self writebuytoDB: isVehiclesPurchased];
            }
        }
        [self viewWillAppear: YES];
    }];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark UITableView

-(NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger) section
{
	return self.content.count;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath: indexPath animated: YES];


    if (![SharedObjects objects].isPro)
    {
        if (indexPath.row == 0) {
            tbView.hidden = YES;
            butRestore.alpha = 0;
            return;
        }
        [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Word SLapPS"
                                                             message: @"Sorry, only default theme is available in lite version."
                                                         actionTitle: @"Buy Full" onCompletion:^{
                                                             [appDelegate presentAppStoreFullVersion];
                                                         }];
        return;
    }

    if ([SharedObjects objects].isColorSlapps)
    {
        if (indexPath.row == VisualTypeFarm && !isFarmPurchased)
        {
            [self performPurchase: indexPath.row];
            return;
        }
        if (indexPath.row == VisualTypeVehicles && !isVehiclesPurchased)
        {
            [self performPurchase: indexPath.row];
            return;
        }
    }
    
    [self saveType: indexPath.row];
    [self initBackground: (int)indexPath.row];
    
    [btVisual setTitle: self.content[indexPath.row] forState: UIControlStateNormal];
	tbView.hidden = YES;
    butRestore.alpha = 0;
    
}

-(UITableViewCell *) tableView:(UITableView *) tv cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"Marker Felt" size:20.0];
        
    }
    cell.textLabel.text = self.content[indexPath.row];
    
	if (indexPath.row == visualType)
    {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
	return cell;
}

- (void) performPurchase: (VisualType) type
{
    NSString* message = @"Do you want to buy the Vehicles pack?\nIMPORTANT:  Please wait 20-30 seconds after pressing Upgrade button for purchase to complete.";
    NSString* previewImageName = @"Vehicle purchase";
    NSString* inappId = @"com.slapps.color.vehicles";
    
    if (type == VisualTypeFarm)
    {
        message = @"Do you want to buy the Farm pack?\nIMPORTANT:  Please wait 20-30 seconds after pressing Upgrade button for purchase to complete.";
        previewImageName = @"Farm purchase";
        inappId = @"com.slapps.color.farm";
    }
    
    self.preview.image = [UIImage imageNamed: previewImageName];
    [self.view addSubview: self.preview];
    self.actView.center = self.view.center;
    [self.view addSubview: self.actView];
    [self.actView startAnimating];
    
    
    [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Confirm"
                                                         message: message
                                                     actionTitle: @"OK" onCompletion:^{
                                                         [[IAPManager sharedIAPManager] purchaseProductForId: inappId
                                                                                                  completion:^(SKPaymentTransaction *transaction) {
                                                                                                      [self.preview removeFromSuperview];
                                                                                                      [self.actView stopAnimating];
                                                                                                      
                                                                                                      [self writebuytoDB: type];
                                                                                                      [self saveType: type];
                                                                                                      [self initBackground:visualType];
                                                                                                      [btVisual setTitle: self.content[visualType] forState: UIControlStateNormal];
                                                                                                      tbView.hidden = YES;
                                                                                                      butRestore.alpha = 0;
                                                                                                      [self viewWillAppear: YES];
                                                                                                  } error:^(NSError *error) {
                                                                                                      [self ShowAlertMessage: error.localizedDescription
                                                                                                                  AlertTitle: @"Error"];
                                                                                                      [self.preview removeFromSuperview];
                                                                                                      [self.actView stopAnimating];
                                                                                                  }];
                                                     }
                                                        onCancel:^{
                                                            [self.preview removeFromSuperview];
                                                            [self.actView stopAnimating];
                                                        }];
}


-(void)writebuytoDB: (NSInteger)vsulType;
{
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql;
		if (vsulType == 1) {
			sql = "update setting set vehiclePurchased=? where id=?";
		}else {
			sql = "update setting set farmPurchased=? where id=?";
		}
		
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 2, 1);
		sqlite3_bind_int(statements, 1, 1);
    }
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to update the database with message '%s'.", sqlite3_errmsg(db));
    }
	
    if (vsulType == VisualTypeFarm)
        isFarmPurchased = YES;
    else
        isVehiclesPurchased = YES;
    
	sqlite3_finalize(statements);
	statements = nil;
}

@end
