    //
//  FolderViewController.m
//  Game
//
//  Created by sandra on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectFolderVC.h"
#import "SelectCategoryVC.h"
#import "GameAppDelegate.h"
#import "CateBean.h"

@implementation SelectFolderVC


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    lbTitle.text = NSLocalizedString(@"Select one", nil);
	array_Folder = [[NSMutableArray alloc] init];
	folderImages = [[NSMutableArray alloc] initWithObjects:@"blue folder_h.png", @"good yellow folder_h.png", @"color scheme orange_h.png", @"pale purple folder_h.png",
					@"grey folder_h.png", @"red folder_h.png", @"orange folder_h.png", @"another green folder_h.png",
					@"grass green folder_h.png", @"purple folder_h.png", nil];
	[self getDatafromDB];
	[self initUI];
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



-(IBAction)chooseFolder: (id)sender
{
	SelectCategoryVC *categoryViewController = [[SelectCategoryVC alloc] init];
	CateBean *cBean = array_Folder[[sender tag]-1];
	categoryViewController.folderID = (int)cBean.cateID;
	[self.navigationController pushViewController:categoryViewController animated:YES];
}



-(void)getDatafromDB
{
	if([array_Folder count] != 0)
	{
		[array_Folder removeAllObjects];
	}
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql = "select id, name from category where parentId=? ORDER BY id ASC";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			sqlite3_bind_int(statements, 1, 0);
			while(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				
				CateBean *cBean = [[CateBean alloc] init];
                cBean.cateID = sqlite3_column_int(statements, 0);
				cBean.name = @((char *)sqlite3_column_text(statements, 1));
				cBean.b_empty = NO;
                [array_Folder addObject:cBean];		
			}
			sqlite3_finalize(statements);
		}	
	}
	NSInteger count = 10;
	for (NSInteger i = [array_Folder count]; i<count; i++) {
		CateBean *cateBean = [[CateBean alloc] init];
        cateBean.name = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"Empty",nil)];
		cateBean.b_empty = YES;
		[array_Folder addObject:cateBean];
	}
}

-(void)initUI
{
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	
	//get default category first
	int categoryID = 1;
	int folderID = 3;
	if (statements == nil) {
		//find default category ID
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
		
		//find default folder ID
		char *sql1 = "select parentId from category where id=?";
		
        if (sqlite3_prepare_v2(database, sql1, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			sqlite3_bind_int(statements, 1, categoryID);
			if(sqlite3_step(statements) == SQLITE_ROW) {
			    folderID = sqlite3_column_int(statements, 0);
			}
			sqlite3_finalize(statements);
			statements = nil;
		}
	}	
	
	NSArray *arryButtons = [[NSArray alloc] initWithObjects:bt1, bt2, bt3, bt4, bt5,bt6, bt7, bt8, bt9, bt10, nil];
	for (int j=0; j<10; j++) {
		CateBean *cBean = array_Folder[j];
		UIButton *bt = arryButtons[j];
		if ([bt tag] != 1) {
			[bt setTitle:NSLocalizedString(cBean.name,nil) forState:UIControlStateNormal];
			[bt setTitle:NSLocalizedString(cBean.name,nil) forState:UIControlStateHighlighted];
			[bt setTitle:NSLocalizedString(cBean.name,nil) forState:UIControlStateSelected];
		}
		
		if (cBean.cateID == folderID) {
			[bt setBackgroundImage:[UIImage imageNamed:folderImages[([bt tag]-1)]] forState:UIControlStateNormal];
			[bt setBackgroundImage:[UIImage imageNamed:folderImages[([bt tag]-1)]] forState:UIControlStateHighlighted];
			[bt setBackgroundImage:[UIImage imageNamed:folderImages[([bt tag]-1)]] forState:UIControlStateSelected];
		}

        bt.enabled = !(cBean.b_empty);
		bt.alpha = (bt.enabled)?1:0.4;
	}
	
}

@end
