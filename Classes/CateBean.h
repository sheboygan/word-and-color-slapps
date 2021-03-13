//
//  CateBean.h
//  Game
//
//  Created by sandra on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CateBean : NSObject {
	NSInteger cateID;
	NSString *_name;
    BOOL b_empty;
	NSMutableArray *categories;
}

@property (nonatomic, assign) NSInteger cateID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL b_empty;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSDate *lastModifiedDate;
-(void)updateLastModifiedDate;
-(void)deleteFromDatabase;

@end
