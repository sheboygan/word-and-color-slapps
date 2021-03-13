//
//  EditFolderViewController.h
//  Game
//
//  Created by sandra on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonVC.h"


@interface FoldersListVC : CommonVC <UITextFieldDelegate> {
	NSMutableArray *array_Folder;
	NSMutableArray *array_Del;

	IBOutlet UIButton *btEdit;
    IBOutlet UILabel *lbTitle;
}

-(void)getDatafromDB;
-(IBAction)editTable:(id)sender;
-(void)delfromDB;
-(void)editFolder;
-(IBAction)home: (id)sender;

@end
