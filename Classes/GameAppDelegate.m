//
//  GameAppDelegate.m
//  Game
//
//  Created by Sunny on 11/4/10.
//  Copyright CoSoft 2010. All rights reserved.
//

#import "GameAppDelegate.h"
#import "MainMenuVC.h"
#import "DropboxBrowserViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation GameAppDelegate
@synthesize window, navController;
//@synthesize gameViewControlle;
@synthesize localFiles;
@synthesize database;
@synthesize currentCategoryId;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [Fabric with:@[[Crashlytics class]]];
    
    if (![SharedObjects objects].isColorSlapps)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
    
    if ([SharedObjects objects].isPro)
    {
        [self initDropboxSession];
    }

	[self createEditableCopyOfDatabaseIfNeeded];
	
    window.rootViewController = navController;
	navController.navigationBar.hidden = YES;
	[window makeKeyAndVisible];

	return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if (![SharedObjects objects].isPro) {
        return NO;
    }
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            NSLog(@"Success! User is logged into Dropbox.");
            [self openDropboxBrowser];
        } else if ([authResult isCancel]) {
            NSLog(@"Authorization flow was manually canceled by user!");
        } else if ([authResult isError]) {
            NSLog(@"Error: %@", authResult);
        }
    }
    return NO;
}

-(void)initDropboxSession
{
    NSString* appKey = @"54udeol8h0lda4a";
    [DBClientsManager setupWithAppKey:appKey];
}

- (void) presentAppStoreFullVersion
{
    NSString* appUrl = @"itms-apps://itunes.apple.com/LANGUAGE/app/id413888079?at=10lb2P&ct=Zorten";
    NSString* localeString = [NSString stringWithFormat:@"%@", [[NSLocale preferredLanguages] objectAtIndex:0]];
    appUrl = [appUrl stringByReplacingOccurrencesOfString: @"LANGUAGE" withString:localeString];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appUrl] options: @{} completionHandler:NULL];
}

-(void)openDropboxBrowser
{
    if (![SharedObjects objects].isPro)
    {
        [[UIApplication sharedApplication] showConfirmAlertWithTitle: @"Word SLapPS"
                                                             message: @"Sorry, Dropbox Sync is available only in full version"
                                                         actionTitle: @"Buy Now" onCompletion:^{
                                                             [self presentAppStoreFullVersion];
                                                         }];
        return;
    }
    
    if ([DBClientsManager authorizedClient]) {
        DropboxBrowserViewController *browser = [[DropboxBrowserViewController alloc] init];
        browser.modalPresentationStyle = UIModalPresentationFormSheet;
        [navController presentViewController: browser animated: YES completion: nil];
    }
    else {
        [DBClientsManager authorizeFromController: [UIApplication sharedApplication]
                                       controller: self.window.rootViewController
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL: url options: @{} completionHandler:NULL];
                                          }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}
