//
//  RemoteSequenceBean.m
//  Sequence
//
//  Created by imac on 18.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RemoteSequenceBean.h"
#import "GameAppDelegate.h"
#import "CategoryBean.h"

@implementation RemoteSequenceBean
@synthesize content;


- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:content] forKey:@"content"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        _name = [decoder decodeObjectForKey:@"name"];
        content = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[decoder decodeObjectForKey:@"content"]]];
        
    }
    return self;
}


-(void)insertIntoDatabase {
// insert the category first
	GameAppDelegate *appDelegate = (GameAppDelegate*)[[UIApplication sharedApplication] delegate];
	sqlite3 *db = [appDelegate getDatabase];
	
    int categoryId = appDelegate.currentCategoryId;
    
	sqlite3_stmt * statements=nil;
	if (statements == nil) {// in
		static char *sql = "INSERT INTO category(name, parentId) VALUES(?, ?)";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_text(statements, 1, [_name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(statements, 2, categoryId);
	}
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
    } 
	// All data for the book is already in memory, but has not be written to the database
	sqlite3_finalize(statements);
	statements = nil;
	
	int _id = -1;
    
	//get the Sequence ID
	if (statements == nil) {
		char *sql2 = "select id from category WHERE name=?  AND parentId=?";
		
        if (sqlite3_prepare_v2(db, sql2, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
        }else{
			sqlite3_bind_text(statements, 1, [_name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statements, 2, categoryId);
			if(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
                _id = sqlite3_column_int(statements, 0);
			}
			sqlite3_finalize(statements);
			statements = nil;
		}	
	}
	cateID = _id;
	//fill category ID
	for (int i=0; i<[content count]; i++) {
		CategoryBean *cBean = content[i];
		cBean.category = _id;
		
		if (statements == nil) {
			static char *sql = "INSERT INTO image(name, image, audio, category) VALUES(?,?,?,?)";
			if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
			}
			sqlite3_bind_text(statements, 1, [cBean.name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statements,2, [cBean.image UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statements, 3, [cBean.audio UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statements, 4, _id);
//			sqlite3_bind_int(statements, 5, i+1);
		}
		int success = sqlite3_step(statements);
		if (success == SQLITE_ERROR) {
			NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
		} 
		// All data for the book is already in memory, but has not be written to the database
		sqlite3_finalize(statements);
		statements = nil;
	}
	
    [appDelegate.localFiles addObject:self];
}


@end
