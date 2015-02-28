//
//  SCAppDelegate.m
//  SCCastroControls
//
//  Created by Sam Page on 22/02/14.
//  Copyright (c) 2014 Subjective-C. All rights reserved.
//

#import "SCAppDelegate.h"
#import "SCRootViewController.h"

@implementation SCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    SCRootViewController *rootViewController = [[SCRootViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = rootViewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