- (void)upgradeDBVersionIfNeeded
{
    
    if ([SharedObjects objects].isColorSlapps)
    {
    	sqlite3_stmt * statements=nil;
        static char *sql = "select incorrect from setting";
        static char *sqlVisualtype = "ALTER TABLE setting ADD COLUMN 'visualType' INTEGER NOT NULL  DEFAULT 0";  //add visual type
        static char *sqlfarmBuy = "ALTER TABLE setting ADD COLUMN 'farmPurchased' BOOL NOT NULL  DEFAULT 0";  //add if purchased for farm pack
        static char *sqlvehicleBuy = "ALTER TABLE setting ADD COLUMN 'vehiclePurchased' BOOL NOT NULL  DEFAULT 0";  //add if purchaed for vehicle pack
        static char *sqlInCorrect = "ALTER TABLE setting ADD COLUMN 'incorrect' BOOL";
        static char *sqlupdate = "update setting set incorrect=1,advance=0";
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {   //version 1.1
            if (sqlite3_prepare_v2(database, sqlInCorrect, -1, &statements, NULL) == SQLITE_OK) {
                sqlite3_step(statements);
            }
            if (sqlite3_prepare_v2(database, sqlVisualtype, -1, &statements, NULL) == SQLITE_OK) {
                sqlite3_step(statements);
            }
            if (sqlite3_prepare_v2(database, sqlfarmBuy, -1, &statements, NULL) == SQLITE_OK) {
                sqlite3_step(statements);
            }
            if (sqlite3_prepare_v2(database, sqlvehicleBuy, -1, &statements, NULL) == SQLITE_OK) {
                sqlite3_step(statements);
            }
            if (sqlite3_prepare_v2(database, sqlupdate, -1, &statements, NULL) == SQLITE_OK) {
                sqlite3_step(statements);
            }
        }
        sqlite3_finalize(statements);
        statements = nil;
        return;
    }
	sqlite3_stmt * statements=nil;
    static char *sql = "select parentId from category where 1";
	static char *sql2 = "ALTER TABLE category ADD COLUMN 'parentId' INTEGER DEFAULT 0";
	static char *sql3 = "ALTER TABLE category ADD COLUMN 'custom' INTEGER DEFAULT 0";
	static char *sql4 = "ALTER TABLE category ADD COLUMN 'disable' INTEGER DEFAULT 0";
	
	static char *sql5 = "update category set parentId=101,custom=1";
	static char *sql6 = "update category set parentId=100,custom = 0 where id = 1";
	static char *sql7 = "update category set parentId=100,custom = 0 where id = 2";
	static char *sql8 = "insert INTO category(id,name,parentId,custom,disable) VALUES(100,'Colors and Animals',0,0,0)";
	static char *sql9 = "insert INTO category(id,name,parentId,custom,disable) VALUES(101,'Custom',0,1,0)";
	
	//Add the score DB by Sunny 05-05-2011
	static char *sqlSel = "select * from score"; 
	
	if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {   //update in version 1.1
			//NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		NSLog(@"%s--%d",sqlite3_errmsg(database),sqlite3_errcode(database));
			//sqlite3_errcode(database);
		if (sqlite3_prepare_v2(database, sql2, -1, &statements, NULL) != SQLITE_OK) {
			
		}else {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sql3, -1, &statements, NULL) != SQLITE_OK) {
			
		}else {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sql4, -1, &statements, NULL) != SQLITE_OK) {
			
		}else {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sql5, -1, &statements, NULL) != SQLITE_OK) {
			
		}else {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sql6, -1, &statements, NULL) != SQLITE_OK) {
			
		}else {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sql7, -1, &statements, NULL) != SQLITE_OK) {
			
		}else {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sql8, -1, &statements, NULL) != SQLITE_OK) {
			
		}else {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sql9, -1, &statements, NULL) != SQLITE_OK) {
			
		}else {
			sqlite3_step(statements);
		}
	}
	
	if (sqlite3_prepare_v2(database, sqlSel, -1, &statements, NULL) != SQLITE_OK) {  //update in version 1.2
		static char *sqlcreate = "CREATE TABLE 'score' ('id' INTEGER PRIMARY KEY  NOT NULL , 'time' VARCHAR, 'score' VARCHAR, 'right' INTEGER NOT NULL  DEFAULT 0, 'total' INTEGER NOT NULL  DEFAULT 5, 'folder' VARCHAR, 'category' VARCHAR)";
		static char *sqlInCorrect = "ALTER TABLE setting ADD COLUMN 'incorrect' BOOL";
		static char *sqlVisualtype = "ALTER TABLE setting ADD COLUMN 'visualType' INTEGER NOT NULL  DEFAULT 0";  //add visual type
		static char *sqlfarmBuy = "ALTER TABLE setting ADD COLUMN 'farmPurchased' BOOL NOT NULL  DEFAULT 0";  //add if purchased for farm pack
		static char *sqlvehicleBuy = "ALTER TABLE setting ADD COLUMN 'vehiclePurchased' BOOL NOT NULL  DEFAULT 0";  //add if purchaed for vehicle pack
		static char *sqlupdate = "update setting set incorrect=1,advance=0";
		static char *sqlupdateBird = "update image set name='Parrot' WHERE id=13";
		if (sqlite3_prepare_v2(database, sqlcreate, -1, &statements, NULL) == SQLITE_OK) {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sqlInCorrect, -1, &statements, NULL) == SQLITE_OK) {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sqlVisualtype, -1, &statements, NULL) == SQLITE_OK) {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sqlfarmBuy, -1, &statements, NULL) == SQLITE_OK) {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sqlvehicleBuy, -1, &statements, NULL) == SQLITE_OK) {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sqlupdate, -1, &statements, NULL) == SQLITE_OK) {
			sqlite3_step(statements);
		}
		if (sqlite3_prepare_v2(database, sqlupdateBird, -1, &statements, NULL) == SQLITE_OK) {
			sqlite3_step(statements);
		}
	}
	
	sqlite3_finalize(statements);
	statements = nil;
}

- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    
    NSString* dbName = @"users.sqlite";
    if ([SharedObjects objects].isColorSlapps)
        dbName = @"usersColors.sqlite";
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent: dbName];
	//NSLog(@"%@", writableDBPath);
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) {
		[self initializeDatabase];
		[self upgradeDBVersionIfNeeded];
		return;
	}
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: dbName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
	[self initializeDatabase];
}


- (void)initializeDatabase
{
    NSString* dbName = @"users.sqlite";
    if ([SharedObjects objects].isColorSlapps)
        dbName = @"usersColors.sqlite";

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent: dbName];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		// "Finalize" the statement - releases the resources associated with the statement.
		
	} else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

-(sqlite3 *) getDatabase
{
	return database;
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}




@end
