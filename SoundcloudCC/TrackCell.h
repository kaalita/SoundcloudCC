//
//  TrackCell.h
//  SC-Challenge
//
//  Created by Katrin on 12/10/12.
//  Copyright (c) 2012 Katrin Apel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackCell : UITableViewCell

/** Updates an existing TrackCell to display a new track
 *  @param newTrack  The track that should be displayed in the cell
 */
- (void) updateCellWithTrack: (NSDictionary *) newTrack;

+ (float) cellHeight;

- (void) displayImage: (UIImage*) image;

@end
