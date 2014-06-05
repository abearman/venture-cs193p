//
// Created by Keenon Werling on 5/24/14.
// Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VentureLocationTracker;

@interface VentureServerLayer : NSObject

@property NSArray *suggestions;

-(id)initWithLocationTracker:(VentureLocationTracker *)tracker;

-(int)numberOfCachedAdventures;
-(NSMutableDictionary *)getCachedAdventureAtIndex:(int)i;
-(NSMutableDictionary *)getPreviousCachedAdventureOrNull:(NSMutableDictionary *)cachedAdventure;
-(NSMutableDictionary *)getNextCachedAdventureOrNull:(NSMutableDictionary *)cachedAdventure;
-(void)getNewAdventureSuggestion:(void (^)(NSMutableDictionary *))callback;
-(void)rateAdventure:(int)adventureId rating:(int)rating;
-(void)associateFacebook:(NSString*)fuid;
-(void)submitAdventure:(NSDictionary *)adventure;

@end