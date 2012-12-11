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
#import "DateTimeUtils.h"

@interface MainViewController ()
{
    NSDate *lastUpdate;
    UIActivityIndicatorView *loadMoreSpinner;
}

@property (strong, nonatomic) NSArray *tracks;
@property (strong, nonatomic) UIButton *loginLogoutButton;

- (void) updateViewToLoginStatus;

@end

@implementation MainViewController

@synthesize tracks = _tracks;
@synthesize loginLogoutButton = _loginLogoutButton;

static int maxTracksPerPage = 50;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    if(self = [super init])
    {
        // Register the controller for the notifications from the AsyncImageLoader
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

    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    self.title = @"Favorite tracks";
    
    [self.navigationController setToolbarHidden:NO];
    [self.navigationController.toolbar setBarStyle: UIBarStyleBlackOpaque];
    
    _loginLogoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navigationController.toolbar addSubview:_loginLogoutButton];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.22f green:0.22f blue:0.22f alpha:1.00f];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = [TrackCell cellHeight];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                              0,
                                                                              self.tableView.frame.size.width,
                                                                              40)];
    self.tableView.tableFooterView.backgroundColor = self.tableView.backgroundColor;

    loadMoreSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadMoreSpinner.frame = CGRectMake((self.tableView.tableFooterView.frame.size.width - 40.0)/2,
                               0,
                               40.0,
                               40.0);
    [self.tableView.tableFooterView addSubview:loadMoreSpinner];
    
    [self updateViewToLoginStatus];
}

/**
 * Loads favorite tracks of the user from the Soundcloud server
 * Refreshes tableview when finished
 */
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
            lastUpdate = [NSDate date];
            [self.tableView reloadData];
        }
    };
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat: @"%i",maxTracksPerPage], @"limit",
                            nil];
    
    NSString *resourceURL = @"https://api.soundcloud.com/me/favorites.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:params
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
}

- (void) loadMore
{
    [loadMoreSpinner startAnimating];
    
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.tracks];
            [newArray addObjectsFromArray:(NSArray *)jsonResponse];
            self.tracks = newArray;
            [loadMoreSpinner stopAnimating];
            [self.tableView reloadData];
        }
    };
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%i",maxTracksPerPage], @"limit",
                            [NSString stringWithFormat:@"%i",[self.tracks count]], @"offset",
                            nil];
    
    NSString *resourceURL = @"https://api.soundcloud.com/me/favorites.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:params
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:nil
             responseHandler:handler];
}

/**
 * Updates the view according to the current login status of the user:
 * if logged in: show logout button and start track download
 * if logged out: show login button and clear tableview
 */
- (void) updateViewToLoginStatus
{
    SCAccount *account = [SCSoundCloud account];
    if (account)
    {
        UIImage *img = [UIImage imageNamed:@"btn-disconnect-l.png"];
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

/**
 * Logout from Soundcloud
 */
- (void) logout
{
    [SCSoundCloud removeAccess];
    [self updateViewToLoginStatus];
}

/**
 * Login to Soundcloud
 */
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

/**
 * Handle the notification from the AsyncImageLoader
 * iterates through all visible cells and udaptes cell image when the url of the image matches the one of the cell image
 */
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

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDragging:(UIScrollView *)myscrollView willDecelerate:(BOOL)decelerate
{
    if (myscrollView.contentOffset.y > self.tableView.frame.size.height - self.tableView.tableFooterView.frame.size.height)
    {
        //start loading more tracks
        [self loadMore];
    }
}

@end
