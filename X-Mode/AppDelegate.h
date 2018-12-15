//
//  AppDelegate.h
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

#define APP_DELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end

