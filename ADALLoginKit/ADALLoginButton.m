//
//  ADALLoginButton.m
//  ADALLoginKit
//
//  Created by Brandon Werner on 7/6/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

#import "ADALLoginButton.h"
#import <UIKit/UIKit.h>
#import "ADAL/ADAL.h"
#import "SamplesApplicationData.h"
#import "ADAL/ADAuthenticationContext.h"


@interface ADALLoginButton()

- (NSString *) _shortLogInTitle;
- (NSString *) _longLogInTitle;
- (NSString *) _logOutTitle;


@end

@implementation ADALLoginButton
{

    NSString *_userID;
    NSString *_userName;
}

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





#
#pragma mark - ADALButton

- (void)configureButton
{
    
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    
    ADAuthenticationError* error = nil;
    ADAuthenticationContext* context = [[ADAuthenticationContext alloc] initWithAuthority:data.authority
                                                                        validateAuthority:true
                                                                                    error:&error];
    
    NSString *logInTitle = [self _shortLogInTitle];
    NSString *logOutTitle = [self _logOutTitle];
    
    [self configureWithIcon:nil
                      title:logInTitle
            backgroundColor:[super defaultBackgroundColor]
           highlightedColor:nil
              selectedTitle:logOutTitle
               selectedIcon:nil
              selectedColor:[super defaultBackgroundColor]
   selectedHighlightedColor:nil];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self _updateContent];
    
    [self addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_accessTokenDidChangeNotification:)
                                                 name:AccessTokenDidChangeNotification
                                               object:nil];

#pragma mark - Helper Methods
    
- (void)_buttonPressed:(id)sender
{
    [self logTapEventWithEventName:AppEventNameADALLoginButtonDidTap parameters:[self analyticsParameters]];
    if ([**** currentAccessToken]) {
        NSString *title = nil;
        
        if (_userName) {
            NSString *localizedFormatString =
            NSLocalizedStringWithDefaultValue(@"LoginButton.LoggedInAs", @"ADAL",
                                              @"Logged in as %@",
                                              @"The format string for the ADALLoginButton label when the user is logged in");
            title = [NSString StringWithFormat: _userName];
        } else {
            NSString *localizedLoggedIn =
            NSLocalizedStringWithDefaultValue(@"LoginButton.LoggedIn", @"ADAL",
                                              @"Logged in using Facebook",
                                              @"The fallback string for the ADALLoginButton label when the user name is not available yet");
            title = localizedLoggedIn;
        }
        NSString *cancelTitle =
        NSLocalizedStringWithDefaultValue(@"LoginButton.CancelLogout", @"ADAL",
                                          @"Cancel",
                                          @"The label for the ADALLoginButton action sheet to cancel logging out");
        NSString *logOutTitle =
        NSLocalizedStringWithDefaultValue(@"LoginButton.ConfirmLogOut", @"ADAL",
                                          @"Log Out",
                                          @"The label for the ADALLoginButton action sheet to confirm logging out");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title
                                                           delegate:self
                                                  cancelButtonTitle:cancelTitle
                                             destructiveButtonTitle:logOutTitle
                                                  otherButtonTitles:nil];
        [sheet showInView:self];
#pragma clang diagnostic pop
    } else {
        if ([self.delegate respondsToSelector:@selector(loginButtonWillLogin:)]) {
            if (![self.delegate loginButtonWillLogin:self]) {
                return;
            }
        }
        
        ADAuthenticationContextRequestTokenHandler handler = ^(ADAuthenticationContextLoginResult *result, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(loginButton:didCompleteWithResult:error:)]) {
                [self.delegate loginButton:self didCompleteWithResult:result error:error];
            }
        };
        
        if (self.publishPermissions.count > 0) {
            [_loginManager logInWithPublishPermissions:self.publishPermissions
                                    fromViewController:[ADALInternalUtility viewControllerForView:self]
                                               handler:handler];
        } else {
            [_loginManager logInWithReadPermissions:self.readPermissions
                                 fromViewController:[ADALInternalUtility viewControllerForView:self]
                                            handler:handler];
        }
    }
}

    - (NSString *)_logOutTitle
    {
        return NSString(@"Log Out");
        
    }
    
    - (NSString *)_longLogInTitle
    {
        return NSString(@"Log In");
    }
    
    - (NSString *)_shortLogInTitle
    {
        return NSString(@"Log in");
    }

- (void)_updateContent
{
    self.selected = ([ **** currentAccessToken] != nil);
    if ([ADALAccessToken currentAccessToken]) {
        if (![[**** currentAccessToken].userID isEqualToString:_userID]) {
            ADALGraphRequest *request = [[ADALGraphRequest alloc] initWithGraphPath:@"me?fields=id,name"
                                                                           parameters:nil];
            [request startWithCompletionHandler:^(ADALRequestConnection *connection, id result, NSError *error) {
                NSString *userID = [ADALTypeUtility stringValue:result[@"id"]];
                if (!error && [[ADALAccessToken currentAccessToken].userID isEqualToString:userID]) {
                    _userName = [ADALTypeUtility stringValue:result[@"name"]];
                    _userID = userID;
                }
            }];
        }
    }
}

@end
