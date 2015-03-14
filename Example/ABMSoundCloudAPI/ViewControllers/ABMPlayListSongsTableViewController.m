//
//  ABMPlayListSongsTableViewController.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun Moreno on 14/03/15.
//  Copyright (c) 2015 Andres Brun Moreno. All rights reserved.
//

#import "ABMPlayListSongsTableViewController.h"

@interface ABMPlayListSongsTableViewController ()

@end

@implementation ABMPlayListSongsTableViewController

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
