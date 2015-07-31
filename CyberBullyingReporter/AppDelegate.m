//
//  AppDelegate.m
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

#import <Parse/Parse.h>

#import "AppDelegate.h"

@implementation AppDelegate

#pragma mark -
#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.policeAPI = [UKPoliceDataAPIManager sharedManager];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringVisits];
    [Parse enableLocalDatastore];

    [Parse setApplicationId:@"NvkxqDzsI6BmL5OdgVgRPYAZVwocNFhjIJfCl1rq"
                  clientKey:@"XWe1ak3RvNjhVb8zDIUbtEl3lQANVb0cW5RQkSDZ"];
    [PFUser enableAutomaticUser];

    PFACL *defaultACL = [PFACL ACL];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    // Override point for customization after application launch.

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    self.navigationController = [storyboard instantiateInitialViewController];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

#pragma mark Push Notifications

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    for (CLLocation *location in locations) {
//       
//        
//                        };
    
    CLLocation *location = [locations lastObject];
    
    NSDictionary *locationDictionary = @{@"Latitude"            : [NSNumber numberWithDouble:location.coordinate.latitude],
                                         @"Longitude"           : [NSNumber numberWithDouble:location.coordinate.longitude],
                                         @"Horizontal Accuracy" : [NSNumber numberWithDouble:location.horizontalAccuracy],
                                         @"Vertical Accuracy"   : [NSNumber numberWithDouble:location.verticalAccuracy],
                                         @"Speed"               : [NSNumber numberWithDouble:location.speed],
                                         @"Altitude"            : [NSNumber numberWithDouble:location.altitude],
                                         @"Timestamp"           : location.timestamp.description,
                                         @"Altitude"            : [NSNumber numberWithDouble:location.timestamp.timeIntervalSinceNow]
                                         };
    
        __block PFObject *visitObject = [PFObject objectWithClassName:@"VisitedLocations"];
        visitObject[@"ReporterName"] = @"Child Name";
        visitObject[@"location"] = locationDictionary;
        visitObject.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
        dispatch_async(queue, ^{
            [_policeAPI crimeSearchByLocation:location.coordinate date:@"2015-05" completion:^(AFHTTPRequestOperation *operation, NSURLRequest *request, id JSON) {
                
                NSLog(@"crime at location:%@",JSON);
                visitObject[@"crimeAtLocation"] = JSON;
                dispatch_semaphore_signal(sema);
            } failure:^(AFHTTPRequestOperation *operation, id JSON) {
                NSLog(@"failed to get crime at location:%@",JSON);
                dispatch_semaphore_signal(sema);
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
            [visitObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"saved location!");
                    // The object has been saved.
                } else {
                    NSLog(@"failed to save with error:%@",error.description);
                    // There was a problem, check error.description
                }
            }];
        });
   
    
    
}

-(void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit{
    
    NSDictionary *visitDictionary = @{@"Latitude"            : [NSNumber numberWithDouble:visit.coordinate.latitude],
                                      @"Longitude"           : [NSNumber numberWithDouble:visit.coordinate.longitude],
                                      @"Horizontal Accuracy" : [NSNumber numberWithDouble:visit.horizontalAccuracy],
                                      @"Arrived"             : visit.arrivalDate.description,
                                      @"Departed"            : visit.departureDate.description
                                      };
    
    
    PFObject *visitObject = [PFObject objectWithClassName:@"VisitedLocations"];
    visitObject[@"ReporterName"] = @"Child Name";
    visitObject[@"location"] = visitDictionary;
    
    visitObject.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    
    [visitObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"saved location - DidVisit!");
            // The object has been saved.
        } else {
            NSLog(@"failed to save with error:%@",error.description);
            // There was a problem, check error.description
        }
    }];


}

@end
