//
//  GFUIWindow+Navigation.h
//  GoFrendly
//
//  Created by Anna on 11/27/17.
//  Copyright © 2017 gofrendly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Navigation)

- (UIViewController *)topViewController;

- (void)showAlertWithTitle:(NSString*) title message: (NSString*) message;
- (void)showAlertWithTitle:(NSString*) title message: (NSString*) message onCompletion: (void (^)(void)) onCompletion;
- (void)showConfirmAlertWithTitle:(NSString*) title message: (NSString*) message actionTitle: (NSString*) actionTitle onCompletion: (void (^)(void)) onCompletion;
- (void)showConfirmAlertWithTitle:(NSString*) title message: (NSString*) message actionTitle: (NSString*) actionTitle onCompletion: (void (^)(void)) onCompletion onCancel: (void (^)(void)) onCancel;
@end
