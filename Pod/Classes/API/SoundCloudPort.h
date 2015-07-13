//
//  SoundCloudPort.h
//  ABMSoundCloudAPI
//
//  Created by AndresBrun on 01/10/14.
//  Copyright (c) 2014 Brun's Software. All rights reserved.
//

@interface SoundCloudPort : NSObject

- (instancetype)initWithClientId:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret;

- (BOOL)isValidToken;

- (void)loginWithResult:(void (^)(BOOL success))resultBlock
          usingParentVC:(UIViewController *)parentVC
            redirectURL:(NSString *)redirectURL;

- (void)requestPlaylistsWithSuccess:(void (^)(NSArray *playlists))successBlock
                            failure:(void (^)(NSError *error))failureBlock;

- (void)requestPlaylistWithID:(NSString *) playlistID
                  withSuccess:(void (^)(NSDictionary *songsDict))successBlock
                      failure:(void (^)(NSError *error))failureBlock;

- (void)requestSongsForQuery:(NSString *)query
                       limit:(NSUInteger)limit
                 withSuccess:(void (^)(NSDictionary *songsDict))successBlock
                     failure:(void (^)(NSError *error))failureBlock;

- (void)requestSongById:(NSString *)songID
            withSuccess:(void (^)(NSDictionary *songDict))successBlock
                failure:(void (^)(NSError *error))failureBlock;

- (void)followUserId:(NSString *)userID
         withSuccess:(void (^)(NSDictionary *songDict))successBlock
             failure:(void (^)(NSError *error))failureBlock;

- (void)downloadDataForSongURL:(NSString *)songStream
                        inPath:(NSString *)pathToSave
                   withSuccess:(void (^)(NSURL *path))successBlock
                       failure:(void (^)(NSError *error))failureBlock
                      progress:(void (^)(CGFloat progress))progressBlock;

- (void)uploadAudioFile:(NSData *)fileData
               mimeType:(NSString*)mimeType
                   meta:(NSDictionary*)params
            withSuccess:(void (^)(NSDictionary *songDict))successBlock
                failure:(void (^)(NSError *error))failureBlock;

- (void)cancelLastOperation;

@end
