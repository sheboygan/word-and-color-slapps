    //
//  EnterFolderViewController.m
//  Game
//
//  Created by sandra on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreateFolderVC.h"
#import "CategoryBean.h"
#import "CateBean.h"
#import "EditFolderVC.h"
#import "UIApplication+Navigation.h"

@implementation CreateFolderVC

- (void)viewDidLoad {
    tfFolder.placeholder = NSLocalizedString(@"Input Folder name here", nil);
	tbView.backgroundColor = [UIColor clearColor];
	categoryArray = [[NSMutableArray alloc] init];
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
	[tbView reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



-(IBAction)back: (id)sender
{
	if ([categoryArray count] == 0) {
		[self.navigationController popViewControllerAnimated:YES];
	}else {
		NSString *strMessage = NSLocalizedString(@"Save folder", nil);
        [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Warning" message:strMessage actionTitle: @"Yes" onCompletion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
	}
}

-(IBAction)home: (id)sender
{
	if ([categoryArray count] == 0) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}else {
		NSString *strMessage = NSLocalizedString(@"Save folder", nil);
        [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Warning" message:strMessage actionTitle: @"Yes" onCompletion:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
	}
}

-(IBAction)newFolder:(id)sender
{
	NSLog(@"new folder");
	if ([tfFolder.text isEqualToString:@""]) {
		[self ShowAlertMessage:NSLocalizedString(@"Please add a folder name",nil) AlertTitle:@""];
		return;
	}
	
	//insert the folder first
	sqlite3 *db = [appDelegate getDatabase];
	int folderID = 0;
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {// in
		static char *sql = "INSERT INTO category(name, parentId, custom) VALUES(?, ?, ?)";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_text(statements, 1, [tfFolder.text UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(statements, 2, 0);
		sqlite3_bind_int(statements, 3, 1);
		
		int success = sqlite3_step(statements);
		if (success == SQLITE_ERROR) {
			NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
		} 
		// All data for the book is already in memory, but has not be written to the database
		sqlite3_finalize(statements);
		statements = nil;
	}
	
	
	//get the folder ID
	if (statements == nil) {
		char *sql2 = "select id from category WHERE name=? AND parentId=?";
		
        if (sqlite3_prepare_v2(db, sql2, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
        }else{
			sqlite3_bind_text(statements, 1, [tfFolder.text UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statements, 2, 0);
			if(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				
                folderID = sqlite3_column_int(statements, 0);
			}
			sqlite3_finalize(statements);
			statements = nil;
		}	
	}
	
	//fill category ID
	for (int i=0; i<[categoryArray count]; i++) {
		CateBean *cateBean = categoryArray[i];
		
		int cateID = 0;
		if (statements == nil) {// insert the category first
			static char *sql = "INSERT INTO category(name, parentId) VALUES(?, ?)";
			if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
			}
			sqlite3_bind_text(statements, 1, [cateBean.name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statements, 2, folderID);
			
			int success = sqlite3_step(statements);
			if (success == SQLITE_ERROR) {
				NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
			} 
			// All data for the book is already in memory, but has not be written to the database
			sqlite3_finalize(statements);
			statements = nil;
		}
		
		//get the category ID
		if (statements == nil) {
			char *sql2 = "select id from category WHERE name=? AND parentId=?";
			
			if (sqlite3_prepare_v2(db, sql2, -1, &statements, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
			}else{
				sqlite3_bind_text(statements, 1, [cateBean.name UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statements, 2, folderID);
				if(sqlite3_step(statements) == SQLITE_ROW) {
					// The second parameter indicates the column index into the result set.
					
					cateID = sqlite3_column_int(statements, 0);
				}
				sqlite3_finalize(statements);
				statements = nil;
			}	
		}
		
		for (int j=0; j<[cateBean.categories count]; j++) {
			CategoryBean *cBean = (cateBean.categories)[j];
			cBean.category = cateID;
			
			if (statements == nil) {
				static char *sql = "INSERT INTO image(name, image, audio, category) VALUES(?,?,?,?)";
				if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
					NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
				}
				sqlite3_bind_text(statements, 1, [cBean.name UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statements,2, [cBean.image UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statements, 3, [cBean.audio UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statements, 4, cateID);
			}
			int success = sqlite3_step(statements);
			if (success == SQLITE_ERROR) {
				NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
			} 
			// All data for the book is already in memory, but has not be written to the database
			sqlite3_finalize(statements);
			statements = nil;
		}
	}
	
	//successfully
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark UITableView methods

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath: indexPath animated: YES];

	if (indexPath.row==[categoryArray count])
	{
		if ([categoryArray count] != 10) {
			EditFolderVC *editCatgViewController = [[EditFolderVC alloc] init];
			editCatgViewController.cateID = 0;
			editCatgViewController.folderID = 0;
			editCatgViewController.delegate = self;
			[self.navigationController pushViewController:editCatgViewController animated:YES];
		}
	}
}

-(UITableViewCell *) tableView:(UITableView *) tv cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    UITableViewCell* cell  = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"cell"];
    cell.backgroundColor = [UIColor clearColor];

	UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, 704, 60)];
	lbName.font = [UIFont fontWithName:@"Marker Felt" size:30.0];
	lbName.backgroundColor = [UIColor clearColor];
	lbName.textAlignment = NSTextAlignmentLeft;
	
	//NSLog(@"%d", indexPath.row);
	if (indexPath.row==[categoryArray count]) {
		lbName.frame = CGRectMake(50, 20, 704, 60);
		lbName.textAlignment = NSTextAlignmentLeft;
		lbName.text = NSLocalizedString(@"Add Category", nil);
		if (indexPath.row  == 10) {
			lbName.textColor = [UIColor grayColor];
		}
	}else {
		CategoryBean *cBean = categoryArray[indexPath.row];		
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
	return [categoryArray count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 88.0;
}

#pragma mark UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[tfFolder resignFirstResponder];
	return YES;
}

-(IBAction)leaveText: (id)sender
{
	[tfFolder resignFirstResponder];
}

#pragma mark EditCatgViewController
-(void)newCategoryDidFinish:(CateBean*)cateBean
{
	[categoryArray addObject:cateBean];
}
@end
