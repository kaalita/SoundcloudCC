//
//  AsyncImageLoader.m
//
//  Created by Katrin Apel on 5/6/12.
//  Copyright (c) 2012 Founder Lingster. All rights reserved.
//

#import "AsyncImageLoader.h"
#import "ASIHTTPRequest.h"

@interface AsyncImageLoader ()
{
    NSMutableArray* pendingImages;
	NSMutableDictionary* loadedImages;
	NSOperationQueue *downloadQueue;
}

- (UIImage*)loadImage:(NSURL*)url;

@end

@implementation AsyncImageLoader

- (id)init
{
    self = [super init];
    if (self)
    {
        pendingImages = [[NSMutableArray alloc] initWithCapacity: 10];
        loadedImages = [[NSMutableDictionary alloc] initWithCapacity: 50];
        downloadQueue = [[NSOperationQueue alloc] init];
        [downloadQueue setMaxConcurrentOperationCount: 3];
    }
    
    return self;
}

static AsyncImageLoader *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        sharedSingleton = [[AsyncImageLoader alloc] init];
    }
}

+ (UIImage*)loadImage:(NSURL *)url
{
    return [sharedSingleton loadImage:url];
}

- (UIImage*)loadImage:(NSURL *)url {
    
	UIImage* img = [loadedImages objectForKey:url];
    if (img) {
        return img;
    }
    
    if ([pendingImages containsObject:url]) {
        // already being downloaded
        return nil;
    }
    [pendingImages addObject:url];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(imageDone:)];
    [request setDidFailSelector:@selector(imageWentWrong:)];
    [downloadQueue addOperation:request];
    return nil;
}

- (void)imageDone:(ASIHTTPRequest*)request
{
    UIImage* image = [[UIImage alloc] initWithData:[request responseData]];
	if (!image) {
		return;
	}
	
	[pendingImages removeObject: request.originalURL];
	[loadedImages setObject:image
                     forKey:request.originalURL];
	
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              request.originalURL.absoluteString, @"url",
                              image, @"image",
                              nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"ImageDownloadFinished"
                                                        object: self
                                                      userInfo: userInfo];
}

- (void)imageWentWrong:(ASIHTTPRequest*)request
{
	NSLog(@"%@ - Image download failed with error: %@", request.originalURL,[[request error] localizedDescription]);
	[pendingImages removeObject: request.originalURL];
}


@end
