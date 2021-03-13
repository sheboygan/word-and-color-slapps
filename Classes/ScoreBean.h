//
//  ScoreBean.h
//  Game
//
//  Created by sandra on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ScoreBean : NSObject {
	int _id;
	NSString *_time;
	NSString *_score;
	int _right;
	int _total;
	NSString *_folder;
	NSString *_category;
}

@property(nonatomic, assign) int _id;
@property(nonatomic, strong) NSString *_time;
@property(nonatomic, strong) NSString *_score;
@property(nonatomic, assign) int _right;
@property(nonatomic, assign) int _total;
@property(nonatomic, strong) NSString *_folder;
@property(nonatomic, strong) NSString *_category;

@end
