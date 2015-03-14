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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self retrieveConfigurationData]) {
        [self authenticate];
    }
}

- (IBAction)connectButtonPressed:(id)sender {
    [self authenticate];
}

- (void) authenticate {
    [[ABMSoundCloudAPISingleton sharedManager] setClientID:self.clientIDTextField.text secretKey:self.secretKeyTextField.text];
    
    __weak typeof(self) weakSelf = self;
    [[[ABMSoundCloudAPISingleton  sharedManager] soundCloudPort] loginWithResult:^(BOOL success) {
        if (success) {
            [weakSelf saveConfigurationData];
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        } else {
            [weakSelf showErrorAlert];
        }
    } usingParentVC:self redirectURL:self.redirectURLTextField.text];
}

- (void)showErrorAlert {
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot authenticate with current data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void) saveConfigurationData {
    [[NSUserDefaults standardUserDefaults] setValue:self.clientIDTextField.text forKey:@"ClientID"];
    [[NSUserDefaults standardUserDefaults] setValue:self.secretKeyTextField.text forKey:@"SecretKey"];
    [[NSUserDefaults standardUserDefaults] setValue:self.redirectURLTextField.text forKey:@"RedirectURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) retrieveConfigurationData {
    [self.clientIDTextField setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"ClientID"]];
    [self.secretKeyTextField setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"SecretKey"]];
    [self.redirectURLTextField setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"RedirectURL"]];
    
    return self.clientIDTextField.text.length>0 && self.secretKeyTextField.text.length>0 && self.redirectURLTextField.text.length>0;
}

@end
