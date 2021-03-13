//
//  GFUIWindow+Navigation.m
//  GoFrendly
//
//  Created by Anna on 11/27/17.
//  Copyright © 2017 gofrendly. All rights reserved.
//

#import "UIApplication+Navigation.h"

@implementation UIApplication (Navigation)

- (UIViewController *)topViewController {
    UIWindow *topWindow = self.keyWindow;
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [UIApplication sharedApplication].windows;
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIViewController *topViewController = topWindow.rootViewController;
    
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    
    return topViewController;
}

- (void)showAlertWithTitle:(NSString*) title message: (NSString*) message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: title message: message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [[self topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString*) title message: (NSString*) message onCompletion: (void (^)(void)) onCompletion{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: title message: message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        onCompletion();
    }]];
    [[self topViewController] presentViewController:alertController animated:YES completion:nil];
}


- (void)showConfirmAlertWithTitle:(NSString*) title message: (NSString*) message actionTitle: (NSString*) actionTitle onCompletion: (void (^)(void)) onCompletion {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: title message: message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        onCompletion();
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [[self topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showConfirmAlertWithTitle:(NSString*) title message: (NSString*) message actionTitle: (NSString*) actionTitle onCompletion: (void (^)(void)) onCompletion onCancel: (void (^)(void)) onCancel {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: title message: message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        onCompletion();
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        onCancel();
    }]];
    
    [[self topViewController] presentViewController:alertController animated:YES completion:nil];
}

@end
