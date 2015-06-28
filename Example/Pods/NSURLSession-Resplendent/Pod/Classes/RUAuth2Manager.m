//
//  RUAuth2Manager.m
//  Pods
//
//  Created by Benjamin Maer on 4/6/15.
//
//

#import "RUAuth2Manager.h"
#import "RUAuthenticationCredentials.h"





static NSString * const kRUAuth2Manager_AuthCodeGrantType = @"authorization_code";





typedef NS_ENUM(NSInteger, RUAuth2Manager_HTTPMethodType) {
	RUAuth2Manager_HTTPMethodType_GET,
	RUAuth2Manager_HTTPMethodType_POST,
	RUAuth2Manager_HTTPMethodType_PUT,
	RUAuth2Manager_HTTPMethodType_PATCH,
	RUAuth2Manager_HTTPMethodType_DELETE,
};

static NSString * const kRURUAuth2Manager_charactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";
static NSString * const kRURUAuth2Manager_errorDomain = @"com.NSURLSession-Resplendent.RUAuth2Manager.oauth2.error";

static NSString * AMBPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
	static NSString * const kAFCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
	
	return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kAFCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kRURUAuth2Manager_charactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

// See: http://tools.ietf.org/html/rfc6749#section-5.2
static NSError * RUAuth2Manager_errorFromRFC6749Section5_2Error(id object) {
	if (![object valueForKey:@"error"] || [[object valueForKey:@"error"] isEqual:[NSNull null]]) {
		return nil;
	}
	
	NSMutableDictionary *mutableUserInfo = [NSMutableDictionary dictionary];
	
	NSString *description = nil;
	if ([object valueForKey:@"error_description"]) {
		description = [object valueForKey:@"error_description"];
	} else {
		if ([[object valueForKey:@"error"] isEqualToString:@"invalid_request"]) {
			description = NSLocalizedStringFromTable(@"The request is missing a required parameter, includes an unsupported parameter value (other than grant type), repeats a parameter, includes multiple credentials, utilizes more than one mechanism for authenticating the client, or is otherwise malformed.", @"AFOAuth2Manager", @"invalid_request");
		} else if ([[object valueForKey:@"error"] isEqualToString:@"invalid_client"]) {
			description = NSLocalizedStringFromTable(@"Client authentication failed (e.g., unknown client, no client authentication included, or unsupported authentication method).  The authorization server MAY return an HTTP 401 (Unauthorized) status code to indicate which HTTP authentication schemes are supported.  If the client attempted to authenticate via the \"Authorization\" request header field, the authorization server MUST respond with an HTTP 401 (Unauthorized) status code and include the \"WWW-Authenticate\" response header field matching the authentication scheme used by the client.", @"AFOAuth2Manager", @"invalid_request");
		} else if ([[object valueForKey:@"error"] isEqualToString:@"invalid_grant"]) {
			description = NSLocalizedStringFromTable(@"The provided authorization grant (e.g., authorization code, resource owner credentials) or refresh token is invalid, expired, revoked, does not match the redirection URI used in the authorization request, or was issued to another client.", @"AFOAuth2Manager", @"invalid_request");
		} else if ([[object valueForKey:@"error"] isEqualToString:@"unauthorized_client"]) {
			description = NSLocalizedStringFromTable(@"The authenticated client is not authorized to use this authorization grant type.", @"AFOAuth2Manager", @"invalid_request");
		} else if ([[object valueForKey:@"error"] isEqualToString:@"unsupported_grant_type"]) {
			description = NSLocalizedStringFromTable(@"The authorization grant type is not supported by the authorization server.", @"AFOAuth2Manager", @"invalid_request");
		}
	}
	
	if (description) {
		mutableUserInfo[NSLocalizedDescriptionKey] = description;
	}
	
	if ([object valueForKey:@"error_uri"]) {
		mutableUserInfo[NSLocalizedRecoverySuggestionErrorKey] = [object valueForKey:@"error_uri"];
	}
	
	return [NSError errorWithDomain:kRURUAuth2Manager_errorDomain code:-1 userInfo:mutableUserInfo];
}





@interface RUAuth2Manager ()

@property (nonatomic, readonly) NSURLSession* session;

- (NSURLSessionDataTask *)authenticateUsingOAuthWithURLString:(NSString *)URLString
												   parameters:(NSDictionary *)parameters
													  success:(ru_Auth2Manager_authenticationSuccessBlock)success
													  failure:(ru_Auth2Manager_failureBlock)failure;

