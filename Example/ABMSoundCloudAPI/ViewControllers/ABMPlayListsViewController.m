//
//  ABMPlayListsViewController.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun Moreno on 14/03/15.
//  Copyright (c) 2015 Andres Brun Moreno. All rights reserved.
//

#import "ABMPlayListsViewController.h"

#import "ABMSoundCloudAPISingleton.h"
#import "ABMPlayListSongsTableViewController.h"

@interface ABMPlayListsViewController ()
@property (nonatomic, strong) NSArray *playLists;
@end

@implementation ABMPlayListsViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak typeof(self) weaSelf = self;
    [[[ABMSoundCloudAPISingleton sharedManager] soundCloudPort] requestPlaylistsWithSuccess:^(NSArray *playLists) {
        weaSelf.playLists = playLists;
        [weaSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ABMPlayListSongsTableViewController class]]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *playListDict = self.playLists[selectedIndexPath.row];
        [(ABMPlayListSongsTableViewController *) segue.destinationViewController setPlayListDict:playListDict];
    }
}

#pragma mark - TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.playLists count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Playlist_Cell"];
    
    NSDictionary *playListDict = self.playLists[indexPath.row];
    
    cell.textLabel.text = playListDict[@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Tracks: %@", playListDict[@"track_count"]];
    
    return cell;
}

@end
