//
//  ABMAuth2Manager.h
//  Pods
//
//  Created by Benjamin Maer on 4/6/15.
//
//

#import <Foundation/Foundation.h>





@interface ABMAuth2Manager : NSObject

@property (nonatomic, copy) NSString* clientId;
@property (nonatomic, copy) NSString* secret;
@property (nonatomic, copy) NSURL* baseURL;

- (NSURLSessionDataTask *)authenticateUsingOAuthWithURLString:(NSString *)URLString
														 code:(NSString *)code
												  redirectURI:(NSString *)uri
													  success:(void (^)(NSDictionary *jsonResponse))success
													  failure:(void (^)(NSError *error))failure;

//+(ABMAuth2Manager*)abm_sharedAuth2Manager;

@end
