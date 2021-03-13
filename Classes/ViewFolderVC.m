    //
//  CategoryViewController.m
//  Game
//
//  Created by Sunny on 11/4/10.
//  Copyright 2010 CoSoft. All rights reserved.
//

#import "ViewFolderVC.h"
#import "GameAppDelegate.h"
#import "CateBean.h"
#import "CategoryBean.h"
#import "SelectImagesFromFolderVC.h"
#import "EditFolderVC.h"
#import "EditContentVC.h"
#import "UIApplication+Navigation.h"

@implementation ViewFolderVC

@synthesize butDropbox;
@synthesize parentItem;- (IBAction)dropboxPressed:(id)sender {
    GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.currentCategoryId = (int)parentItem.cateID;
    app.localFiles = array_Cate;
    [app openDropboxBrowser];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	tbView.backgroundColor = [UIColor clearColor];
	lbTitle.text = [NSString stringWithFormat:@"%@:", parentItem.name];
	array_Cate = [[NSMutableArray alloc] init];
	array_Del = [[NSMutableArray alloc] init];
    
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self getDatafromDB];
	[tbView reloadData];
}

-(void)refreshContent {
    [tbView reloadData];
}




-(IBAction)back: (id)sender
{
	if ([array_Del count] == 0) {
		[self.navigationController popViewControllerAnimated:YES];
	}else {
        NSString *strMessage = NSLocalizedString(@"Save changes", nil);
        [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Warning" message:strMessage actionTitle: @"Yes" onCompletion:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
	}
}

-(IBAction)home: (id)sender
{
	if ([array_Del count] == 0) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}else {
        NSString *strMessage = NSLocalizedString(@"Save changes", nil);
        [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Warning" message:strMessage actionTitle: @"Yes" onCompletion:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
	}
}

- (void)viewDidUnload {
    [self setButDropbox:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



-(IBAction)editTable:(id)sender
{
	if (tbView.editing) {
		[btEdit setImage:[UIImage imageNamed:@"Edit-remove.png"] forState:UIControlStateNormal];
		[btEdit setImage:[UIImage imageNamed:@"Edit-remove.png"] forState:UIControlStateHighlighted];
		[btEdit setImage:[UIImage imageNamed:@"Edit-remove.png"] forState:UIControlStateSelected];
		[tbView setEditing:NO];
		[tbView reloadData];
		[self editCategory];
		[self delfromDB];
	}else {		
		[btEdit setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateNormal];
		[btEdit setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateHighlighted];
		[btEdit setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateSelected];
		[tbView setEditing:YES];
		[tbView reloadData];
	}
}

-(void)editCategory
{
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	
	for (int i=0; i<[array_Cate count]; i++) {
		CateBean *cBean = array_Cate[i];
		if (statements == nil) {
			static char *sql = "update category set name=? where id=?";
			if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
			}
			sqlite3_bind_int(statements, 2, (int)cBean.cateID);
			sqlite3_bind_text(statements, 1, [cBean.name UTF8String], -1, SQLITE_TRANSIENT);	
		}
		int success = sqlite3_step(statements);
		if (success == SQLITE_ERROR) {
			NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
		}    	
		sqlite3_finalize(statements);
		statements = nil;
	}
}

-(void)delfromDB
{
    
    for (CateBean *cBean in array_Del) {
        [cBean deleteFromDatabase];
    }
	[array_Del removeAllObjects];
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
			sqlite3_bind_int(statements, 1, (int)parentItem.cateID);
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
	

}

#pragma mark UITableView methods

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath: indexPath animated: YES];
	if (indexPath.row == array_Cate.count)
    {
        if (array_Cate.count == LiteVersionMaxCategories && ![SharedObjects objects].isPro)
        {
            [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Word SLapPS"
                                                                 message: @"Sorry, it's allowed to have only two categories in lite version."
                                                             actionTitle: @"Buy Full" onCompletion:^{
                                                                 [appDelegate presentAppStoreFullVersion];
                                                             }];
            return;
        }

        
		if ([array_Cate count]!=10) {
			EditFolderVC *editCatgViewController = [[EditFolderVC alloc] init];
			editCatgViewController.cateID = 0;
			editCatgViewController.folderID = parentItem.cateID;
			[self.navigationController pushViewController:editCatgViewController animated:YES];
		}
	}else {
		CateBean *cBean = array_Cate[indexPath.row];
		EditContentVC *editImage = [[EditContentVC alloc] init];
		editImage.cateID = cBean.cateID;
        editImage.parentItem = cBean;
		editImage.strTitle = [NSString stringWithFormat:@"%@: %@", parentItem.name, cBean.name];
		[self.navigationController pushViewController:editImage animated:YES];
	}
}

