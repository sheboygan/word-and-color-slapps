//
//  CateBean.m
//  Game
//
//  Created by sandra on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CateBean.h"
#import "GameAppDelegate.h"
#import "CategoryBean.h"


@implementation CateBean

@synthesize cateID, b_empty, categories;
@synthesize name = _name;
@synthesize lastModifiedDate = _lastModifiedDate;

-(void)setLastModifiedDate:(NSDate *)lastModifiedDate {
    
    [[NSUserDefaults standardUserDefaults] setObject:lastModifiedDate forKey:[NSString stringWithFormat:@"%i",(int)cateID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _lastModifiedDate = lastModifiedDate;
}
-(NSDate*)lastModifiedDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%i",(int)cateID]];
}
-(void)updateLastModifiedDate {
    [self setLastModifiedDate:[NSDate date]];
}


-(void)deleteFromDatabase {
	NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
    GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
    sqlite3 *database = [app getDatabase];
    sqlite3_stmt * statements=nil;
    
    //get category from DB under this folder
    if (statements == nil) {
        char *sql = "select id, name from category where parentId=? ORDER BY id ASC";
        
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
            sqlite3_bind_int(statements, 1, (int)cateID);
            while(sqlite3_step(statements) == SQLITE_ROW) {
                // The second parameter indicates the column index into the result set.
                
                CateBean *cBean = [[CateBean alloc] init];
                cBean.cateID = sqlite3_column_int(statements, 0);
                cBean.name = @((char *)sqlite3_column_text(statements, 1));
                cBean.b_empty = NO;
                [categoryArray addObject:cBean];		
            }
            sqlite3_finalize(statements);
            statements = nil;
        }	
    }
    
    for (int j=0; j<[categoryArray count]; j++) {
        //get images records from DB
        NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
        
        CateBean *categoryBean = categoryArray[j];
        if (statements == nil) {
            char *sql = "select id, name,image, audio from image WHERE category=? ORDER BY id ASC";
            
            if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }else{
                sqlite3_bind_int(statements, 1, (int)categoryBean.cateID);
                while(sqlite3_step(statements) == SQLITE_ROW) {
                    // The second parameter indicates the column index into the result set.
                    
                    CategoryBean *cBean = [[CategoryBean alloc] init];
                    cBean.record_ID = sqlite3_column_int(statements, 0);
                    if (sqlite3_column_text(statements, 1)) {
                        cBean.name = @((char *)sqlite3_column_text(statements, 1));
                    }else {
                        cBean.name = @"";
                    }
                    if (sqlite3_column_text(statements, 2)) {
                        cBean.image = @((char *)sqlite3_column_text(statements, 2));
                    }else {
                        cBean.image = @"";
                    }
                    if (sqlite3_column_text(statements, 3)) {
                        cBean.audio = @((char *)sqlite3_column_text(statements, 3));
                    }else {
                        cBean.audio = @"";
                    }
                    
                    [imagesArray addObject:cBean];		
                }
                sqlite3_finalize(statements);
                statements = nil;
            }	
        }	
        
        sqlite3_stmt *delete_statement = nil;		
        //delete from categry which category ID = current ID
        if (delete_statement == nil) {
            const char *sql = "DELETE FROM category WHERE id=?";
            if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
            sqlite3_bind_int(delete_statement, 1, (int)categoryBean.cateID);
            int success = sqlite3_step(delete_statement);
            sqlite3_reset(delete_statement);
            if (success != SQLITE_DONE) {
                NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
            }
            sqlite3_finalize(delete_statement);
            delete_statement = nil;	
        }
        
        //delete from image where category ID = current category ID
        const char *sql = "DELETE FROM image WHERE category=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
        sqlite3_bind_int(delete_statement, 1, (int)categoryBean.cateID);
        int success1 = sqlite3_step(delete_statement);
        sqlite3_reset(delete_statement);
        if (success1 != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
        }
        sqlite3_finalize(delete_statement);
        delete_statement = nil;	
        
        
        for (int j=0; j<[imagesArray count]; j++) {
            CategoryBean *cBean = imagesArray[j];
            
            //delete the image and sound files associate with it
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            [fileManager removeItemAtPath:[cBean audioFilePath] error:NULL];
            [fileManager removeItemAtPath:[cBean imageFilePath] error:NULL];
        }
        
    }			
    
    //delete from categry which category ID = folder ID
    if (statements == nil) {
        const char *sql = "DELETE FROM category WHERE id=?";
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
        sqlite3_bind_int(statements, 1, (int)cateID);
        int success = sqlite3_step(statements);
        sqlite3_reset(statements);
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statements);
        statements = nil;	
    }
    

}
@end
