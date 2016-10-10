//
//  NSError+APISoundCloud.h
//  ABMSoundCloudAPI
//
//  Created by Andres Brun on 08/03/15.
//  Copyright (c) 2015 Brun's Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (APISoundCloud)

+ (nonnull NSError *)createParsingError;
+ (nonnull NSError *)createNonStreamableSongError;
+ (nonnull NSError *)createConnexionError;
+ (nonnull NSError *)createSessionError;

@end
