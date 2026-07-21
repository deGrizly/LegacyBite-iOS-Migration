//
//  AboutDetailsViewController.m
//  LegacyBite
//
//  Created by Grizly on 20.07.26.
//

#import "AboutDetailsViewController.h"

static NSString * projectStr = @"LegacyBite is a portfolio iOS project built as a staged modernization case study.\nThe app allows users to scan a product barcode, load basic product information, view nutrition details, and keep a local scan history.\nThe main goal of this project is not only the product scanner itself, but the migration path: from a legacy Objective-C/UIKit MVC codebase to a more modern Swift/UIKit and SwiftUI architecture.\nThis project intentionally starts with a classic UIKit/Objective-C baseline to demonstrate how a real legacy iOS app can be gradually improved without a full rewrite.";

static NSString * apiStr = @"Product data in this app is provided by the public Open Food Facts API.\nOpen Food Facts is an open food products database that allows apps and services to look up product information by barcode. LegacyBite uses this API to display product names, brands, ingredients, images, and nutrition values when available.\nThe app does not own, verify, or control the data returned by Open Food Facts. Product information may be incomplete, outdated, unavailable for some barcodes, or changed by the Open Food Facts service over time.\nThis project uses the API for educational and portfolio purposes only. The displayed information should not be treated as medical, dietary, or professional advice.";

@interface AboutDetailsViewController ()

@property (strong, nonatomic) UITextView * textView;

@end

@implementation AboutDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self setupUI];
}

-(void)initUI{
    self.textView = [[UITextView alloc] init];
    self.textView.translatesAutoresizingMaskIntoConstraints = false;
    self.textView.editable = false;
    self.textView.scrollEnabled = false;
    
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.textColor = [UIColor systemGrayColor];
    
    [self.view addSubview:self.textView];
    [NSLayoutConstraint activateConstraints:@[
       [self.textView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
       [self.textView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
       [self.textView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:8],
       [self.textView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-8]
    ]];
}

-(void)setupUI{
    if (self.type == AboutDetailsTypeApi){
        self.textView.text = apiStr;
        
    } else {
        self.textView.text = projectStr;
    }
}


@end
