//
//  AsyncImageLoader.h
//
//  Created by Katrin Apel on 5/6/12.
//  Copyright (c) 2012 Founder Lingster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncImageLoader : NSObject

/** Loads the image from the given url (asynchronously)
 * @param url  The url of the image
 * @return  Returns the image, if the image for the url was already downloaded,
 *          Returns nil, otherwise. A notification is posted when the download is finished
 */
+ (UIImage*)loadImage:(NSURL*)url;

@end

