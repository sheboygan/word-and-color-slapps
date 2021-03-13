//
//  FolderViewController.h
//  Game
//
//  Created by sandra on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonVC.h"


@interface SelectFolderVC : CommonVC {
	IBOutlet UIButton *bt1;
	IBOutlet UIButton *bt2;
	IBOutlet UIButton *bt3;
	IBOutlet UIButton *bt4;
	IBOutlet UIButton *bt5;
	IBOutlet UIButton *bt6;
	IBOutlet UIButton *bt7;
	IBOutlet UIButton *bt8;
	IBOutlet UIButton *bt9;
	IBOutlet UIButton *bt10;
    IBOutlet UILabel *lbTitle;
	
	NSMutableArray *array_Folder;
	NSMutableArray *folderImages;
}

-(IBAction)chooseFolder: (id)sender;
-(void)getDatafromDB;
-(void)initUI;

@end
