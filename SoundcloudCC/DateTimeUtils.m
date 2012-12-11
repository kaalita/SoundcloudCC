//
//  DateTimeUtils.m
//
//  Created by Katrin Apel on 5/6/12.
//  Copyright (c) 2012 Founder Lingster. All rights reserved.
//

#import "DateTimeUtils.h"

@implementation DateTimeUtils

static NSString* dateFormat = @"yyyy/MM/dd' 'HH:mm:ss' 'ZZZ";

+ (NSString*) stringFromDate:(NSDate*) date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle: NSDateFormatterMediumStyle];
    NSString *myDateString = [dateFormatter stringFromDate:date];
    return myDateString;
}

+ (NSString *) dateDiffStringPast:(NSDate*) date
{
    double timeInterval = [date timeIntervalSinceDate: [NSDate date]];
    timeInterval = timeInterval * -1;
    
    int diff;
    NSString *timeUnit;
    
    // Define standard time intervals
    int oneMinute = 60;
    int oneHour = oneMinute * 60;
    int oneDay = oneHour * 24;
    int oneWeek = oneDay * 7;
    int oneMonth = oneWeek * 4;
    int oneYear = oneMonth * 12;
    
    // Timeinterval is less than 1 minute
    if(timeInterval < oneMinute)
    {
        return @"just now";
    }
    // Timeinterval is less than 1 hour
    else if (timeInterval < oneHour)
    {
        diff = (int) timeInterval / oneMinute;
        timeUnit = diff == 1 ? @"minute" : @"minutes";
    }
    // Timeinterval is less than 1 day
    else if (timeInterval < oneDay)
    {
        diff = (int) timeInterval / oneHour;
        timeUnit = diff == 1 ? @"hour" : @"hours";
    }
    // Timeinterval is less than 1 week
    else if (timeInterval < oneWeek)
    {
        diff = (int) timeInterval / oneDay;
        timeUnit = diff == 1 ? @"day" : @"days";
    }
    // Timeinterval is less than 1 month
    else if (timeInterval < oneMonth)
    {
        diff = (int) timeInterval / oneWeek;
        timeUnit = diff == 1 ? @"week" : @"weeks";
    }
    // Timeinterval is less than 1 year
    else if (timeInterval < oneYear)
    {
        diff = (int) timeInterval / oneMonth;
        timeUnit = diff == 1 ? @"month" : @"months";
    }
    // Timeinterval is less than 1 year
    else if (timeInterval < oneYear)
    {
        diff = (int) timeInterval / oneMonth;
        timeUnit = diff == 1 ? @"month" : @"months";
    }
    // Timeinterval is more than 1 year
    else
    {
        diff = (int) timeInterval / oneYear;
        timeUnit = diff == 1 ? @"year" : @"years";
    }
    
    return [NSString stringWithFormat:@"%d %@ ago", diff, timeUnit];
}

+ (NSString *)getHumanReadableTimeFrom:(NSString *)timestamp
{
    return [self dateDiffStringPast:[self dateFromJsonTimestamp: timestamp]];
}

+ (NSDate*) dateFromJsonTimestamp: (NSString*) timestamp
{
    NSDateFormatter *sFormatter = [[NSDateFormatter alloc] init];
    sFormatter.dateFormat = dateFormat;
    
    return [sFormatter dateFromString: timestamp];
}

@end
