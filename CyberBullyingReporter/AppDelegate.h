
#import <Foundation/Foundation.h>
#import "UKPoliceDataAPIManager.h"
@import CoreLocation;

@class AppDelegate;

@interface AppDelegate : NSObject <UIApplicationDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UKPoliceDataAPIManager *policeAPI;
@end
