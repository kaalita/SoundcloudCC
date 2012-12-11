//
//  TrackCell.m
//  SC-Challenge
//
//  Created by Katrin on 12/10/12.
//  Copyright (c) 2012 Katrin Apel. All rights reserved.
//

#import "TrackCell.h"
#import <QuartzCore/QuartzCore.h>
#import "DateTimeUtils.h"
#import "AsyncImageLoader.h"

@interface TrackCell ()

@property (nonatomic, strong) NSDictionary *track;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *trackLabel;
@property (nonatomic, strong) UIImageView *waveImageView;

@end

@implementation TrackCell

static const float WAVE_IMAGE_WIDTH = 1800;
static const float WAVE_IMAGE_HEIGHT = 280;
static const float DATE_Y_OFFSET = 6;
static const float DATE_HEIGHT = 18;
static const float TITLE_Y_OFFSET = 6;
static const float TITLE_HEIGHT = 24;
static const float WAVE_Y_OFFSET = 6;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                [UIScreen mainScreen].bounds.size.width,
                                self.frame.size.height);
        
        self.contentView.backgroundColor = [UIColor colorWithRed:0.22f green:0.22f blue:0.22f alpha:1.00f];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        // Create label for the creation date of the track
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(18,
                                                               DATE_Y_OFFSET,
                                                               self.bounds.size.width - 12*2,
                                                               DATE_HEIGHT)];
        
        _dateLabel.backgroundColor = self.contentView.backgroundColor;
        _dateLabel.textAlignment = NSTextAlignmentRight;
        _dateLabel.textColor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
        _dateLabel.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:_dateLabel];
        
        // Create view as the background for the track
        UIView *trackView = [[UIView alloc] initWithFrame:CGRectMake(6,
                                                                     _dateLabel.frame.origin.y
                                                                     + _dateLabel.frame.size.height,
                                                                     self.bounds.size.width - 6*2,
                                                                     [TrackCell cellHeight]
                                                                     - DATE_Y_OFFSET
                                                                     - DATE_HEIGHT)];
        trackView.backgroundColor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
        trackView.layer.cornerRadius = 3;
        trackView.layer.borderColor = [UIColor colorWithRed:0.14f green:0.14f blue:0.14f alpha:1.00f].CGColor;
        trackView.layer.borderWidth = 0.5;
        trackView.layer.shadowPath = [UIBezierPath bezierPathWithRect:trackView.bounds].CGPath;
        trackView.layer.shadowColor = [UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.00f].CGColor;
        trackView.layer.shadowOffset = CGSizeMake(0, 1);
        trackView.layer.shadowOpacity = 1;
        trackView.layer.shadowRadius = 1;
        [self.contentView addSubview:trackView];
        
        // Create label for track title
        _trackLabel = [[UILabel alloc] initWithFrame:CGRectMake(6,
                                                                0,
                                                                trackView.bounds.size.width - 6*2,
                                                                TITLE_HEIGHT)];
        _trackLabel.backgroundColor = trackView.backgroundColor;
        _trackLabel.textColor = [UIColor colorWithRed:0.14f green:0.14f blue:0.14f alpha:1.00f];
        _trackLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
        _trackLabel.font = [UIFont boldSystemFontOfSize:14];
        _trackLabel.adjustsFontSizeToFitWidth = YES;
        _trackLabel.minimumScaleFactor = 0.8;
        [trackView addSubview:_trackLabel];
        
        // Create image view for wave image
        
        float scaleDownFactor = 1800 / (trackView.bounds.size.width - 12);
        
        _waveImageView = [[UIImageView alloc] initWithFrame:CGRectMake((trackView.bounds.size.width
                                                                        - 1800/scaleDownFactor)/2,
                                                                       _trackLabel.frame.origin.y
                                                                       + _trackLabel.frame.size.height
                                                                       + WAVE_Y_OFFSET,
                                                                       WAVE_IMAGE_WIDTH / scaleDownFactor,
                                                                       WAVE_IMAGE_HEIGHT / scaleDownFactor)];
        [trackView addSubview:_waveImageView];
        
        self.track = nil;
        
    }
    return self;
}

- (void) updateCellWithTrack: (NSDictionary *) newTrack
{
    // Only update the cell if the newTrack differes from the track the cell currently displays
    if(self.track != newTrack)
    {
        self.track = newTrack;
        _dateLabel.text = [DateTimeUtils getHumanReadableTimeFrom: [_track objectForKey:@"created_at"]];
        _trackLabel.text = [_track objectForKey:@"title"];
        
        NSURL *imageURL = [NSURL URLWithString: [_track objectForKey:@"waveform_url"]];
        UIImage *image = [AsyncImageLoader loadImage:imageURL];
        if(image)
        {
            [self displayImage:image];
        }
        else
        {
            _waveImageView.image = nil;
            _waveImageView.backgroundColor = [UIColor lightGrayColor];
        }
    }
}

- (void) displayImage: (UIImage*) image
{
    // Create image that contains only the upper half of the original image
    CGImageRef imageToSplit = image.CGImage;
    CGImageRef partOfImageAsCG = CGImageCreateWithImageInRect(imageToSplit,
                                                              CGRectMake(0,
                                                                         0,
                                                                         image.size.width,
                                                                         image.size.height/2));
    UIImage *upperPartOfImage = [UIImage imageWithCGImage:partOfImageAsCG];
    CGImageRelease(partOfImageAsCG);
    
    _waveImageView.backgroundColor = [UIColor colorWithRed:1.00f green:0.23f blue:0.00f alpha:1.00f];
    _waveImageView.image = upperPartOfImage;
    [_waveImageView setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (float) scaleDownFactor
{
    return WAVE_IMAGE_WIDTH / ([UIScreen mainScreen].bounds.size.width - 12);
}

+ (float) cellHeight
{
    return DATE_Y_OFFSET
    + DATE_HEIGHT
    + TITLE_Y_OFFSET
    + TITLE_HEIGHT
    + WAVE_Y_OFFSET
    + WAVE_IMAGE_HEIGHT / [TrackCell scaleDownFactor];
}


@end
