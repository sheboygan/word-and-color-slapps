    //
//  EditFolderViewController.m
//  Game
//
//  Created by sandra on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FoldersListVC.h"
#import "CreateFolderVC.h"
#import "ViewFolderVC.h"
#import "CateBean.h"
#import "CategoryBean.h"
#import "GameAppDelegate.h"
#import "UIApplication+Navigation.h"

@implementation FoldersListVC
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    lbTitle.text = NSLocalizedString(@"Your Folders", nil);
	tbView.backgroundColor = [UIColor clearColor];
	
	array_Folder = [[NSMutableArray alloc] init];
	array_Del = [[NSMutableArray alloc] init];
	
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self getDatafromDB];
	[tbView reloadData];
}

-(IBAction)back: (id)sender
{
	if ([array_Del count] == 0) {
		[self.navigationController popViewControllerAnimated:YES];
	}else {
        NSString *strMessage = NSLocalizedString(@"Save changes", nil);
        [[UIApplication sharedApplication] showConfirmAlertWithTitle:@"Warning" message:strMessage actionTitle: @"Yes" onCompletion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
	}
}

-(IBAction)home: (id)sender
{
	if ([array_Del count] == 0) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}else {
        NSString *strMessage = NSLocalizedString(@"Save changes", nil);
        [[UIApplication sharedApplication] showConfirmAlertWithTitle:@"Warning" message:strMessage actionTitle: @"Yes" onCompletion:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
	}
}

-(IBAction)editTable:(id)sender
{
	if (tbView.editing) {
		[btEdit setImage:[UIImage imageNamed:@"delete folder.png.png"] forState:UIControlStateNormal];
		[btEdit setImage:[UIImage imageNamed:@"delete folder.png.png"] forState:UIControlStateHighlighted];
		[btEdit setImage:[UIImage imageNamed:@"delete folder.png.png"] forState:UIControlStateSelected];
		[tbView setEditing:NO];
		[tbView reloadData];
		[self editFolder];
		[self delfromDB];
	}else {		
		[btEdit setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateNormal];
		[btEdit setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateHighlighted];
		[btEdit setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateSelected];
		[tbView setEditing:YES];
		[tbView reloadData];
	}
}





- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



-(void)editFolder
{
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	
	for (int i=0; i<[array_Folder count]; i++) {
		CateBean *cBean = array_Folder[i];
		if (statements == nil) {
			static char *sql = "update category set name=? where parentId=? and id=?";
			if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
			}
			sqlite3_bind_int(statements, 2, 0);
			sqlite3_bind_int(statements, 3, (int)cBean.cateID);
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
	if([array_Folder count] != 0)
	{
		[array_Folder removeAllObjects];
	}
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql = "select id, name from category where parentId=? AND custom=? ORDER BY id ASC";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			sqlite3_bind_int(statements, 1, 0);
			sqlite3_bind_int(statements, 2, 1);
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
}

#pragma mark UITableView methods

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath: indexPath animated: YES];

	if (indexPath.row == array_Folder.count)
    {
        if (array_Folder.count == LiteVersionMaxFolders && ![SharedObjects objects].isPro)
        {
            [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Word SLapPS"
                                                                 message: @"Sorry, it's allowed to have only one folder in lite version."
                                                             actionTitle: @"Buy Full" onCompletion:^{
                                                                 [appDelegate presentAppStoreFullVersion];
                                                             }];
            return;
        }
        
		if ([array_Folder count]!=9)
        {
			CreateFolderVC *enterFolderViewController = [[CreateFolderVC alloc] init];
			[self.navigationController pushViewController:enterFolderViewController animated:YES];
		}
	}
    else
    {
		ViewFolderVC *categoryViewController = [[ViewFolderVC alloc] init];
		CateBean *cBean = array_Folder[indexPath.row];
        categoryViewController.parentItem = cBean;
		[self.navigationController pushViewController:categoryViewController animated:YES];
	}
}

-(UITableViewCell *) tableView:(UITableView *) tv cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    UITableViewCell* cell  = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"cell"];
    cell.backgroundColor = [UIColor clearColor];

	if (!tbView.editing) {
		UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(55, 20, 954, 60)];
		lbName.font = [UIFont fontWithName:@"Marker Felt" size:30.0];
		lbName.backgroundColor = [UIColor clearColor];
		lbName.textAlignment = NSTextAlignmentLeft;	
		if (indexPath.row == [array_Folder count]) {   //last row
			NSInteger cout = [array_Folder count];
			if (cout == 9) {
				lbName.textColor = [UIColor grayColor];  //gray if reaches 9
			}else {
				lbName.textColor = [UIColor blackColor];
			}
			lbName.text = NSLocalizedString(@"Add a folder", nil);
		}else {
			CateBean *cBean = array_Folder[indexPath.row];
			lbName.text = cBean.name;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		[cell addSubview:lbName];
	}else {
		UITextField *tfName = [[UITextField alloc] initWithFrame:CGRectMake(55, 20, 400, 50)];
		tfName.font = [UIFont fontWithName:@"Marker Felt" size:30.0];
		tfName.borderStyle = UITextBorderStyleRoundedRect;
		tfName.backgroundColor = [UIColor clearColor];
		tfName.textAlignment = NSTextAlignmentLeft;
		tfName.delegate = self;
		CateBean *cBean = array_Folder[indexPath.row];
		tfName.tag = cBean.cateID;
		tfName.text = cBean.name;
		[cell addSubview:tfName];
		
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

-(NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger) section
{
	if (tbView.editing) {
		return [array_Folder count];
	}
	return [array_Folder count]+1;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableViews commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
		
		CateBean *cBean = array_Folder[indexPath.row];
		[array_Del addObject:cBean];
		[array_Folder removeObjectAtIndex:indexPath.row];
		
		[tbView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}else if (editingStyle == UITableViewCellEditingStyleInsert) {
		NSLog(@"Insert");
		NSInteger cout = [array_Folder count];
		if (cout != 9) {
			
		}
	}
	
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == [array_Folder count]) {
		return UITableViewCellEditingStyleInsert;
	}else {
		CateBean *cBean = array_Folder[indexPath.row];
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
	NSIndexPath *idPath = [NSIndexPath indexPathForRow:([array_Folder count]-1) inSection:0];
	[tbView scrollToRowAtIndexPath:idPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	for (int i=0; i<[array_Folder count]; i++) {
		CateBean *cBean = array_Folder[i];
		if (textField.tag == cBean.cateID) {
			cBean.name = textField.text;
			break;
		}
	}
}

@end
