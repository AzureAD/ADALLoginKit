//
//  ADALLoginButton.m
//  ADALLoginKit
//
//  Created by Brandon Werner on 7/6/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

#import "ADALLoginButton.h"

#import "ADALLoginButton.h"


@interface ADALLoginButton()
@end

@implementation ADALLoginButton
{
    BOOL _hasShownTooltipBubble;
    ADALLoginManager *_loginManager;
    NSString *_userID;
    NSString *_userName;
}

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UIView

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window &&
        ((self.tooltipBehavior == ADALLoginButtonTooltipBehaviorForceDisplay) || !_hasShownTooltipBubble)) {
        [self performSelector:@selector(_showTooltipIfNeeded) withObject:nil afterDelay:0];
        _hasShownTooltipBubble = YES;
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    CGSize size = self.bounds.size;
    CGSize longTitleSize = [self sizeThatFits:size title:[self _longLogInTitle]];
    NSString *title = (longTitleSize.width <= size.width ?
                       [self _longLogInTitle] :
                       [self _shortLogInTitle]);
    if (![title isEqualToString:[self titleForState:UIControlStateNormal]]) {
        [self setTitle:title forState:UIControlStateNormal];
    }
    
    [super layoutSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if ([self isHidden]) {
        return CGSizeZero;
    }
    CGSize selectedSize = [self sizeThatFits:size title:[self _logOutTitle]];
    CGSize normalSize = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, size.height) title:[self _longLogInTitle]];
    if (normalSize.width > size.width) {
        return normalSize = [self sizeThatFits:size title:[self _shortLogInTitle]];
    }
    return CGSizeMake(MAX(normalSize.width, selectedSize.width), MAX(normalSize.height, selectedSize.height));
}

#pragma mark - UIActionSheetDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        ADAuthenticationContext *login = [[ADAuthenticationContext alloc] init];
        [login logOut];
        [self.delegate loginButtonDidLogOut:self];
    }
}


#pragma mark - ADALButton

- (void)configureButton
{
    _loginManager = [[ADAuthenticationContext alloc] init];
    
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
}

#pragma mark - Helper Methods

- (void)_accessTokenDidChangeNotification:(NSNotification *)notification
{
    if (notification.userInfo[AccessTokenDidChangeUserID]) {
        [self _updateContent];
    }
}

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
            title = [NSString localizedStringWithFormat:localizedFormatString, _userName];
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
    return NSLocalizedStringWithDefaultValue(@"LoginButton.LogOut", @"ADAL",
                                             @"Log out",
                                             @"The label for the ADALLoginButton when the user is currently logged in");
    ;
}

- (NSString *)_longLogInTitle
{
    return NSLocalizedStringWithDefaultValue(@"LoginButton.LogInLong", @"ADAL",
                                             @"Log in with Facebook",
                                             @"The long label for the ADALLoginButton when the user is currently logged out");
}

- (NSString *)_shortLogInTitle
{
    return NSLocalizedStringWithDefaultValue(@"LoginButton.LogIn", @"ADAL",
                                             @"Log in",
                                             @"The short label for the ADALLoginButton when the user is currently logged out");
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