- (NSURLSessionDataTask *)URLSessionDataTaskWithRequest:(NSURLRequest*)URLRequest
												success:(ru_Auth2Manager_successBlock)success
												failure:(ru_Auth2Manager_failureBlock)failure;

-(void)applyParameters:(id)parameters toHTTPBodyOfRequest:(NSMutableURLRequest*)URLRequest;
-(NSString*)URLStringWithParameters:(id)parameters withBaseURLString:(NSString*)URLString;
-(NSURL*)URLWithString:(NSString*)URLString parameters:(id)parameters HTTPMethodType:(RUAuth2Manager_HTTPMethodType)HTTPMethodType;

- (NSMutableURLRequest *)URLRequestURLString:(NSString*)URLString
								  parameters:(id)parameters
							  HTTPMethodType:(RUAuth2Manager_HTTPMethodType)HTTPMethodType;

+(NSString*)requestHTTPMethodForType:(RUAuth2Manager_HTTPMethodType)HTTPMethodType;
+(BOOL)HTTPMethodTypeEncodesParametersIntoFormBody:(RUAuth2Manager_HTTPMethodType)HTTPMethodType;

@end





@implementation RUAuth2Manager

#pragma mark - NSObject
-(instancetype)init
{
	self = [super init];
	if (self) {
		NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
		
		// This will set all requests to only accept JSON responses.
		[sessionConfig setHTTPAdditionalHeaders:
		 @{@"Accept"			: @"application/json",
		   }
		 ];

		[sessionConfig setTimeoutIntervalForRequest:30.0f];
		[sessionConfig setTimeoutIntervalForResource:60.0f];
		[sessionConfig setHTTPMaximumConnectionsPerHost:1];

		_session = [NSURLSession sessionWithConfiguration:sessionConfig];
	}
	
	return self;
}

