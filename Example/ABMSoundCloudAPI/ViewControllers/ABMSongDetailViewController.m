//
//  ABMSongDetailViewController.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun Moreno on 14/03/15.
//  Copyright (c) 2015 Andres Brun Moreno. All rights reserved.
//

#import "ABMSongDetailViewController.h"
#import "ABMSoundCloudAPISingleton.h"

@interface ABMSongDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *resultTextField;

@end

@implementation ABMSongDetailViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [[[ABMSoundCloudAPISingleton sharedManager] soundCloudPort] requestSongById:self.songDictionary[@"id"] withSuccess:^(NSDictionary *songDict) {
        [weakSelf.resultTextField setText:songDict.descriptionInStringsFileFormat];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }];
}

@end
