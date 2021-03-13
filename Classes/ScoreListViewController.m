    //
//  ScoreListViewController.m
//  Game
//
//  Created by sandra on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreListViewController.h"
#import "ScoreViewController.h"
#import "ScoreBean.h"
#import "GameAppDelegate.h"

@implementation ScoreListViewController

- (void)viewDidLoad
{
	results = [[NSMutableArray alloc] init];
	_vType = 0;
	[self initBackground];
	[self getRelfromDB];
	
    [super viewDidLoad];
}


-(void)getRelfromDB
{
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	
	//get category from DB under this folder
	if (statements == nil) {
		char *sql = "select id, time,score, right,total, folder, category from score ORDER by id DESC";
		
		if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}else{
			while(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				
				ScoreBean *sBean = [[ScoreBean alloc] init];
				sBean._id = sqlite3_column_int(statements, 0);
				sBean._time = @((char *)sqlite3_column_text(statements, 1));
				sBean._score = @((char *)sqlite3_column_text(statements, 2));
				sBean._right = sqlite3_column_int(statements, 3);
				sBean._total = sqlite3_column_int(statements, 4);
				sBean._folder = @((char *)sqlite3_column_text(statements, 5));
				sBean._category = @((char *)sqlite3_column_text(statements, 6));
				[results addObject:sBean];		
			}
			sqlite3_finalize(statements);
			statements = nil;
		}	
	}	
}

-(void)initBackground
{
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql = "select visualType from setting";
		
		if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}else{;
			if(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				
				_vType = sqlite3_column_int(statements, 0);
			}
			sqlite3_finalize(statements);
		}	
	}	
	
	if(_vType == 2)  //farm pack
	{
		bgImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"farm background" ofType:@"png"]];
	}else if(_vType == 1)  //vehicle pack
	{
		bgImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vehicleBg" ofType:@"png"]];
	}else {
		bgImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bgPlay" ofType:@"png"]];
	}
}



#pragma mark UITableView methods

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tv deselectRowAtIndexPath:indexPath animated:NO];
	ScoreBean *sBean = results[indexPath.row];
	ScoreViewController *scoreViewController = [[ScoreViewController alloc] init];
	scoreViewController.sBean = sBean;
	scoreViewController._vType = _vType;
	[self.navigationController pushViewController:scoreViewController animated:YES];
}

-(UITableViewCell *) tableView:(UITableView *) tv cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    UITableViewCell* cell  = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"cell"];
    cell.backgroundColor = [UIColor clearColor];

	ScoreBean *sBean = results[indexPath.row];
	
	UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 638, 45)];
	lbName.text = [NSString stringWithFormat:@"%@    %@ - %@", sBean._time, NSLocalizedString(sBean._folder, nil), NSLocalizedString(sBean._category, nil)];
	lbName.font = [UIFont fontWithName:@"Marker Felt" size:28.0];
	if (_vType == 1) {  //vehicle type
		lbName.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
	}else {
		lbName.textColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:112.0/255.0 alpha:1];
	}
	lbName.backgroundColor = [UIColor clearColor];
	lbName.textAlignment = NSTextAlignmentLeft;
	[cell addSubview:lbName];
	
	UILabel *lbScore = [[UILabel alloc] initWithFrame:CGRectMake(668, 5, 190, 45)];
	lbScore.text = [NSString stringWithFormat:@"%d / %d = %d%%", sBean._right, sBean._total, sBean._right*100/sBean._total];
	lbScore.font = [UIFont fontWithName:@"Marker Felt" size:28.0];
	if (_vType == 1) {  //vehicle type
		lbScore.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
	}else {
		lbScore.textColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:112.0/255.0 alpha:1];
	}
	
	lbScore.backgroundColor = [UIColor clearColor];
	lbScore.textAlignment = NSTextAlignmentLeft;
	[cell addSubview:lbScore];

	return cell;
}

-(NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger) section
{
	return [results count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50.0;
}

@end
