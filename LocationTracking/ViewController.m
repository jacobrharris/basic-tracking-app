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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.showsBackgroundLocationIndicator = YES;

    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
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
    for (CLLocation *location in locations) {
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = location.coordinate;
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            CLPlacemark *placemark = [placemarks firstObject];
            point.title = placemark.name;
            [self.mapView addAnnotation:point];
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
    for (MKAnnotationView *view in views) {
        CLLocationCoordinate2D coord = view.annotation.coordinate;
        MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
        MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
        [mapView setRegion:region animated:YES];
    }
}

@end