-(UITableViewCell *) tableView:(UITableView *) tv cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    UITableViewCell* cell  = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"cell"];
    cell.backgroundColor = [UIColor clearColor];

	if (tbView.editing) {
		UITextField *tfName = [[UITextField alloc] initWithFrame:CGRectMake(55, 20, 400, 50)];
		tfName.font = [UIFont fontWithName:@"Marker Felt" size:30.0];
		tfName.borderStyle = UITextBorderStyleRoundedRect;
		tfName.backgroundColor = [UIColor clearColor];
		tfName.textAlignment = NSTextAlignmentLeft;
		tfName.delegate = self;
		CateBean *cBean = array_Cate[indexPath.row];
		tfName.tag = cBean.cateID;
		tfName.text = cBean.name;
		[cell addSubview:tfName];
		
		cell.accessoryType = UITableViewCellAccessoryNone;
	}else {
		UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(55, 20, 994, 60)];
		lbName.font = [UIFont fontWithName:@"Marker Felt" size:30.0];
		lbName.backgroundColor = [UIColor clearColor];
		lbName.textAlignment = NSTextAlignmentLeft;
		if (indexPath.row == [array_Cate count]) {
			NSInteger cout = [array_Cate count];
			if (cout == 10) {
				lbName.textColor = [UIColor grayColor];
			}else {
				lbName.textColor = [UIColor blackColor];
			}
            lbName.text = NSLocalizedString(@"Add Category", nil);
		}else {
			CateBean *cBean = array_Cate[indexPath.row];
			lbName.text = cBean.name;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		[cell addSubview:lbName];
	}
	
	return cell;
}

-(NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger) section
{
	if (tbView.editing) {
		return [array_Cate count];
	}
	return [array_Cate count]+1;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableViews commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
		
		CateBean *cBean = array_Cate[indexPath.row];
		[array_Del addObject:cBean];
		[array_Cate removeObjectAtIndex:indexPath.row];
		
		[tbView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}else if (editingStyle == UITableViewCellEditingStyleInsert) {
		NSInteger cout = [array_Cate count];
		if (cout != 10)
        {
			EditFolderVC *editCatgViewController = [[EditFolderVC alloc] init];
			editCatgViewController.cateID = 0;
			[self.navigationController pushViewController:editCatgViewController animated:YES];
		}
	}

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == [array_Cate count]) {
		return UITableViewCellEditingStyleInsert;
	}else {
		CateBean *cBean = array_Cate[indexPath.row];
		if (cBean.b_empty) {
			return UITableViewCellEditingStyleNone;
		}else {
            if (tableView.isEditing) {
                return UITableViewCellEditingStyleDelete;
            }
			return UITableViewCellEditingStyleNone;
		}
	}
	return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 88.0;
}

#pragma mark UITextFieldDelegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	tbView.frame = CGRectMake(tbView.frame.origin.x, tbView.frame.origin.y, tbView.frame.size.width, 570);
	[textField resignFirstResponder];
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	tbView.frame = CGRectMake(tbView.frame.origin.x, tbView.frame.origin.y, tbView.frame.size.width, 570/2);
	NSIndexPath *idPath = [NSIndexPath indexPathForRow:([array_Cate count]-1) inSection:0];
	[tbView scrollToRowAtIndexPath:idPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	for (int i=0; i<[array_Cate count]; i++) {
		CateBean *cBean = array_Cate[i];
		if (textField.tag == cBean.cateID) {
			cBean.name = textField.text;
			break;
		}
	}
}

@end
