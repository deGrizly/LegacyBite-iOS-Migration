//
//  SSRootTabBarController.m
//  LegacyBite
//
//  Created by Grizly on 15.07.26.
//

#import "RootTabBarController.h"
#import "AboutViewController.h"
#import "HistoryViewController.h"
#import "ScanerViewController.h"

typedef enum : NSUInteger {
    RootTabBarTagScan,
    RootTabBarTagHistory,
    RootTabBarTagAbout
} RootTabBarTag;

@interface RootTabBarController ()

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTabBarControllers];
    
    self.tabBar.translucent = NO;
    self.tabBar.tintColor = [UIColor systemGreenColor];
    self.tabBar.unselectedItemTintColor = [UIColor systemGrayColor];
    self.tabBar.backgroundColor = [UIColor systemBackgroundColor];
    
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor systemBackgroundColor];
        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance = appearance;
    }
}

-(void)addTabBarControllers{
    
    ScanerViewController * scanerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ScanerViewController"]; 
    UINavigationController * scanerNC = [[UINavigationController alloc] initWithRootViewController:scanerVC];
    UITabBarItem * scanItem = [[UITabBarItem alloc] initWithTitle:@"Scan" image:[UIImage systemImageNamed:@"barcode.viewfinder"] tag:RootTabBarTagScan];
    scanerNC.tabBarItem = scanItem;
    
    HistoryViewController * historyVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HistoryViewController"];
    UINavigationController * historyNC = [[UINavigationController alloc] initWithRootViewController:historyVC];
    historyNC.navigationBar.prefersLargeTitles = YES;
    UITabBarItem * historyItem = [[UITabBarItem alloc] initWithTitle:@"History" image:[UIImage systemImageNamed:@"clock.arrow.circlepath"] tag:RootTabBarTagHistory];
    historyNC.tabBarItem = historyItem;
    

    AboutViewController * aboutVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"AboutViewController"];
    UINavigationController * aboutNC = [[UINavigationController alloc] initWithRootViewController:aboutVC];
    aboutNC.navigationBar.prefersLargeTitles = YES;
    UITabBarItem * aboutItem = [[UITabBarItem alloc] initWithTitle:@"About" image:[UIImage systemImageNamed:@"info.circle"] tag:RootTabBarTagAbout];
    aboutNC.tabBarItem = aboutItem;
    
    NSMutableArray * list = [NSMutableArray new];
    [list addObject:scanerNC];
    [list addObject:historyNC];
    [list addObject:aboutNC];
    
    self.viewControllers = list;
    
}

@end
