//
//  ABMAuth2Manager.h
//  Pods
//
//  Created by Benjamin Maer on 4/6/15.
//
//

#import <Foundation/Foundation.h>





typedef void(^abm_Auth2Manager_successBlock) (NSDictionary *jsonResponse);
typedef void(^abm_Auth2Manager_failureBlock) (NSError *error);





@interface ABMAuth2Manager : NSObject

@property (nonatomic, copy) NSString* clientId;
@property (nonatomic, copy) NSString* secret;
@property (nonatomic, copy) NSURL* baseURL;

- (NSURLSessionDataTask *)authenticateUsingOAuthWithURLString:(NSString *)URLString
														 code:(NSString *)code
												  redirectURI:(NSString *)uri
													  success:(abm_Auth2Manager_successBlock)success
													  failure:(abm_Auth2Manager_failureBlock)failure;

//success:(void (^)(NSDictionary *jsonResponse))success

//+(ABMAuth2Manager*)abm_sharedAuth2Manager;

@end