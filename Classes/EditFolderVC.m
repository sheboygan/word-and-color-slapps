    //
//  EditCatgViewController.m
//  Game
//
//  Created by sandra on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EditFolderVC.h"
#import "GameAppDelegate.h"
#import "CategoryBean.h"
#import "GameAppDelegate.h"
#import "CateBean.h"
#import "UIApplication+Navigation.h"

@implementation EditFolderVC

@synthesize cateID, folderID;
@synthesize delegate;

-(BOOL)isExistsFile:(NSString *)filepath{
	
	NSFileManager *filemanage = [NSFileManager defaultManager];
	
	return [filemanage fileExistsAtPath:filepath];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    tfCategory.placeholder = NSLocalizedString(@"Input Category name here", nil);
	tbView.backgroundColor = [UIColor clearColor];
	imageArray = [[NSMutableArray alloc] init];
	//if (cateID != 0) {
		//[self getImagesfromDB];
	//}
	
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self getImagesfromDB];
	[tbView reloadData];
}





- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



-(void)editTable:(id)sender{
	if (tbView.editing) {
		[tbView setEditing:NO];
		[tbView reloadData];
		//[self delfromDB];
	}else {		
		[tbView setEditing:YES];
		[tbView reloadData];
	}
}

-(IBAction)newCategory:(id)sender
{
	NSLog(@"new categoty");
	if ([tfCategory.text isEqualToString:@""]) {
		[self ShowAlertMessage:NSLocalizedString(@"Please add a category name", nil) AlertTitle:@""];
		return;
	}
//	if ([imageArray count] <1 ) {
//		[self ShowAlertMessage:@"You should add 1 records at least!" AlertTitle:@"Warning"];
//		return;
//	}
	
	if (folderID == 0) {  //new category under a new folder
		CateBean *cateBean = [[CateBean alloc] init];
		cateBean.b_empty = NO;
		cateBean.name = tfCategory.text;
		cateBean.categories = imageArray;
		[self.delegate newCategoryDidFinish:cateBean];
		[self.navigationController popViewControllerAnimated:YES];
		return;
	}
	//insert the category first
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {// in
		static char *sql = "INSERT INTO category(name, parentId) VALUES(?, ?)";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_text(statements, 1, [tfCategory.text UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(statements, 2, (int)folderID);
	}
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
    } 
	// All data for the book is already in memory, but has not be written to the database
	sqlite3_finalize(statements);
	statements = nil;
	
	
	//get the category ID
	if (statements == nil) {
		char *sql2 = "select id from category WHERE name=? AND parentId=?";
		
        if (sqlite3_prepare_v2(db, sql2, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
        }else{
			sqlite3_bind_text(statements, 1, [tfCategory.text UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statements, 2, (int)folderID);
			if(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.

                cateID = sqlite3_column_int(statements, 0);
			}
			sqlite3_finalize(statements);
			statements = nil;
		}	
	}
	
	//fill category ID
	for (int i=0; i<[imageArray count]; i++) {
		CategoryBean *cBean = imageArray[i];
		cBean.category = cateID;
		
		if (statements == nil) {
			static char *sql = "INSERT INTO image(name, image, audio, category) VALUES(?,?,?,?)";
			if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
			}
			sqlite3_bind_text(statements, 1, [cBean.name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statements,2, [cBean.image UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statements, 3, [cBean.audio UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statements, 4, (int)cateID);
		}
		int success = sqlite3_step(statements);
		if (success == SQLITE_ERROR) {
			NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
		} 
		// All data for the book is already in memory, but has not be written to the database
		sqlite3_finalize(statements);
		statements = nil;
	}
	
	//successfully
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)back: (id)sender
{
	if ([imageArray count] == 0) {
		[self.navigationController popViewControllerAnimated:YES];
	}else {
		NSString *strMessage = NSLocalizedString(@"Save category", nil);
        [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Warning" message:strMessage actionTitle: @"Save" onCompletion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
	}
}

-(IBAction)home: (id)sender
{
	if ([imageArray count] == 0) {
		[self.navigationController popToRootViewControllerAnimated:YES];	
	}else {
		NSString *strMessage = NSLocalizedString(@"Save category", nil);
        [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Warning" message:strMessage actionTitle: @"Save" onCompletion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
	}
}

-(void)newRecordDidFinish:(CategoryBean*)cateBean
{
	[imageArray addObject:cateBean];
	//[tbView reloadData];
}

-(void)getImagesfromDB
{
	if (cateID==0) {
		return;
	}
	if([imageArray count] != 0)
	{
		[imageArray removeAllObjects];
	}
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql = "select id, name,image, audio from image WHERE category=? ORDER BY id ASC";
		
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

                [imageArray addObject:cBean];		
			}
			sqlite3_finalize(statements);
		}	
	}	
}

#pragma mark UITableView methods

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath: indexPath animated: YES];
	RecordAudioViewController *recordAudioViewController = [[RecordAudioViewController alloc] init];
	if (indexPath.row == [imageArray count]) {
		recordAudioViewController._id = 0;
	}else {
		CategoryBean *cBean = imageArray[indexPath.row];
		recordAudioViewController._id = cBean.record_ID;
	}
	recordAudioViewController._category = cateID;
	recordAudioViewController.delegate = self;
    [self presentViewController: recordAudioViewController animated: YES completion: nil];
}

-(UITableViewCell *) tableView:(UITableView *) tv cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    UITableViewCell* cell  = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"cell"];
    cell.backgroundColor = [UIColor clearColor];

	
	UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(150, 20, 704, 60)];
	lbName.font = [UIFont fontWithName:@"Marker Felt" size:30.0];
	lbName.backgroundColor = [UIColor clearColor];
	lbName.textAlignment = NSTextAlignmentCenter;
	
	//NSLog(@"%d", indexPath.row);
	if (indexPath.row==[imageArray count]) {
		lbName.frame = CGRectMake(50, 20, 704, 60);
		lbName.textAlignment = NSTextAlignmentLeft;
		lbName.text = NSLocalizedString(@"Add an image and audio", nil); 
	}else {
		CategoryBean *cBean = imageArray[indexPath.row];
		
		UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(50, 5, 78, 78)];
        img.image = [UIImage imageWithContentsOfFile:[cBean imageFilePath]];
		img.contentMode = UIViewContentModeScaleAspectFit;
		[cell addSubview:img];
		
		lbName.text = cBean.name;
	}
	
	[cell addSubview:lbName];
	
	return cell;
}

-(NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger) section
{
//	if (tbView.editing) {
//		return [imageArray count]+1;
//	}
	//NSLog(@"%d", [imageArray count]+1);
	return [imageArray count]+1;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableViews commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
		[tbView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}else if (editingStyle == UITableViewCellEditingStyleInsert) {
		RecordAudioViewController *recordAudioViewController = [[RecordAudioViewController alloc] init];
		recordAudioViewController._id = 0;
		recordAudioViewController._category = 3;
        [self presentViewController: recordAudioViewController animated: NO completion: nil];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == [imageArray count]) {
		return UITableViewCellEditingStyleInsert;
	}else {
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 88.0;
}

#pragma mark UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[tfCategory resignFirstResponder];
	return YES;
}

-(IBAction)leaveText: (id)sender
{
	[tfCategory resignFirstResponder];
}

@end
