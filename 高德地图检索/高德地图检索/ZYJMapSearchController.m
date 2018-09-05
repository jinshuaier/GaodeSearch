//
//  ZYJMapSearchController.m
//  yihuodong
//
//  Created by 张艳江 on 2018/6/7.
//  Copyright © 2018年 张艳江. All rights reserved.
//

#import "ZYJMapSearchController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "MJRefresh.h"

@interface ZYJMapSearchController ()<UITableViewDelegate,UITableViewDataSource,AMapSearchDelegate,UITextFieldDelegate>{
    NSInteger searchPage;
    // 上拉更多请求数据的标记
    BOOL isFromMoreLoadRequest;
}

@property (strong, nonatomic) UITextField    *search;
@property (strong, nonatomic) AMapSearchAPI  *searchAPI;
@property (strong, nonatomic) UITableView    *searchTableView;
@property (strong, nonatomic) NSMutableArray *searchResultArray;

@end

@implementation ZYJMapSearchController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [self.search becomeFirstResponder];
    searchPage = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpsearch];
    [self setTableView];
    
    self.searchAPI = [[AMapSearchAPI alloc] init];
    self.searchAPI.delegate = self;
    self.searchResultArray = [NSMutableArray array];
}
- (void)setUpsearch{
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 64)];
    navView.backgroundColor = [UIColor whiteColor];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = BGColor;
    [self.view addSubview:navView];
    [navView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(0.7);
        make.left.bottom.right.equalTo(navView).offset(0);
    }];
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = RGB(242, 242, 242);
    bgView.layer.cornerRadius = 4.0f;
    [navView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(navView.mas_left).offset(16);
        make.top.equalTo(navView.mas_top).offset(23);
        make.bottom.equalTo(navView.mas_bottom).offset(-7);
        make.width.offset(ScreenW * 0.8);
    }];
    UIButton *imageBtn = [[UIButton alloc]init];
    [imageBtn setImage:[UIImage imageNamed:@"hui_search"] forState:0];
    [bgView addSubview:imageBtn];
    [imageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bgView.mas_left).offset(10);
        make.width.offset(16);
        make.centerY.equalTo(bgView.mas_centerY).offset(0);
    }];
    self.search = [[UITextField alloc] init];
    self.search.returnKeyType = UIReturnKeySearch;//更改键盘的return
    self.search.delegate = self;
    self.search.placeholder = @"请输入关键字";
    self.search.font = [UIFont systemFontOfSize:14];
    [self.search addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:self.search];
    [self.search mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageBtn.mas_right).offset(10);
        make.top.equalTo(bgView.mas_top).offset(5);
        make.bottom.equalTo(bgView.mas_bottom).offset(-5);
        make.right.equalTo(bgView.mas_right).offset(-5);
    }];
    UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [navView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bgView.mas_centerY).offset(0);
        make.left.equalTo(bgView.mas_right).offset(15);
        make.width.offset(30);
    }];
    [self.view addSubview:self.searchTableView];
    [self.searchTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navView.mas_bottom).offset(0);
        make.left.right.bottom.equalTo(self.view).offset(0);
    }];
}
- (void)setTableView{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenW, ScreenH - 64) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 55;
    tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:tableView];
    self.searchTableView = tableView;
    
    self.searchTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}
- (void)cancelBtnClick{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)loadMoreData{
    if (self.search.text.length > 0) {
        searchPage++;
        isFromMoreLoadRequest = YES;
        [self searchPoiBySearchString:self.search.text];
    }else{
        self.searchTableView.mj_footer.state = MJRefreshStateNoMoreData;
    }
}
- (void)searchPoiBySearchString:(NSString *)searchString{
    //POI关键字搜索
    [self searchResult];
}
#pragma mark - textFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField{
    //POI关键字搜索
    [self searchResult];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    if (textField.text.length > 0) {
        [textField resignFirstResponder];
        [self searchResult];
    }
    return YES;
}
- (void)searchResult{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = self.search.text;
    request.cityLimit = YES;
    request.page = searchPage;
    [self.searchAPI AMapPOIKeywordsSearch:request];
}
#pragma mark - AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    // 判断是否从更多拉取
    if (isFromMoreLoadRequest) {
        isFromMoreLoadRequest = NO;
    }else{
        [self.searchResultArray removeAllObjects];
        // 刷新后TableView返回顶部
        [self.searchTableView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    // 刷新完成,没有数据时不显示footer
    if (response.pois.count == 0) {
        self.searchTableView.mj_footer.state = MJRefreshStateNoMoreData;
    }else{
        self.searchTableView.mj_footer.state = MJRefreshStateIdle;
        // 添加数据并刷新TableView
        [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
            [self.searchResultArray addObject:obj];
        }];
    }
    [self.searchTableView reloadData];
}

#pragma mark - UITableViewDelegate && dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchResultArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    AMapPOI *point = self.searchResultArray[indexPath.row];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:point.name];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, text.length)];
    
    //高亮
    NSRange textHighlightRange = [point.name rangeOfString:self.search.text];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:textHighlightRange];
    cell.textLabel.attributedText = text;
    
    cell.detailTextLabel.text = point.address;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AMapPOI *point = self.searchResultArray[indexPath.row];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(point.location.latitude, point.location.longitude);
    !_chooseAddress ?: _chooseAddress(location);
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
