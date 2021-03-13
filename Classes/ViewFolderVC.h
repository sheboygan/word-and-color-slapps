//
//  CategoryViewController.h
//  Game
//
//  Created by Sunny on 11/4/10.
//  Copyright 2010 CoSoft. All rights reserved.
//

#import "CommonVC.h"
#import "CateBean.h"

@interface ViewFolderVC : CommonVC <UITextFieldDelegate> {
	NSMutableArray *array_Cate;
	NSMutableArray *array_Del;
	IBOutlet UIButton *btEdit;
	IBOutlet UILabel *lbTitle;
}

-(void)getDatafromDB;
-(IBAction)editTable:(id)sender;
-(void)delfromDB;
-(void)editCategory;
-(IBAction)home: (id)sender;

- (IBAction)dropboxPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *butDropbox;
-(void)refreshContent;
@property (nonatomic,strong) CateBean *parentItem;
@end
