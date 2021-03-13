//
//  EditImageViewController.h
//  Game
//
//  Created by sandra on 11/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommonVC.h"
#import "RecordAudioViewController.h"
#import "CateBean.h"
@interface EditContentVC : CommonVC <RecordAudioViewControllerDelegate> {

	NSMutableArray *imageArray;
	NSMutableArray *array_Del;
	NSInteger cateID;
	IBOutlet UIButton *btEdit;
	IBOutlet UILabel *lbTitle;
	
	NSString *strTitle;
}

-(void)getImagesfromDB;
-(IBAction)editTable:(id)sender;
//-(void)newRecordDidFinish:(CategoryBean*)cateBean;
-(void)delfromDB;
-(BOOL)isExistsFile:(NSString *)filepath;
-(IBAction)home: (id)sender;

@property (nonatomic, assign) NSInteger cateID;
@property (nonatomic, strong) NSString *strTitle;
@property (nonatomic,strong) CateBean *parentItem;

@end
