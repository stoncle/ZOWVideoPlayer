//
//  ViewController.m
//  Example
//
//  Created by stoncle on 12/18/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ViewController.h"
#import "InstagramVideoView.h"
#import "InstagramViewController.h"

static const NSString *cellIdentifier = @"cellIdentifier";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<NSString *> *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"ZOWVideoPlayerExample";
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[cellIdentifier copy]];
    [self.view addSubview:_tableView];
    
    [self prepareDataSource];
}

- (void)prepareDataSource {
    _data = [@[@"instagram", @"common"] mutableCopy];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[cellIdentifier copy] forIndexPath:indexPath];
    if (indexPath.row < _data.count) {
        cell.textLabel.text = _data[indexPath.row];
    } else {
        cell.textLabel.text = @"error";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _data.count && [_data[indexPath.row] isEqualToString:@"instagram"]) {
        InstagramViewController *insVC = [[InstagramViewController alloc] init];
        [self.navigationController pushViewController:insVC animated:YES];
    } else if (indexPath.row < _data.count && [_data[indexPath.row] isEqualToString:@"common"]) {
        
    }
}

@end
