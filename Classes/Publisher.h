//
//  Publisher.h
//  Newsstand
//
//  Created by Carlo Vigiani on 18/Oct/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>

#define CacheDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

extern  NSString *PublisherDidUpdateNotification;
extern  NSString *PublisherFailedUpdateNotification;

@interface Publisher : NSObject {
    NSArray *issues;
    
}

@property (nonatomic,readonly,getter = isReady) BOOL ready;

-(void)addIssuesInNewsstand;
-(void)getIssuesList;
-(NSInteger)numberOfIssues;
-(NSString *)titleOfIssueAtIndex:(NSInteger)index;
-(NSString *)descriptionOfIssueAtIndex:(NSInteger)index;
-(void)setCoverOfIssueAtIndex:(NSInteger)index completionBlock:(void(^)(UIImage *img))block;
-(NSURL *)contentURLForIssueWithName:(NSString *)name;
-(NSString *)downloadPathForIssue:(NKIssue *)nkIssue;
-(UIImage *)coverImageForIssue:(NKIssue *)nkIssue;
-(NKIssue*)removeIssueAtIndex:(NSInteger)index;

@end
