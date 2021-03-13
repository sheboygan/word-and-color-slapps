//
//  EnterFolderViewController.h
//  Game
//
//  Created by sandra on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonVC.h"
#import "EditFolderVC.h"

@interface CreateFolderVC : CommonVC <EditCatgViewControllerDelegate> {
	IBOutlet UITextField *tfFolder;
	NSMutableArray *categoryArray;
}

-(void)newCategoryDidFinish:(CateBean*)cateBean;
-(IBAction)newFolder:(id)sender;
-(IBAction)home: (id)sender;

@end
