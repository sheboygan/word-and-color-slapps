    //
//  SelImageViewController.m
//  Game
//
//  Created by sandra on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SelectImagesFromFolderVC.h"
#import "CategoryBean.h"
#import "GameAppDelegate.h"


@implementation SelectImagesFromFolderVC

@synthesize cateID, delegate;
-(BOOL)isExistsFile:(NSString *)filepath{
	NSFileManager *filemanage = [NSFileManager defaultManager];
	return [filemanage fileExistsAtPath:filepath];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    lbTitle.text = NSLocalizedString(@"Choose Images", nil);
	b_selAll = NO;
	tbView.backgroundColor = [UIColor clearColor];
	imageArray = [[NSMutableArray alloc] init];
	UIBarButtonItem *_rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	self.navigationItem.rightBarButtonItem = _rightBarButtonItem;
	[self getImagesfromDB];
	if ([imageArray count] == 0) {
		btDone.enabled = NO;
		btDisAll.enabled = NO;
		btSelectAll.enabled = NO;
	}
    [super viewDidLoad];
}





- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)back:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)chooseImage: (id)sender
{
	//NSLog(@"id=%d", [sender tag]);
	CategoryBean *cBean = imageArray[[sender tag]];
	UIButton *bt = (UIButton *)sender;
	UIImage *img = [bt imageForState:UIControlStateNormal];
	if (img) {
		[bt setImage:nil forState:UIControlStateNormal];
		[bt setImage:nil forState:UIControlStateHighlighted];
		[bt setImage:nil forState:UIControlStateSelected];
		cBean.b_Sel = NO;
	}else {
		[bt setImage:[UIImage imageNamed:@"border.png"] forState:UIControlStateNormal];
		[bt setImage:[UIImage imageNamed:@"border.png"] forState:UIControlStateHighlighted];
		[bt setImage:[UIImage imageNamed:@"border.png"] forState:UIControlStateSelected];
		cBean.b_Sel = YES;
	}	
}


-(void)getImagesfromDB
{
	if([imageArray count] != 0)
	{
		[imageArray removeAllObjects];
	}
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql = "select id, name,image, audio,selected from image WHERE category=? ORDER BY id ASC";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			sqlite3_bind_int(statements, 1, (int)cateID);
			while(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				
				CategoryBean *cBean = [[CategoryBean alloc] init];
                cBean.record_ID = sqlite3_column_int(statements, 0);
				if (sqlite3_column_text(statements, 1)) {
					cBean.name = @((char *)sqlite3_column_text(statements, 1));
				}else {
					cBean.name = @"";
				}
				if (sqlite3_column_text(statements, 2)) {
					cBean.image = @((char *)sqlite3_column_text(statements, 2));
				}else {
					cBean.image = @"";
				}
				if (sqlite3_column_text(statements, 3)) {
					cBean.audio = @((char *)sqlite3_column_text(statements, 3));
				}else {
					cBean.audio = @"";
				}

				cBean.b_Sel = sqlite3_column_int(statements, 4);
                [imageArray addObject:cBean];		
			}
			sqlite3_finalize(statements);
		}	
	}	
}

-(IBAction)done: (id)sender
{
	//write the selection to DB
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	for (int i=0; i<[imageArray count]; i++) {
		
		CategoryBean *cBean = imageArray[i];
		if (statements == nil) {
			static char *sql = "update image set selected=? where id=?";
			if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
			}
			sqlite3_bind_int(statements, 1, cBean.b_Sel);
			sqlite3_bind_int(statements, 2, (int)cBean.record_ID);
		}
		int success = sqlite3_step(statements);
		if (success == SQLITE_ERROR) {
			NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
		}    	
		sqlite3_finalize(statements);
		statements = nil;
	}
	
	//save default category
	if (statements == nil) {
		static char *sql = "update setting set cateID=? where id=?";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 1, (int)cateID);
		sqlite3_bind_int(statements, 2, 1);
	}
	int success = sqlite3_step(statements);
	if (success == SQLITE_ERROR) {
		NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
	}    
	sqlite3_finalize(statements);
	statements = nil;
	
	//return to before page
	[self.navigationController popToRootViewControllerAnimated:YES];
	
	//call the previous view also return to home page. Use delegate method for it
	//[self.delegate didChooseImage];
}

-(IBAction)selectAll: (id)sender
{
	for (int i=0; i<[imageArray count]; i++) {
		CategoryBean *cBean = imageArray[i];
		cBean.b_Sel = YES;
		UIButton *bt = cBean.bt;
		UIImage *img = [bt imageForState:UIControlStateNormal];
		if (!img) {
			[bt setImage:[UIImage imageNamed:@"border.png"] forState:UIControlStateNormal];
			[bt setImage:[UIImage imageNamed:@"border.png"] forState:UIControlStateHighlighted];
			[bt setImage:[UIImage imageNamed:@"border.png"] forState:UIControlStateSelected];			
		}
	}
}

