//
//  SoundCloudLoginWebViewController.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun on 08/03/15.
//  Copyright (c) 2015 Brun's Software. All rights reserved.
//

#import "SoundCloudLoginWebViewController.h"

@interface SoundCloudLoginWebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webViewContainer;
@end

// Shows scLoginURL related screen. Checking URL response wait for a success or failure login to call resultBlock
@implementation SoundCloudLoginWebViewController

+ (UINavigationController *)instantiateWithLoginURL:(NSString *)loginURL redirectURL:(NSString *)redirectURL resultBlock:(void (^)(BOOL result, NSString *code))resultBlock {
    UINavigationController *navController = [[UIStoryboard storyboardWithName:@"SoundCloudLogin" bundle:nil] instantiateInitialViewController];
    SoundCloudLoginWebViewController *loginVC = [navController.viewControllers firstObject];
    if (loginVC) {
        loginVC.scLoginURL = [loginURL stringByAppendingFormat:@"&redirect_uri=%@",redirectURL];
        loginVC.redirectURL = redirectURL;
        loginVC.resultBlock = resultBlock;
    }
    return navController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.webViewContainer loadRequest:[self webURLForLogin]];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        self.resultBlock(NO, nil);
    }];
}

- (NSURLRequest *)webURLForLogin {
    NSAssert(self.scLoginURL!=nil, @"Login url has to be set before load the view.");
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.scLoginURL]];
    return request;
}

- (NSString *)extractCodeFromRequest:(NSURLRequest *)request {
    NSArray *codeArray =[request.URL.absoluteString componentsSeparatedByString:@"code="];
    if(codeArray.count>1) {
        NSString *code = codeArray[1];
        if([code hasSuffix:@"#"]) {
            code = [code substringToIndex:code.length-1];
            return code;
        }
    }
    return nil;
}

- (BOOL)isFlowFinishWithRequest:(NSURLRequest *)request {
	NSString* scheme = request.URL.scheme;
	if (scheme == nil)
	{
		return NO;
	}

	NSString* host = request.URL.host;
	if (host == nil)
	{
		return NO;
	}

	NSString *baseURL = [@[scheme, host] componentsJoinedByString:@"://"];
    return [baseURL rangeOfString:self.redirectURL].location!=NSNotFound;
}

- (void)finishFlowWithRequest:(NSURLRequest *)request {
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *code = [self extractCodeFromRequest:request];
        self.resultBlock(code!=nil, code);
    }];
}

#pragma mark - WebView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([self isFlowFinishWithRequest:request]) {
        [self finishFlowWithRequest:request];
        return NO;
    }
    
    return YES;
}

@end
