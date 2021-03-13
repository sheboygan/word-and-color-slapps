//
//  SelImageViewController.h
//  Game
//
//  Created by sandra on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommonVC.h"

@protocol SelImageViewControllerDelegate<NSObject>
@optional
-(void)didChooseImage;
@end

@interface SelectImagesFromFolderVC : CommonVC {
	id<SelImageViewControllerDelegate> __weak delegate;
	
	NSMutableArray *imageArray;
	NSInteger cateID;
	BOOL b_selAll;
	IBOutlet UIButton *btDone;
	IBOutlet UIButton *btSelectAll;
	IBOutlet UIButton *btDisAll;
    IBOutlet UILabel *lbTitle;
}

-(void)getImagesfromDB;
-(IBAction)done: (id)sender;
-(IBAction)back:(id)sender;
-(BOOL)isExistsFile:(NSString *)filepath;
-(IBAction)selectAll: (id)sender;
-(IBAction)clearAll: (id)sender;
-(IBAction)chooseImage: (id)sender;

@property (nonatomic, assign) NSInteger cateID;
@property (weak) id<SelImageViewControllerDelegate> delegate;

@end
