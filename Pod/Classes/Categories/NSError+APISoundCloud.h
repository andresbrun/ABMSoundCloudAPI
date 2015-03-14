//
//  NSError+APISoundCloud.h
//  ABMSoundCloudAPI
//
//  Created by Andres Brun on 08/03/15.
//  Copyright (c) 2015 Brun's Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (APISoundCloud)

+ (NSError *)createParsingError;
+ (NSError *)createNonStreamableSongError;
+ (NSError *)createConnexionError;
+ (NSError *)createSessionError;

@end
