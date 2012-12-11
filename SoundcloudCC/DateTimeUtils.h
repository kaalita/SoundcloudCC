//
//  DateTimeUtils.h
//
//  Created by Katrin Apel on 5/6/12.
//  Copyright (c) 2012 Founder Lingster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateTimeUtils : NSObject

/**
 * Parses a string in the format "yyyy/MM/dd' 'HH:mm:ss' 'ZZZ" and 
 * returns  a string to show the time difference in a human readable format
 * e.g: "3 days ago", "1 week ago"
 * @param timestamp  String in the format "yyyy/MM/dd' 'HH:mm:ss' 'ZZZ"
 * @return  Time difference to current date in a human readable format
 */
+ (NSString*) getHumanReadableTimeFrom: (NSString*) timestamp;

+ (NSDate *) dateFromJsonTimestamp: (NSString *) timestamp;
+ (NSString *) dateDiffStringPast: (NSDate *)date;

@end
