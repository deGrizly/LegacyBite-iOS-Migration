//
//  NutriScoreView.m
//  LegacyBite
//
//  Created by Grizly on 18.07.26.
//

#import "NutriScoreView.h"

static NSString * darkGreenColorHex = @"367B46";
static NSString * lightGreenColorHex = @"8CB447";
static NSString * yellowColorHex = @"EEC744";
static NSString * orangeColorHex = @"D9832F";
static NSString * redColorHex = @"CD4A28";

@interface NutriScoreView()

@property (strong, nonatomic) UIStackView * stackView;
@property (strong, nonatomic) NSArray<UIView *> * itemViews;
@property (strong, nonatomic) NSMutableArray<NSLayoutConstraint *> * heightConstraints;

@end

@implementation NutriScoreView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}


#pragma mark - setup

-(void)customInit{
    if (self.stackView) {
        return;
    }
    CGFloat spacing = 2;
    self.stackView = [[UIStackView alloc] init];
    self.stackView.axis = UILayoutConstraintAxisHorizontal;
    self.stackView.spacing = spacing;
    self.stackView.alignment = UIStackViewAlignmentFill;
    self.stackView.distribution = UIStackViewDistributionFillEqually;
    self.stackView.translatesAutoresizingMaskIntoConstraints = false;
    
    [self addSubview:self.stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.stackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0],
        [self.stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0],
        [self.stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0],
        [self.stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0]
    ]];
    
    NSArray * nameList = @[@"A", @"B", @"C", @"D", @"E"];
    NSArray<UIColor *> *colors = @[
        [self colorFromHex:darkGreenColorHex],
        [self colorFromHex:lightGreenColorHex],
        [self colorFromHex:yellowColorHex],
        [self colorFromHex:orangeColorHex],
        [self colorFromHex:redColorHex]
    ];

    NSMutableArray<UIView *> *views = [NSMutableArray array];
    self.heightConstraints = [NSMutableArray array];
    
    for (NSInteger index = 0; index < nameList.count; index++) {
        UIView *itemView = [self itemView:nameList[index] сolor:colors[index]];
        
        [self.stackView addArrangedSubview:itemView];
        [views addObject:itemView];
        
        NSLayoutConstraint *heightConstraint =
        [itemView.heightAnchor constraintEqualToAnchor:self.heightAnchor
                                            multiplier:0.8];
        
        heightConstraint.active = YES;
        [self.heightConstraints addObject:heightConstraint];
    }
    
    self.itemViews = views;
}

- (UIColor *)colorFromHex:(NSString *)hexString {

    unsigned int rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];

    CGFloat red = ((rgbValue & 0xFF0000) >> 16) / 255.0;
    CGFloat green = ((rgbValue & 0x00FF00) >> 8) / 255.0;
    CGFloat blue = (rgbValue & 0x0000FF) / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

-(UIView *)itemView:(NSString *)text сolor:(UIColor *)color{
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = color;
    view.translatesAutoresizingMaskIntoConstraints = false;
    view.layer.cornerRadius = 4.0;
    view.clipsToBounds = true;
    
    UILabel * label = [UILabel new];
    label.text = text;
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    label.textColor = [UIColor whiteColor];
    label.translatesAutoresizingMaskIntoConstraints = false;
    [label setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:label];
    
    [NSLayoutConstraint activateConstraints:@[
       [label.topAnchor constraintEqualToAnchor:view.topAnchor],
       [label.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
       [label.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
       [label.trailingAnchor constraintEqualToAnchor:view.trailingAnchor]
    ]];
    
    
    return view;
}

#pragma mark - interface
- (void)setScore:(NSString *)score {
    NSString *normalizedScore = score.uppercaseString;
    
    NSArray<NSString *> *supportedScores = @[@"A", @"B", @"C", @"D", @"E"];
    NSInteger selectedIndex = [supportedScores indexOfObject:normalizedScore];
    
    for (NSInteger index = 0; index < self.itemViews.count; index++) {
        UIView *itemView = self.itemViews[index];
        
        NSLayoutConstraint *oldConstraint = self.heightConstraints[index];
        oldConstraint.active = NO;
        
        CGFloat multiplier = index == selectedIndex ? 0.95 : 0.8;
        
        NSLayoutConstraint *newConstraint =
        [itemView.heightAnchor constraintEqualToAnchor:self.heightAnchor
                                            multiplier:multiplier];
        
        newConstraint.active = YES;
        self.heightConstraints[index] = newConstraint;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
}

@end
