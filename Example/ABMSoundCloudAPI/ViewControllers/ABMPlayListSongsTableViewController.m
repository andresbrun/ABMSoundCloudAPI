//
//  ABMPlayListSongsTableViewController.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun Moreno on 14/03/15.
//  Copyright (c) 2015 Andres Brun Moreno. All rights reserved.
//

#import "ABMPlayListSongsTableViewController.h"
#import "ABMSongDetailViewController.h"

@interface ABMPlayListSongsTableViewController ()

@end

@implementation ABMPlayListSongsTableViewController

# pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ABMSongDetailViewController class]]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *songDict = self.playListDict[@"tracks"][selectedIndexPath.row];
        [(ABMSongDetailViewController *)segue.destinationViewController setSongDictionary:songDict];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.playListDict[@"tracks"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongDetail_Cell"];
    
    NSDictionary *songDict = self.playListDict[@"tracks"][indexPath.row];
    
    cell.textLabel.text = songDict[@"title"];
    cell.detailTextLabel.text = songDict[@"user"][@"username"];
    
    return cell;
}

@end
