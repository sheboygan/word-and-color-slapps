    //
//  ChooseCtoryViewController.m
//  Game
//
//  Created by sandra on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SelectCategoryVC.h"
#import "CateBean.h"
#import "GameAppDelegate.h"

@implementation SelectCategoryVC
@synthesize butDropbox;

@synthesize folderID;- (IBAction)dropboxPressed:(id)sender {
    GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"b_empty == NO"];
    NSMutableArray *mut = [NSMutableArray array];
    [mut addObjectsFromArray:[array_Cate filteredArrayUsingPredicate:pre]];
    app.localFiles = mut;
    app.currentCategoryId = folderID;

    [app openDropboxBrowser];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    lbTitle.text = NSLocalizedString(@"Choose Category", nil);
	array_Cate = [[NSMutableArray alloc] init];
	highImages = [[NSMutableArray alloc] initWithObjects:@"dark grey h.png", @"green h.png", @"dark green h.png",@"correct lighter blue h.png", @"dark blue h.png",
				  @"purple h.png", @"bright purple h.png", @"purple pink.png", @"brighter red h.png", @"bright orange h.png", nil];
	/*lb1.textColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:112.0/255.0 alpha:1];
	lb2.textColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:112.0/255.0 alpha:1];
	lb3.textColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:112.0/255.0 alpha:1];
	lb4.textColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:112.0/255.0 alpha:1];
	lb5.textColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:112.0/255.0 alpha:1];*/
    if (folderID  == 100) {
        [butDropbox removeFromSuperview];
    }
	[self getDatafromDB];
	[self initUI];
	
    [super viewDidLoad];
}

-(void)refreshContent {
	[self getDatafromDB];
	[self initUI];

}





- (void)viewDidUnload {
    [self setButDropbox:nil];
    [super viewDidUnload];
}



-(IBAction)clickCategory: (id)sender
{
	CateBean *cBean = array_Cate[([sender tag]-1)];
	SelectImagesFromFolderVC *selImage = [[SelectImagesFromFolderVC alloc] init];
	selImage.cateID = cBean.cateID;
	[self.navigationController pushViewController:selImage animated:YES];
}



-(void)getDatafromDB
{
	if([array_Cate count] != 0)
	{
		[array_Cate removeAllObjects];
	}
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql = "select id, name from category where parentId=? ORDER BY id ASC";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			sqlite3_bind_int(statements, 1, folderID);
			while(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				
				CateBean *cBean = [[CateBean alloc] init];
                cBean.cateID = sqlite3_column_int(statements, 0);
				cBean.name = @((char *)sqlite3_column_text(statements, 1));
				cBean.b_empty = NO;
                [array_Cate addObject:cBean];		
			}
			sqlite3_finalize(statements);
		}	
	}
	NSInteger count = 10;
	for (NSInteger i = [array_Cate count]; i<count; i++) {
		CateBean *cateBean = [[CateBean alloc] init];
		cateBean.name = @"(empty)";
		cateBean.b_empty = YES;
		[array_Cate addObject:cateBean];
	}
}

-(void)initUI
{
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	
	//get default category first
	int categoryID = 1;
	if (statements == nil) {
		char *sql = "select cateID from setting";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			if(sqlite3_step(statements) == SQLITE_ROW) {
			    categoryID = sqlite3_column_int(statements, 0);
			}
			sqlite3_finalize(statements);
			statements = nil;
		}	
	}	
	
	//NSArray *arryLevels = [[NSArray alloc] initWithObjects:lb1, lb2, lb3, lb4, lb5, nil];
	NSArray *arryButtons = [[NSArray alloc] initWithObjects:bt1, bt2, bt3, bt4, bt5, bt6, bt7, bt8, bt9, bt10, nil];
	for (int i=0; i<10; i++) {
		CateBean *cBean = array_Cate[i];
		//UILabel *lb = [arryLevels objectAtIndex:i];
		UIButton *bt = arryButtons[i];
		[bt setTitle:NSLocalizedString(cBean.name, nil) forState:UIControlStateNormal];
		[bt setTitle:NSLocalizedString(cBean.name, nil) forState:UIControlStateHighlighted];
		[bt setTitle:NSLocalizedString(cBean.name, nil) forState:UIControlStateSelected];
		[bt setTitle:NSLocalizedString(cBean.name, nil) forState:UIControlStateDisabled];
		//lb.text = cBean.name;
		
        bt.enabled = !(cBean.b_empty);
		bt.alpha = (bt.enabled)?1:0.4;
        
		if (cBean.cateID == categoryID) {
			UIButton *bt = arryButtons[i];
			[bt setBackgroundImage:[UIImage imageNamed:highImages[([bt tag]-1)]] forState:UIControlStateNormal];
			[bt setBackgroundImage:[UIImage imageNamed:highImages[([bt tag]-1)]] forState:UIControlStateHighlighted];
			[bt setBackgroundImage:[UIImage imageNamed:highImages[([bt tag]-1)]] forState:UIControlStateSelected];
		}
	}
	
	if (folderID == 100) {
		for (int j=2; j<10; j++) {
			UIButton *bt = arryButtons[j];
			bt.hidden = YES;
		}
	}
	//[arryLevels release];
}

#pragma mark SelImageViewControllerDelegate

-(void)didChooseImage
{
}

@end
