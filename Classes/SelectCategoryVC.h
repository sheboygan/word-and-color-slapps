//
//  ChooseCtoryViewController.h
//  Game
//
//  Created by sandra on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommonVC.h"
#import "SelectImagesFromFolderVC.h"

@interface SelectCategoryVC : CommonVC <SelImageViewControllerDelegate> {
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
	
//	IBOutlet UILabel *lb1;
//	IBOutlet UILabel *lb2;
//	IBOutlet UILabel *lb3;
//	IBOutlet UILabel *lb4;
//	IBOutlet UILabel *lb5;
	
	NSMutableArray *array_Cate;
	NSMutableArray *highImages;
	
	int folderID;
    
    IBOutlet UILabel *lbTitle;
}

@property(nonatomic, assign) int folderID;

-(IBAction)clickCategory: (id)sender;
-(void)getDatafromDB;
-(void)initUI;
@property (strong, nonatomic) IBOutlet UIButton *butDropbox;

//Delegate
-(void)didChooseImage;
- (IBAction)dropboxPressed:(id)sender;

@end
