//
//  SoundCloudPort.h
//  ABMSoundCloudAPI
//
//  Created by AndresBrun on 01/10/14.
//  Copyright (c) 2014 Brun's Software. All rights reserved.
//

@interface SoundCloudPort : NSObject

- (instancetype)initWithClientId:(nonnull NSString *)clientID
                    clientSecret:(nonnull NSString *)clientSecret;

- (BOOL)isValidToken;

- (void)loginWithResult:(nullable void (^)(BOOL success))resultBlock
          usingParentVC:(nonnull UIViewController *)parentVC
            redirectURL:(nonnull NSString *)redirectURL;

- (void)requestPlaylistsWithSuccess:(nullable void (^)(NSArray  *_Nonnull playlists))successBlock
                            failure:(nullable void (^)(NSError *_Nonnull error))failureBlock;

- (void)requestPlaylistWithID:(nonnull NSString *) playlistID
                  withSuccess:(nullable void (^)(NSDictionary *_Nonnull songsDict))successBlock
                      failure:(nullable void (^)(NSError *_Nonnull error))failureBlock;

- (void)requestSongsForQuery:(nonnull NSString *)query
                       limit:(NSUInteger)limit
                 withSuccess:(nullable void (^)(NSDictionary *_Nonnull songsDict))successBlock
                     failure:(nullable void (^)(NSError *_Nonnull error))failureBlock;

- (void)requestSongById:(nonnull NSString *)songID
            withSuccess:(nullable void (^)(NSDictionary *_Nonnull songDict))successBlock
                failure:(nullable void (^)(NSError *_Nonnull error))failureBlock;

- (void)followUserId:(nonnull NSString *)userID
         withSuccess:(nullable void (^)(NSDictionary *_Nonnull songDict))successBlock
             failure:(nullable void (^)(NSError *_Nonnull error))failureBlock;

- (void)downloadDataForSongURL:(nonnull NSString *)songStream
                        inPath:(nonnull NSString *)pathToSave
                   withSuccess:(nullable void (^)(NSURL *_Nonnull path))successBlock
                       failure:(nullable void (^)(NSError *_Nonnull error))failureBlock
                      progress:(nullable void (^)(CGFloat progress))progressBlock;

- (void)uploadAudioFile:(nonnull NSData *)fileData
               mimeType:(nonnull NSString*)mimeType
                   meta:(nonnull NSDictionary*)params
            withSuccess:(nullable void (^)(NSDictionary *_Nonnull songDict))successBlock
               progress:(nullable void (^)(NSProgress *_Nonnull progress))progressBlock
                failure:(nullable void (^)(NSError *_Nonnull error))failureBlock;

- (void)cancelLastOperation;

@end
