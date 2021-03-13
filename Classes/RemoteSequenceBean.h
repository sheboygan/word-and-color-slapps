//
//  RemoteSequenceBean.h
//  Sequence
//
//  Created by imac on 18.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CateBean.h"

@interface RemoteSequenceBean : CateBean
@property (nonatomic,strong) NSMutableArray *content;
-(void)insertIntoDatabase;

@end
