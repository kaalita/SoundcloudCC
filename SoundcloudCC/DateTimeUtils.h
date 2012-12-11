//
//  DateTimeUtils.h
//
//  Created by Katrin Apel on 5/6/12.
//  Copyright (c) 2012 Founder Lingster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateTimeUtils : NSObject

+ (NSString*) getHumanReadableTimeFrom: (NSString*) timestamp;

+ (NSString *) stringFromDate: (NSDate *)date;
+ (NSDate *) dateFromJsonTimestamp: (NSString *) timestamp;
+ (NSString *) dateDiffStringPast: (NSDate *)date;

@end
