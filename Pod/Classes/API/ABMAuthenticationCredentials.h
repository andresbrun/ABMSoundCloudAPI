//
//  ABMAuthenticationCredentials.h
//  Pods
//
//  Created by Benjamin Maer on 4/11/15.
//
//

#import <Foundation/Foundation.h>





@interface ABMAuthenticationCredentials : NSObject

/**
 The OAuth access token.
 */
@property (readonly, nonatomic, copy) NSString *accessToken;

/**
 The OAuth token type (e.g. "bearer").
 */
@property (readonly, nonatomic, copy) NSString *tokenType;

/**
 The OAuth refresh token.
 */
@property (readwrite, nonatomic, copy) NSString *refreshToken;

@property (readwrite, nonatomic, copy) NSDate *expiration;

/**
 Whether the OAuth credentials are expired.
 */
@property (readonly, nonatomic, assign, getter = isExpired) BOOL expired;

+ (instancetype)credentialWithOAuthToken:(NSString *)token
							   tokenType:(NSString *)type;

- (id)initWithOAuthToken:(NSString *)token
			   tokenType:(NSString *)type;

#pragma mark - Storing
+ (BOOL)storeCredential:(ABMAuthenticationCredentials*)credential
		 withIdentifier:(NSString *)identifier;

+ (BOOL)deleteCredentialWithIdentifier:(NSString *)identifier;

+ (ABMAuthenticationCredentials *)retrieveCredentialWithIdentifier:(NSString *)identifier;

@end
