//
//  UKPoliceDataAPIManager.h
//  UKPoliceDataAPI-SDK
//

#import "AFNetworking.h"
@import Foundation;
@import UIKit;
@import CoreLocation;

@interface UKPoliceDataAPIManager : NSObject

typedef void (^APIRequestCompletionBlock)(AFHTTPRequestOperation *operation, NSURLRequest *request, id JSON);

typedef void (^APIRequestFailureBlock)(AFHTTPRequestOperation *operation, id JSON);

+(instancetype)sharedManager;

#pragma mark /no parameters

-(void)requestForces:(APIRequestCompletionBlock)requestCompletedHandler failure:(APIRequestFailureBlock)requestFailureHander;

-(void)streetLevelCrimeSearchByLocation:(CLLocationCoordinate2D)location completion:(APIRequestCompletionBlock)requestCompletedHandler failure:(APIRequestFailureBlock)requestFailureHander;

-(void)streetLevelCrimeSearchByLocation:(CLLocationCoordinate2D)location date:(NSDate*)date completion:(APIRequestCompletionBlock)requestCompletedHandler failure:(APIRequestFailureBlock)requestFailureHander;

-(void)streetLevelCrimeSearchByLocation:(CLLocationCoordinate2D)location year:(NSString*)year completion:(APIRequestCompletionBlock)requestCompletedHandler failure:(APIRequestFailureBlock)requestFailureHander;

-(void)crimeSearchByLocation:(CLLocationCoordinate2D)location date:(NSString*)date completion:(APIRequestCompletionBlock)requestCompletedHandler failure:(APIRequestFailureBlock)requestFailureHander;

#pragma mark /pagination

-(void)nextPagination:(NSURL*)paginationURL completion:(APIRequestCompletionBlock)requestCompletedHandler failure:(APIRequestFailureBlock)requestFailureHander;

@end

