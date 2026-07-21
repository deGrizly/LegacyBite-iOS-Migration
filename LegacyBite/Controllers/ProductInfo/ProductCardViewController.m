//
//  ProductCardViewController.m
//  LegacyBite
//
//  Created by Grizly on 17.07.26.
//

#import "ProductCardViewController.h"
#import "SSNetworkManager.h"
#import "NutriScoreView.h"


@interface ProductCardViewController ()

@property (weak, nonatomic) IBOutlet UIView * containerNutritionView;
@property (weak, nonatomic) IBOutlet UIImageView * productImage;
@property (weak, nonatomic) IBOutlet UILabel * productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel * productCompanyLabel;
@property (weak, nonatomic) IBOutlet NutriScoreView * nutriScoreView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * nutriScoreHeight; //default 54

@property (strong, nonatomic) UIActivityIndicatorView *imageActivityIndicator;
@property (strong, nonatomic, nullable) NSURLSessionDataTask *imageLoadingTask;

@property (weak, nonatomic) IBOutlet UILabel * proteinLabel;
@property (weak, nonatomic) IBOutlet UILabel * fatLabel;
@property (weak, nonatomic) IBOutlet UILabel * carbohydratesLabel;
@property (weak, nonatomic) IBOutlet UILabel * energyLabel;

@end

@implementation ProductCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContainerView];
    [self updateUI];
    [self loadProductImage];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.imageLoadingTask cancel];
    self.imageLoadingTask = nil;
}

-(void)setupContainerView{
    self.containerNutritionView.layer.masksToBounds = true;
    self.containerNutritionView.layer.cornerRadius = 20.;
    self.containerNutritionView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.containerNutritionView.layer.borderWidth = 1.;
}

-(void)updateUI{
    self.productNameLabel.text = self.product.name;
    self.productCompanyLabel.text = self.product.brand;
    
    if(self.product.proteins && [self.product.proteins doubleValue] != 0){
        self.proteinLabel.text = [NSString stringWithFormat:@"%.2f g", self.product.proteins.doubleValue];
    } else {
        self.proteinLabel.text = @"-";
    }
    
    if(self.product.fat && [self.product.fat doubleValue] != 0){
        self.fatLabel.text = [NSString stringWithFormat:@"%.2f g", self.product.fat.doubleValue];
    } else {
        self.fatLabel.text = @"-";
    }
    
    if(self.product.carbohydrates && [self.product.carbohydrates doubleValue] != 0){
        self.carbohydratesLabel.text = [NSString stringWithFormat:@"%.2f g", self.product.carbohydrates.doubleValue];
    } else {
        self.carbohydratesLabel.text = @"-";
    }
    
    if(self.product.energyKcal && [self.product.energyKcal doubleValue] != 0){
        self.energyLabel.text = [NSString stringWithFormat:@"%.2f kcal", self.product.energyKcal.doubleValue];
    } else {
        self.energyLabel.text = @"-";
    }
    
    
    
    [self configureProductImageView];
    [self configureImageActivityIndicator];
    NSString * score = self.product.nutriScore;
    NSArray * testList = @[@"a", @"b", @"c", @"d", @"e"];
    if(![score isEqual:[NSNull null]] && score && [testList containsObject:score.lowercaseString]){
        [self.nutriScoreView setScore:[score uppercaseString]];
    } else {
        self.nutriScoreView.hidden = true;
        self.nutriScoreHeight.constant = 0;
    }
    
}

- (void)configureProductImageView {
    self.productImage.contentMode = UIViewContentModeScaleAspectFit;
    self.productImage.clipsToBounds = YES;
}

- (void)configureImageActivityIndicator {
    UIActivityIndicatorViewStyle style;

    style = UIActivityIndicatorViewStyleMedium;
 

    self.imageActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];

    self.imageActivityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageActivityIndicator.hidesWhenStopped = YES;

    [self.productImage addSubview:self.imageActivityIndicator];

    [NSLayoutConstraint activateConstraints:@[[self.imageActivityIndicator.centerXAnchor constraintEqualToAnchor:self.productImage.centerXAnchor], [self.imageActivityIndicator.centerYAnchor constraintEqualToAnchor:self.productImage.centerYAnchor]
    ]];
}

- (void)showImagePlaceholder {
    [self.imageActivityIndicator stopAnimating];

    self.productImage.contentMode = UIViewContentModeCenter;

    UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:44.0 weight:UIImageSymbolWeightRegular];
    
    self.productImage.image = [UIImage systemImageNamed:@"photo" withConfiguration:configuration];
    self.productImage.tintColor = [UIColor secondaryLabelColor];

}

- (void)loadProductImage {
    [self.imageLoadingTask cancel];
    self.imageLoadingTask = nil;

    self.productImage.image = nil;
    [self.imageActivityIndicator startAnimating];

    NSURL *imageURL = self.product.imageURL;

    if (!imageURL) {
        [self showImagePlaceholder];
        return;
    }

    __weak typeof(self) weakSelf = self;

    self.imageLoadingTask = [[SSNetworkManager shared] loadImageWithURL:imageURL completion:^(UIImage *image, NSError *error) {

        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (!strongSelf) {
            return;
        }

        strongSelf.imageLoadingTask = nil;
        [strongSelf.imageActivityIndicator stopAnimating];

        if (error || !image) {
            NSLog(@"Product image loading error: %@", error);
            [strongSelf showImagePlaceholder];
            return;
        }

        strongSelf.productImage.tintColor = nil;
        strongSelf.productImage.contentMode = UIViewContentModeScaleAspectFit;
        strongSelf.productImage.image = image;
    }];
}

@end
