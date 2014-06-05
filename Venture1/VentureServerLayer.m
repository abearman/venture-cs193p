//
// Created by Keenon Werling on 5/24/14.
// Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "VentureServerLayer.h"
#import "VentureLocationTracker.h"
#import "NSDictionary+URLEncoding.h"

#define SERVER_BASE_URL @"http://128.12.18.127:9000"

@implementation VentureServerLayer {
    VentureLocationTracker *tracker;
    NSMutableArray *cachedAdventures;
}

-(id)initWithLocationTracker:(VentureLocationTracker *)t {
    self = [super init];
    if (self) {
        tracker = t;
        _suggestions = [[NSMutableArray alloc] init];
        cachedAdventures = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark public

-(int)numberOfCachedAdventures {
    return [cachedAdventures count];
}

-(NSMutableDictionary *)getCachedAdventureAtIndex:(int)i {
    return [cachedAdventures objectAtIndex:i];
}

-(NSMutableDictionary *)getPreviousCachedAdventureOrNull:(NSMutableDictionary *)cachedAdventure {
    int index = [cachedAdventures indexOfObject:cachedAdventure];
    NSLog(@"Cached adventure has index for this adventure of %i",index);
    if (index > 0) return [cachedAdventures objectAtIndex:index-1];
    return NULL;
}

-(NSMutableDictionary *)getNextCachedAdventureOrNull:(NSMutableDictionary *)cachedAdventure {
    int index = [cachedAdventures indexOfObject:cachedAdventure];
    if (index < [cachedAdventures count] - 1) return [cachedAdventures objectAtIndex:index+1];
    return NULL;
}

-(void)getNewAdventureSuggestion:(void (^)(NSMutableDictionary *))callback {
    [self makeCallToVentureServer:@"/get-suggestion" callback:^(NSMutableDictionary *adventure) {
        if (adventure != nil) {
            if ([cachedAdventures containsObject:adventure]) [cachedAdventures removeObject:adventure];
            [cachedAdventures addObject:adventure];
            callback(adventure);
        }
    }];
}

-(void)rateAdventure:(int)adventureId rating:(int)rating {
    NSDictionary *data = @{
            @"adventure_id" : [NSString stringWithFormat:@"%i",adventureId],
            @"rating" : [NSString stringWithFormat:@"%i",rating],
    };
    [self makeCallToVentureServer:@"/rate-adventure" additionalData:data];
}

-(void)associateFacebook:(NSString*)fb_uid {
    NSDictionary *data = @{
            @"fb_uid" : fb_uid
    };
    [self makeCallToVentureServer:@"/associate-facebook" additionalData:data];
}

-(void)submitAdventure:(NSDictionary *)adventure {
    NSDictionary *data = @{
            @"adventure" : adventure
    };
    [self makeCallToVentureServer:@"/submit-adventure" additionalData:data];
}

#pragma mark private

-(void)makeCallToVentureServer:(NSString *)uri {
    [self makeCallToVentureServer:uri callback:^(NSDictionary * dict){}];
}

-(void)makeCallToVentureServer:(NSString *)uri additionalData:(NSDictionary *)additionalData {
    [self makeCallToVentureServer:uri additionalData:additionalData callback:^(NSDictionary * dict){}];
}

-(void)makeCallToVentureServer:(NSString *)uri callback:(void (^)(NSMutableDictionary *))callback {
    [self makeCallToVentureServer:uri additionalData:[[NSDictionary alloc] init] callback:callback];
}

-(void)makeCallToVentureServer:(NSString *)uri additionalData:(NSDictionary *)additionalData callback:(void (^)(NSMutableDictionary *))callback {
    NSMutableDictionary *serverData = [[NSMutableDictionary alloc] init];
    [serverData addEntriesFromDictionary:additionalData];
    [serverData setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"uid"];
    [serverData setValue:tracker.lat forKey:@"lat"];
    [serverData setValue:tracker.lng forKey:@"lng"];

    NSString *url = [NSString stringWithFormat:@"%@%@", SERVER_BASE_URL, uri];
    NSLog(@"URL: %@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/json" forHTTPHeaderField:@"Content-Type"];

    NSError *jsonError;
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:serverData options:0 error:&jsonError]];

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

    [[session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSData* data = [NSData dataWithContentsOfURL:location];
            NSError* decodeJsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:&decodeJsonError];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback([json mutableCopy]);
            });
        }
        else {
            callback(nil);
        }
    }] resume];
}
@end