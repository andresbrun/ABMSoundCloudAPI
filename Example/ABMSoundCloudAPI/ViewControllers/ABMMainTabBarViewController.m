//
//  ABMMainTabBarViewController.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun Moreno on 14/03/15.
//  Copyright (c) 2015 Andres Brun Moreno. All rights reserved.
//

#import "ABMMainTabBarViewController.h"
#import "ABMSoundCloudAPISingleton.h"

@interface ABMMainTabBarViewController ()

@end

@implementation ABMMainTabBarViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[[ABMSoundCloudAPISingleton sharedManager] soundCloudPort] isValidToken]) {
        [self performSegueWithIdentifier:@"presentConnectView" sender:nil];
    }
}

@end