#pragma mark - Authenticate
- (NSURLSessionDataTask *)authenticateUsingOAuthWithURLString:(NSString *)URLString
														 code:(NSString *)code
												  redirectURI:(NSString *)uri
													  success:(ru_Auth2Manager_authenticationSuccessBlock)success
													  failure:(ru_Auth2Manager_failureBlock)failure
{
	if (URLString.length == 0)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	if (code == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	if (uri == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	NSParameterAssert(code);
	NSParameterAssert(uri);
	
	NSString* encodedURI = AMBPercentEscapedQueryStringKeyFromStringWithEncoding(uri, NSUTF8StringEncoding);

	NSDictionary *parameters =
 @{
   @"grant_type"	: kRUAuth2Manager_AuthCodeGrantType,
   @"code"			: code,
   @"redirect_uri"	: encodedURI
   };

	return [self authenticateUsingOAuthWithURLString:URLString parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)authenticateUsingOAuthWithURLString:(NSString *)URLString
												   parameters:(NSDictionary *)parameters
													  success:(ru_Auth2Manager_authenticationSuccessBlock)success
													  failure:(ru_Auth2Manager_failureBlock)failure
{
	if (self.baseURL == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	if (self.session == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	NSMutableDictionary *mutableParameters = [parameters mutableCopy];
	if (self.clientId)
	{
		[mutableParameters setObject:self.clientId forKey:@"client_id"];
	}
	
	if (self.secret)
	{
		[mutableParameters setObject:self.secret forKey:@"client_secret"];
	}

	parameters = [mutableParameters copy];

	return [self POST:URLString parameters:parameters success:^(NSDictionary *jsonResponse) {

		if ([jsonResponse valueForKey:@"error"]) {
			if (failure) {
				failure(RUAuth2Manager_errorFromRFC6749Section5_2Error(jsonResponse));
			}
			
			return;
		}
		
		NSString *refreshToken = [jsonResponse valueForKey:@"refresh_token"];
		if (!refreshToken || [refreshToken isEqual:[NSNull null]]) {
			refreshToken = [parameters valueForKey:@"refresh_token"];
		}
		
		RUAuthenticationCredentials* credential = [RUAuthenticationCredentials credentialWithOAuthToken:[jsonResponse valueForKey:@"access_token"] tokenType:[jsonResponse valueForKey:@"token_type"]];
		
		if (refreshToken)
		{
			// refreshToken is optional in the OAuth2 spec
			[credential setRefreshToken:refreshToken];
		}
		
		// Expiration is optional, but recommended in the OAuth2 spec. It not provide, assume distantFuture === never expires
		NSDate *expireDate = [NSDate distantFuture];
		id expiresIn = [jsonResponse valueForKey:@"expires_in"];
		if (expiresIn && ![expiresIn isEqual:[NSNull null]]) {
			expireDate = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
		}
		
		if (expireDate) {
			[credential setExpiration:expireDate];
		}

		if (success)
		{
			success(credential);
		}

	} failure:failure];
}

#pragma mark - Requests
- (NSURLSessionDataTask *)URLSessionDataTaskWithRequest:(NSURLRequest*)URLRequest
												success:(ru_Auth2Manager_successBlock)success
												failure:(ru_Auth2Manager_failureBlock)failure
{
	if (self.session == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	if (URLRequest == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	void (^dispatchToCorrectThread)(void (^blockToRun)(void)) = ^(void (^blockToRun)(void)){
		if (blockToRun)
		{
			dispatch_queue_t queue = (self.completionQueue ?: dispatch_get_main_queue());
			if (queue)
			{
				dispatch_async(queue, ^{
					blockToRun();
				});
			}
			else
			{
				NSAssert(false, @"Should always have a queue");
				blockToRun();
			}
		}
	};
	
	void (^failureCheckBlock)(NSError* error) = ^(NSError* error){
		dispatchToCorrectThread(^{
			if (failure)
			{
				failure(error);
			}
		});
	};
	
	void (^successCheckBlock)(id jsonResponse) = ^(id jsonResponse){
		dispatchToCorrectThread(^{
			if (success)
			{
				success(jsonResponse);
			}
		});
	};
	
	NSURLSessionDataTask* URLSessionDataTask = [self.session dataTaskWithRequest:URLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		
		if (error ||
			(response == nil) ||
			(data == nil))
		{
			failureCheckBlock(error);
			return;
		}
		
		NSError* jsonParseError = nil;
		id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParseError];
		
		if (jsonParseError)
		{
			failureCheckBlock(jsonParseError);
			return;
		}

		successCheckBlock(jsonData);
		
	}];
	
	[URLSessionDataTask resume];
	return URLSessionDataTask;
}

-(void)applyParameters:(id)parameters toHTTPBodyOfRequest:(NSMutableURLRequest*)URLRequest
{
	NSError* jsonError = nil;
	NSString* parametersString = [self URLStringWithParameters:parameters withBaseURLString:nil];
	NSData* parameterData = [parametersString dataUsingEncoding:NSUTF8StringEncoding];
	
	if (jsonError)
	{
		NSAssert(false, @"unhandled");
		return;
	}
	
	[URLRequest setHTTPBody:parameterData];
}

-(NSString*)URLStringWithParameters:(id)parameters withBaseURLString:(NSString*)URLString
{
	NSMutableString* mutableURLString = (URLString ? [URLString mutableCopy] : [NSMutableString string]);

	if (parameters)
	{
		if ([parameters isKindOfClass:[NSDictionary class]])
		{
			NSDictionary* parametersDictionary = [parameters copy];
			NSMutableArray* keyObjectComponentsArray = [NSMutableArray arrayWithCapacity:parametersDictionary.count];
			[parametersDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				
				[keyObjectComponentsArray addObject:[NSString stringWithFormat:@"%@=%@",key,obj]];

			}];

			if (keyObjectComponentsArray.count > 0)
			{
				if (mutableURLString.length > 0)
				{
					[mutableURLString appendString:@"?"];
				}

				[mutableURLString appendString:[keyObjectComponentsArray componentsJoinedByString:@"&"]];
			}
		}
		else
		{
			NSAssert(false, @"unhandled");
		}
	}

	return mutableURLString;
}

-(NSURL*)URLWithString:(NSString*)URLString parameters:(id)parameters HTTPMethodType:(RUAuth2Manager_HTTPMethodType)HTTPMethodType
{
	if (parameters &&
		([[self class]HTTPMethodTypeEncodesParametersIntoFormBody:HTTPMethodType] == false))
	{
		URLString = [self URLStringWithParameters:parameters withBaseURLString:URLString];
	}

	return [NSURL URLWithString:URLString relativeToURL:self.baseURL];
}

+(BOOL)HTTPMethodTypeEncodesParametersIntoFormBody:(RUAuth2Manager_HTTPMethodType)HTTPMethodType
{
	switch (HTTPMethodType)
	{
		case RUAuth2Manager_HTTPMethodType_POST:
		case RUAuth2Manager_HTTPMethodType_PUT:
		case RUAuth2Manager_HTTPMethodType_PATCH:
			return YES;
			
		case RUAuth2Manager_HTTPMethodType_GET:
		case RUAuth2Manager_HTTPMethodType_DELETE:
			return NO;
	}

	NSAssert(false, @"unhandled");
}

- (NSMutableURLRequest *)URLRequestURLString:(NSString*)URLString
								  parameters:(id)parameters
							  HTTPMethodType:(RUAuth2Manager_HTTPMethodType)HTTPMethodType
{
	if (URLString.length == 0)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	NSURL *URL = [self URLWithString:URLString parameters:parameters HTTPMethodType:HTTPMethodType];
	if (URL == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	NSMutableURLRequest *mutableURLRequest = [NSMutableURLRequest requestWithURL:URL];
	[mutableURLRequest setHTTPMethod:[[self class]requestHTTPMethodForType:HTTPMethodType]];

	if (parameters)
	{
		if ([[self class]HTTPMethodTypeEncodesParametersIntoFormBody:HTTPMethodType])
		{
			[self applyParameters:parameters toHTTPBodyOfRequest:mutableURLRequest];
			[mutableURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		}
		else
		{
			[mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		}
	}

	[self.session.configuration.HTTPAdditionalHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[mutableURLRequest setValue:obj forHTTPHeaderField:key];
	}];

	return mutableURLRequest;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
					parameters:(id)parameters
					   success:(ru_Auth2Manager_successBlock)success
					   failure:(ru_Auth2Manager_failureBlock)failure
{
	NSMutableURLRequest *request = [self URLRequestURLString:URLString parameters:parameters HTTPMethodType:RUAuth2Manager_HTTPMethodType_POST];
	if (request == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	return [self URLSessionDataTaskWithRequest:request success:success failure:failure];
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
				   parameters:(id)parameters
					  success:(ru_Auth2Manager_successBlock)success
					  failure:(ru_Auth2Manager_failureBlock)failure
{
	NSMutableURLRequest *request = [self URLRequestURLString:URLString parameters:parameters HTTPMethodType:RUAuth2Manager_HTTPMethodType_PUT];
	if (request == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	return [self URLSessionDataTaskWithRequest:request success:success failure:failure];
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
				   parameters:(id)parameters
					  success:(ru_Auth2Manager_successBlock)success
					  failure:(ru_Auth2Manager_failureBlock)failure
{
	NSMutableURLRequest *request = [self URLRequestURLString:URLString parameters:parameters HTTPMethodType:RUAuth2Manager_HTTPMethodType_GET];
	if (request == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	return [self URLSessionDataTaskWithRequest:request success:success failure:failure];
}

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString
					 parameters:(id)parameters
						success:(ru_Auth2Manager_successBlock)success
						failure:(ru_Auth2Manager_failureBlock)failure
{
	NSMutableURLRequest *request = [self URLRequestURLString:URLString parameters:parameters HTTPMethodType:RUAuth2Manager_HTTPMethodType_PATCH];
	if (request == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	return [self URLSessionDataTaskWithRequest:request success:success failure:failure];
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
				   parameters:(id)parameters
					  success:(ru_Auth2Manager_successBlock)success
					  failure:(ru_Auth2Manager_failureBlock)failure
{
	NSMutableURLRequest *request = [self URLRequestURLString:URLString parameters:parameters HTTPMethodType:RUAuth2Manager_HTTPMethodType_DELETE];
	if (request == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	return [self URLSessionDataTaskWithRequest:request success:success failure:failure];
}

+(NSString*)requestHTTPMethodForType:(RUAuth2Manager_HTTPMethodType)HTTPMethodType
{
	switch (HTTPMethodType)
	{
		case RUAuth2Manager_HTTPMethodType_GET:
			return @"GET";

		case RUAuth2Manager_HTTPMethodType_POST:
			return @"POST";

		case RUAuth2Manager_HTTPMethodType_PUT:
			return @"PUT";
			
		case RUAuth2Manager_HTTPMethodType_DELETE:
			return @"DELETE";
			
		case RUAuth2Manager_HTTPMethodType_PATCH:
			return @"PATCH";
	}

	NSAssert(false, @"unhandled");
	return nil;
}

@end
