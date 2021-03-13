//
//  CategoryBean.h
//  Game
//
//  Created by sandra on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


@interface CategoryBean : NSObject {
	NSInteger record_ID;
	NSString *name;
	NSString *image;
	NSString *audio;
	NSInteger category;
	UIButton *bt;
	BOOL b_Sel;
}

@property (nonatomic, assign) NSInteger record_ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *audio;
@property (nonatomic, assign) NSInteger category;
@property (nonatomic, strong) UIButton *bt;
@property (nonatomic, assign) BOOL b_Sel;
-(NSString*)audioFilePath;
-(NSString*)imageFilePath;

@end
