//
//  ABMSearchSongsViewController.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun Moreno on 14/03/15.
//  Copyright (c) 2015 Andres Brun Moreno. All rights reserved.
//

#import "ABMSearchSongsViewController.h"
#import "ABMSoundCloudAPISingleton.h"
#import "ABMSongDetailViewController.h"

@interface ABMSearchSongsViewController () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) NSMutableArray *songsList;
@property(nonatomic, assign, getter=isSearching) BOOL searching;
@end

@implementation ABMSearchSongsViewController

#pragma mark - Private methods
- (void)searchTableList {
    NSString *query = self.searchDisplayController.searchBar.text;
   [[[ABMSoundCloudAPISingleton sharedManager] soundCloudPort] requestSongsForQuery:query limit:20 withSuccess:^(NSDictionary *songsDict) {
       self.songsList = songsDict[@"suggestions"];
       self.searching=NO;
   } failure:^(NSError *error) {
       [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
       self.searching=NO;
   }];
}

# pragma mark - NAvigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ABMSongDetailViewController class]]) {
        [(ABMSongDetailViewController *)segue.destinationViewController setSongDictionary:sender];
    }
}
#pragma mark - Search Bar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if([searchText length] != 0 && !self.searching) {
        self.searching = YES;
        [self searchTableList];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchTableList];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.songsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    NSDictionary *songDictionary = [self.songsList objectAtIndex:indexPath.row];
    
    [cell.textLabel setAttributedText:[self createAttributtedStringFromHTMLText:songDictionary[@"query"]]];
    [cell.detailTextLabel setText:songDictionary[@"kind"]];
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *songDictionary = [self.songsList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"presentSong" sender:songDictionary];
    
    return NO;
}

#pragma mark - Helpers
- (NSAttributedString *) createAttributtedStringFromHTMLText:(NSString *)htmlText {
    NSError *error;
    NSAttributedString *attributtedString = [[NSAttributedString alloc] initWithData: [htmlText dataUsingEncoding:NSUTF8StringEncoding]
                                                            options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                 documentAttributes: nil
                                                              error: &error];
    if(error)
        NSLog(@"Unable to parse label text: %@", error);
    
    return attributtedString;
}

@end
