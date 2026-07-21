//
//  HistoryViewController.m
//  LegacyBite
//
//  Created by Grizly on 15.07.26.
//

#import "HistoryViewController.h"
#import "SSProductObject.h"
#import "ProductManager.h"
#import "HistoryProductCell.h"
#import "SSNetworkManager.h"
#import "ProductCardViewController.h"

@interface HistoryViewController () <UITableViewDelegate, UITableViewDataSource>

{
    NSArray <SSProductObject *> * dataList;
}

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"History";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    dataList = [[ProductManager shared] historyListOfProducts];
    [self.tableView reloadData];
}

+ (NSDateFormatter *)historyDateFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd.MM.yyyy HH:mm";
    });

    return formatter;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryProductCell * cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryProductCell"];
    
    SSProductObject * obj = dataList[indexPath.row];
    
    if (obj.name && obj.name.length > 0){
        cell.nameLabel.text = obj.name;
    } else {
        cell.nameLabel.hidden = true;
    }
    
    if (obj.brand && obj.brand.length > 0){
        cell.brandLabel.text = obj.brand;
    } else {
        cell.brandLabel.hidden = true;
    }
    
    if(obj.savedDate){
        cell.dateLabel.text =
        [[[self class] historyDateFormatter] stringFromDate:obj.savedDate];
    } else {
        cell.dateLabel.hidden = nil;
    }
    
    
    NSURL * imageUrl = obj.imageURL;
    //cell.productImage.image = [UIImage ]
    cell.representedImageURL = imageUrl;
    
    cell.imageTask = [[SSNetworkManager shared] loadImageWithURL:imageUrl completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!image || error){
                return;
            }
            if([cell.representedImageURL isEqual:imageUrl]){
                cell.productImage.image = image;
            }
        });
    }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    SSProductObject * obj = dataList[indexPath.row];
    
    ProductCardViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProductCardViewController"];
    vc.product = obj;
    [self.navigationController pushViewController:vc animated:true];
}

@end
