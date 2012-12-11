//
//  MainViewController.m
//  SoundcloudCC
//
//  Created by Katrin on 12/11/12.
//  Copyright (c) 2012 Katrin Apel. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SCUI.h"
#import "TrackCell.h"

@interface MainViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *tracks;
@property (strong, nonatomic) UIButton *loginLogoutButton;

@end

@implementation MainViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    if(self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleImageLoadedNotification:)
                                                     name: @"ImageDownloadFinished"
                                                   object: nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                               42,
                                                               [UIScreen mainScreen].bounds.size.width,
                                                               self.view.bounds.size.height - 42*2)];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.22f green:0.22f blue:0.22f alpha:1.00f];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = [TrackCell cellHeight];
    [self.view addSubview:_tableView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  self.view.bounds.size.width,
                                                                  42)];
    headerView.backgroundColor = [UIColor colorWithRed:0.14f green:0.14f blue:0.14f alpha:1.00f];
    
    headerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:headerView.bounds].CGPath;
    headerView.layer.shadowColor = [UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.00f].CGColor;
    headerView.layer.shadowOffset = CGSizeMake(0,1);
    headerView.layer.shadowOpacity = 0.8;
    headerView.layer.shadowRadius = 1;
    [self.view addSubview:headerView];
    
    UILabel *headline = [[UILabel alloc] initWithFrame:CGRectMake(6,
                                                                  6,
                                                                  headerView.bounds.size.width - 12,
                                                                  headerView.bounds.size.height - 12)];
    headline.text = @"Favorite tracks";
    headline.font = [UIFont boldSystemFontOfSize:16];
    headline.textAlignment = UITextAlignmentCenter;
    headline.backgroundColor = headerView.backgroundColor;
    headline.textColor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
    [headerView addSubview:headline];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  self.view.bounds.size.height - 42,
                                                                  self.view.bounds.size.width,
                                                                  42)];
    footerView.backgroundColor = [UIColor colorWithRed:0.14f green:0.14f blue:0.14f alpha:1.00f];
    footerView.layer.borderColor = [UIColor colorWithRed:0.00f green:0.00f blue:0.00f alpha:1.00f].CGColor;
    footerView.layer.borderWidth = 1;
    footerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:headerView.bounds].CGPath;
    footerView.layer.shadowColor = [UIColor colorWithRed:0.22f green:0.22f blue:0.22f alpha:1.00f].CGColor;
    footerView.layer.shadowOffset = CGSizeMake(0, -3);
    footerView.layer.shadowOpacity = 0.8;
    footerView.layer.shadowRadius = 1;
    headerView.clipsToBounds = NO;
    [self.view addSubview:footerView];
    
    _loginLogoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [footerView addSubview:_loginLogoutButton];
    
    [self updateViewToLoginStatus];
}

- (void) loadTracks
{
    SCAccount *account = [SCSoundCloud account];
    if (account == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Not Logged In"
                                                        message: @"You must login first"
                                                       delegate: nil
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            self.tracks = (NSArray *)jsonResponse;
            [self.tableView reloadData];
        }
    };
    
    NSString *resourceURL = @"https://api.soundcloud.com/me/favorites.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
}

- (void) updateViewToLoginStatus
{
    SCAccount *account = [SCSoundCloud account];
    if (account)
    {
        
        UIImage *img = [UIImage imageNamed:@"soundcloud_disconnect.png"];
        [_loginLogoutButton setImage: img
                            forState: UIControlStateNormal];
        
        [_loginLogoutButton removeTarget: self
                                  action: @selector(login)
                        forControlEvents: UIControlEventTouchUpInside];
        
        [_loginLogoutButton addTarget: self
                               action: @selector(logout)
                     forControlEvents: UIControlEventTouchUpInside];
        
        [self loadTracks];
    }
    else
    {
        UIImage *img = [UIImage imageNamed:@"btn-connect-l.png"];
        [_loginLogoutButton setImage: img
                            forState: UIControlStateNormal];
        
        [_loginLogoutButton removeTarget: self
                                  action: @selector(logout)
                        forControlEvents: UIControlEventTouchUpInside];
        [_loginLogoutButton addTarget: self
                               action: @selector(login)
                     forControlEvents: UIControlEventTouchUpInside];
        
        self.tracks = nil;
        [self.tableView reloadData];
    }
    
    _loginLogoutButton.frame = CGRectMake((_loginLogoutButton.superview.frame.size.width
                                           - _loginLogoutButton.imageView.image.size.width)/2,
                                          (_loginLogoutButton.superview.frame.size.height
                                           - _loginLogoutButton.imageView.image.size.height)/2,
                                          _loginLogoutButton.imageView.image.size.width,
                                          _loginLogoutButton.imageView.image.size.height);
    [_loginLogoutButton setNeedsDisplay];
}

- (void) logout
{
    [SCSoundCloud removeAccess];
    [self updateViewToLoginStatus];
}

- (void) login
{
    SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Done with identifier: %@",[SCSoundCloud account].identifier);
            [self updateViewToLoginStatus];
        }
    };
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController;
        
        loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL: preparedURL
                                                                      completionHandler: handler];
        
        [self presentModalViewController: loginViewController
                                animated: YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"TrackCell";
    TrackCell *cell = (TrackCell*) [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[TrackCell alloc] initWithStyle: UITableViewCellStyleDefault
                                reuseIdentifier: cellID];
    }
    
    NSDictionary *track = [self.tracks objectAtIndex: indexPath.row];
    [cell updateCellWithTrack: track];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *selectedTrack = [self.tracks objectAtIndex: indexPath.row];
    NSURL *appURL = [NSURL URLWithString:
                     [NSString stringWithFormat:@"soundcloud:tracks:%@",
                      [selectedTrack valueForKey:@"id"]]];
    
    // Open track in Soundcloud app, if installed
    if([[UIApplication sharedApplication] canOpenURL:appURL])
    {
        [[UIApplication sharedApplication] openURL:appURL];
    }
    // Otherwise open track in Browser
    else {
        NSURL *soundcloudURL = [NSURL URLWithString:[selectedTrack valueForKey:@"permalink_url"]];
        [[UIApplication sharedApplication] openURL:soundcloudURL];
    }
}

- (void) handleImageLoadedNotification:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
        
        if([[track valueForKey:@"waveform_url"] isEqualToString:[dict valueForKey:@"url"]])
        {
            TrackCell *cell = (TrackCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell displayImage:[dict valueForKey:@"image"]];
        }
    }
}

@end
