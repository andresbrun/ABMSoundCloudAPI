//
//  ABMConnectViewController.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun Moreno on 14/03/15.
//  Copyright (c) 2015 Andres Brun Moreno. All rights reserved.
//

#import "ABMConnectViewController.h"
#import "ABMSoundCloudAPISingleton.h"

@interface ABMConnectViewController ()
@property (weak, nonatomic) IBOutlet UITextField *redirectURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *secretKeyTextField;
@end

@implementation ABMConnectViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
#warning REMOVE THIS
    [self.clientIDTextField setText:@"2c6da81d3f014254d3358bccd00f341a"];
    [self.secretKeyTextField setText:@"2bb216a627a0722a4e7244682f243706"];
    [self.redirectURLTextField setText:@"drummerboy://oauth"];
}

- (IBAction)connectButtonPressed:(id)sender {
    [[ABMSoundCloudAPISingleton sharedManager] setClientID:self.clientIDTextField.text secretKey:self.secretKeyTextField.text];
    
    __weak typeof(self) weakSelf = self;
    [[[ABMSoundCloudAPISingleton  sharedManager] soundCloudPort] loginWithResult:^(BOOL success) {
        if (success) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        } else {
            [weakSelf showErrorAlert];
        }
    } usingParentVC:self redirectURL:self.redirectURLTextField.text];
}

- (void)showErrorAlert {
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot authenticate with current data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