-(IBAction)clearAll: (id)sender
{
	for (int i=0; i<[imageArray count]; i++) {
		CategoryBean *cBean = imageArray[i];
		cBean.b_Sel = NO;
		UIButton *bt = cBean.bt;
		UIImage *img = [bt imageForState:UIControlStateNormal];
		if (img) {
			[bt setImage:nil forState:UIControlStateNormal];
			[bt setImage:nil forState:UIControlStateHighlighted];
			[bt setImage:nil forState:UIControlStateSelected];		
		}
	}
}

#pragma mark UITableView methods

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tv deselectRowAtIndexPath:indexPath animated:NO];
	//CategoryBean *cBean = [imageArray objectAtIndex:indexPath.row];
//	if (indexPath.row == [imageArray count]) {
//		b_selAll = YES;
//		[tbView reloadData];
//		return;
//	}
//    UITableViewCell *tbCell = [tv cellForRowAtIndexPath:indexPath];
//	b_selAll = NO;
//	if (tbCell.accessoryType == UITableViewCellAccessoryCheckmark) {
//		tbCell.accessoryType = UITableViewCellAccessoryNone;
//	}else {
//		tbCell.accessoryType = UITableViewCellAccessoryCheckmark;
//	}	
}

-(UITableViewCell *) tableView:(UITableView *) tv cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    UITableViewCell* cell  = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"cell"];
    cell.backgroundColor = [UIColor clearColor];

//	if (b_selAll) {
//		cell.accessoryType = UITableViewCellAccessoryCheckmark;
//	}
	
//	if (indexPath.row == [imageArray count]) {
//		cell.textLabel.font = [UIFont fontWithName:@"Marker Felt" size:30.0];
//		cell.textLabel.text = @"All";
//	}else {
	
	int num = 6;
	int iextra = 0;
	if (([imageArray count]%6) != 0) {
		iextra = 1;
	}
	int rows = ((int)[imageArray count])/6 + iextra;
	if (indexPath.row == (rows-1)) {   // last line
		num = [imageArray count]%6;
	}
	if (num == 0) {
		num = 6;
	}
	    for (int i=0; i<num; i++) {
			CategoryBean *cBean = imageArray[indexPath.row*6+i];
			
			UIButton *bt = nil;
			if (cBean.bt) {
				bt = cBean.bt;
			}else {
				bt = [UIButton buttonWithType:UIButtonTypeCustom];
				cBean.bt = bt;
			}
			bt.frame = CGRectMake(210.5+i*88+15*i, 5, 88, 88);
			bt.tag = indexPath.row*6+i;
			
			if ((cateID==1) || (cateID==2)) {
				UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:cBean.image ofType:@"png"]];
				[bt setBackgroundImage:image forState:UIControlStateNormal];
				[bt setBackgroundImage:image forState:UIControlStateHighlighted];
				[bt setBackgroundImage:image forState:UIControlStateSelected];
				
			}else {  //document directory				
				if([self isExistsFile:[cBean imageFilePath]]){
					UIImage *image = [UIImage imageWithContentsOfFile:[cBean imageFilePath]];
					[bt setBackgroundImage:image forState:UIControlStateNormal];
					[bt setBackgroundImage:image forState:UIControlStateHighlighted];
					[bt setBackgroundImage:image forState:UIControlStateSelected];
				}
			}
			if (cBean.b_Sel) {
				[bt setImage:[UIImage imageNamed:@"border.png"] forState:UIControlStateNormal];
				[bt setImage:[UIImage imageNamed:@"border.png"] forState:UIControlStateHighlighted];
				[bt setImage:[UIImage imageNamed:@"border.png"] forState:UIControlStateSelected];
			}else {
				[bt setImage:nil forState:UIControlStateNormal];
				[bt setImage:nil forState:UIControlStateHighlighted];
				[bt setImage:nil forState:UIControlStateSelected];
			}

			[bt addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:bt];
			//[bt release];
			
			UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(210.5+i*88+15*i, 83, 88, 57)];
			lbName.text = NSLocalizedString(cBean.name, nil);
			lbName.font = [UIFont fontWithName:@"Marker Felt" size:28.0];
			lbName.textColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:112.0/255.0 alpha:1];
			lbName.backgroundColor = [UIColor clearColor];
			lbName.textAlignment = NSTextAlignmentCenter;
			[cell addSubview:lbName];
		}
		
		//}
	
	return cell;
}

-(NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger) section
{
	int iextra = 0;
	if (([imageArray count]%6) != 0) {
		iextra = 1;
	}
	return [imageArray count]/6 + iextra;//[imageArray count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 146.0;
}


@end
