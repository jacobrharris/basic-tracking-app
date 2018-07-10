//
//  ViewController.m
//  LocationTracking
//
//  Created by Jacob Harris on 7/9/18.
//  Copyright © 2018 Sneeze & Cookie, LLC. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

NSString * const CoordinatesKey = @"CoordinatesKey";
NSString * const LatitudeKey = @"LatitudeKey";
NSString * const LongitudeKey = @"LongitudeKey";
NSString * const TitleKey = @"TitleKey";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.showsBackgroundLocationIndicator = YES;

    // Set up map view
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    // Retrieve any previously-saved coordinates and add them to the map view
    NSArray *savedCoordinates = [[NSUserDefaults standardUserDefaults] objectForKey:CoordinatesKey];
    for (NSDictionary *coordinateDict in savedCoordinates) {
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.title = [coordinateDict objectForKey:TitleKey];
        point.coordinate = CLLocationCoordinate2DMake([[coordinateDict objectForKey:LatitudeKey] doubleValue],
                                                      [[coordinateDict objectForKey:LongitudeKey] doubleValue]);
        [self.mapView addAnnotation:point];
    }
}

- (void)saveCoordinate:(CLLocationCoordinate2D)coordinate withTitle:(NSString *)title {
    // Retrieve any previously-saved coordinates
    NSArray *savedCoordinates = [[NSUserDefaults standardUserDefaults] objectForKey:CoordinatesKey];
    NSMutableArray *updatedCoordinates = [NSMutableArray array];
    if (savedCoordinates) {
        updatedCoordinates = [savedCoordinates mutableCopy];
    }
    
    // Append the current coordinate to the saved coordinates
    NSDictionary *coordinateDict = @{LatitudeKey:@(coordinate.latitude),
                                     LongitudeKey:@(coordinate.longitude),
                                     TitleKey:title};
    [updatedCoordinates addObject:coordinateDict];
    
    // Save the coordinates
    [[NSUserDefaults standardUserDefaults] setObject:updatedCoordinates forKey:CoordinatesKey];
}

- (IBAction)didTapLocationButton:(UIButton *)sender {
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"%d", status);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"%@", locations);

    // Create an annotation when a location is created
    CLLocation *lastLocation = [locations lastObject];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = lastLocation.coordinate;
    
    // Reverse-geocode the location to get the address
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:lastLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        // Add the address to the annotation
        CLPlacemark *placemark = [placemarks firstObject];
        point.title = placemark.name;
        
        // Add the annotation to the map
        [self.mapView addAnnotation:point];
        
        // Save the coordinate and title to NSUserDefaults
        [self saveCoordinate:lastLocation.coordinate withTitle:point.title];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
    // Set the map region when an annotation is added
    MKAnnotationView *view = [views lastObject];
    CLLocationCoordinate2D coord = view.annotation.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
    MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
    [mapView setRegion:region animated:YES];
}

@end
