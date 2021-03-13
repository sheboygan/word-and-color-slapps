//
//  EditCatgViewController.h
//  Game
//
//  Created by sandra on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommonVC.h"
#import "RecordAudioViewController.h"

@class CateBean;

@protocol EditCatgViewControllerDelegate<NSObject>
@optional
-(void)newCategoryDidFinish:(CateBean*)cateBean;
@end

@interface EditFolderVC : CommonVC <RecordAudioViewControllerDelegate, UITextFieldDelegate> {
	id<EditCatgViewControllerDelegate> __weak delegate;
	NSInteger cateID;
	NSInteger folderID;
	IBOutlet UITextField *tfCategory;
	
	NSMutableArray *imageArray;
}

-(void)getImagesfromDB;
-(void)editTable:(id)sender;
-(BOOL)isExistsFile:(NSString *)filepath;
-(IBAction)newCategory:(id)sender;
-(void)newRecordDidFinish:(CategoryBean*)cateBean;
-(IBAction)leaveText: (id)sender;
-(IBAction)home: (id)sender;

@property (weak) id<EditCatgViewControllerDelegate> delegate;
@property(nonatomic, assign) NSInteger cateID;
@property(nonatomic, assign) NSInteger folderID;

@end
