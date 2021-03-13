    //
//  EditImageViewController.m
//  Game
//
//  Created by sandra on 11/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//



#import "EditContentVC.h"
#import "CategoryBean.h"
#import "GameAppDelegate.h"
#import "RecordAudioViewController.h"
#import "UIApplication+Navigation.h"

@implementation EditContentVC

@synthesize cateID, strTitle;
@synthesize parentItem;
-(BOOL)isExistsFile:(NSString *)filepath{
	NSFileManager *filemanage = [NSFileManager defaultManager];
	return [filemanage fileExistsAtPath:filepath];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	tbView.backgroundColor = [UIColor clearColor];
	imageArray = [[NSMutableArray alloc] init];
	array_Del = [[NSMutableArray alloc] init];
	lbTitle.text = strTitle;
	
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





-(IBAction)home: (id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
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

-(void)editTable:(id)sender{
	if (tbView.editing) {
		[btEdit setImage:[UIImage imageNamed:@"Remove.png"] forState:UIControlStateNormal];
		[btEdit setImage:[UIImage imageNamed:@"Remove.png"] forState:UIControlStateHighlighted];
		[btEdit setImage:[UIImage imageNamed:@"Remove.png"] forState:UIControlStateSelected];		
		[tbView setEditing:NO];
		[tbView reloadData];
		[self delfromDB];
	}else {		
		[btEdit setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateNormal];
		[btEdit setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateHighlighted];
		[btEdit setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateSelected];
		[tbView setEditing:YES];
		[tbView reloadData];
	}
}

-(void)delfromDB
{
	for (int i=0; i<[array_Del count]; i++) {
        [parentItem updateLastModifiedDate];
        
		CategoryBean *cBean = array_Del[i];
		
		GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
		sqlite3 *database = [app getDatabase];
		sqlite3_stmt *delete_statement = nil;	
		//delete from image where id = id
		if (delete_statement == nil) {
			const char *sql = "DELETE FROM image WHERE id=?";
			if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		sqlite3_bind_int(delete_statement, 1, (int)cBean.record_ID);
		int success1 = sqlite3_step(delete_statement);
		sqlite3_reset(delete_statement);
		if (success1 != SQLITE_DONE) {
			NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
		}
		sqlite3_finalize(delete_statement);
		delete_statement = nil;	
		
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		[fileManager removeItemAtPath:[cBean audioFilePath] error:NULL];
		[fileManager removeItemAtPath:[cBean imageFilePath] error:NULL];
	}
	[array_Del removeAllObjects];
}

//#pragma mark RecordAudioViewController methods
//
//-(void)newRecordDidFinish:(CategoryBean*)cateBean
//{
//	if (cateBean.record_ID == 0) {  //create a new
//		[imageArray addObject:cateBean];
//		[cateBean release];
//	}else {        //modify 
//		for (int i=0; i<[imageArray count]; i++) {
//			CategoryBean *cBean = [imageArray objectAtIndex:i];
//			if (cBean.record_ID == cateBean.record_ID) {
//				cBean.audio = [cateBean.audio retain];
//				cBean.image = [cateBean.image retain];
//				cBean.name = [cateBean.name retain];
//				break;
//			}
//		}
//		[cateBean release];
//	}
//}

#pragma mark UITableView methods

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath: indexPath animated: YES];
    [parentItem updateLastModifiedDate];

	RecordAudioViewController* recordAudioViewController = [[RecordAudioViewController alloc] init];
	if (indexPath.row == [imageArray count])
    {
        if (imageArray.count == LiteVersionMaxImagesInCategory + 1 && ![SharedObjects objects].isPro)
        {
            [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Word SLapPS"
                                                                 message: @"This version only supports the use of 8 images"
                                                             actionTitle: @"Buy Full" onCompletion:^{
                                                                 [appDelegate presentAppStoreFullVersion];
                                                             }];
            return;
        }

		recordAudioViewController._id = 0;
	}else {
		CategoryBean *cBean = imageArray[indexPath.row];
		recordAudioViewController._id = cBean.record_ID;
	}
	recordAudioViewController.delegate = self;
	recordAudioViewController._category = cateID;
    
    
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
	
	if (indexPath.row == [imageArray count]) {
		lbName.frame = CGRectMake(50, 20, 704, 60);
		lbName.textAlignment = NSTextAlignmentLeft;
		lbName.text = NSLocalizedString(@"Add an image", nil);
	}else {
		CategoryBean *cBean = imageArray[indexPath.row];
		
		UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 5, 78, 78)];
        imgView.image = [UIImage imageWithContentsOfFile:[cBean imageFilePath]];
		imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
		[cell addSubview:imgView];
		
		lbName.text = cBean.name;
	}
	[cell addSubview:lbName];

	return cell;
}

-(NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger) section
{
	return [imageArray count]+1;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableViews commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
		
		CategoryBean *cBean = imageArray[indexPath.row];
		[array_Del addObject:cBean];
		[imageArray removeObjectAtIndex:indexPath.row];
		
		[tbView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}else if (editingStyle == UITableViewCellEditingStyleInsert) {
		RecordAudioViewController *recordAudioViewController = [[RecordAudioViewController alloc] init];
		recordAudioViewController.delegate = self;
		recordAudioViewController._id = 0;
		recordAudioViewController._category = cateID;
        [self presentViewController: recordAudioViewController animated: NO completion: nil];
	}
	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == [imageArray count]) {
		return UITableViewCellEditingStyleInsert;
	}else {
        if (!tableView.isEditing) {
            return UITableViewCellEditingStyleNone;
        }
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 88.0;
}

@end
