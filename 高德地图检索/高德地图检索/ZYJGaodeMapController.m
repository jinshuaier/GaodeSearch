//
//  ZYJGaodeMapController.m
//  yihuodong
//
//  Created by 张艳江 on 2018/6/7.
//  Copyright © 2018年 张艳江. All rights reserved.
//

#import "ZYJGaodeMapController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "ZYJMapPoiTableView.h"
#import "ZYJMapSearchController.h"

@interface ZYJGaodeMapController ()<MAMapViewDelegate, ZYJMapPoiTableViewDelegate, AMapSearchDelegate>{
    
    NSString *_city;//当前城市
    BOOL isFirstLocated;//第一次定位标记
    NSInteger searchPage;//搜索页数
    // 禁止连续点击两次
    BOOL _isMapViewRegionChangedFromTableView;
}

@property (strong, nonatomic) UIView        *topView;
@property (strong, nonatomic) MAMapView     *mapView;//地图
@property (strong, nonatomic) UIImageView   *centerMaker;//中心点图标
@property (strong, nonatomic) UIButton      *locationBtn;//定位开关
@property (strong, nonatomic) AMapSearchAPI *searchAPI;//搜索API
@property (strong, nonatomic) ZYJModel      *model;

@property (strong, nonatomic) ZYJMapPoiTableView *tableView;

@end

@implementation ZYJGaodeMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"地点选择";
    self.view.backgroundColor = [UIColor whiteColor];
    //顶部搜索按钮
    [self setupSearchView];
    
    _isMapViewRegionChangedFromTableView = NO;
    isFirstLocated = YES;
    
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithButtonFrame:CGRectMake(0, 0, 40, 30) title:@"确定" color:RGB(20, 104, 240) font:[UIFont systemFontOfSize:16] target:self action:@selector(clickCertain)];
    
    //初始化地图
    [self initMapView];
    [self initCenterMarker];
    [self initLocationButton];
    [self initTableView];
    [self initSearch];
    //经纬度地址模型
    self.model = [[ZYJModel alloc]init];
}
- (void)clickCertain{
//    if (self.model.address.length == 0) {
//        [SVProgressHUD showImage:nil status:@"请先选择地址"];
//    }else{
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"ChooseAdress" object:self.model];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}
- (void)setupSearchView{
    
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, 45)];
    self.topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topView];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    searchBtn.frame = CGRectMake(12, 0, ScreenW - 24, 30);
    [searchBtn setBackgroundColor:BGColor];
    searchBtn.layer.cornerRadius = 4.0f;
    [searchBtn setTitle:@"搜索" forState:0];
    [searchBtn setImage:[UIImage imageNamed:@"hui_search"] forState:0];
    //[searchBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:3];
    [searchBtn addTarget:self action:@selector(clickSearch) forControlEvents:UIControlEventTouchUpInside];
    
    [self.topView addSubview:searchBtn];
}
- (void)clickSearch{
    ZYJMapSearchController *mapSearchVc = [[ZYJMapSearchController alloc]init];
    //mapSearchVc.cityName = _city;
    [self presentViewController:mapSearchVc animated:NO completion:nil];
    mapSearchVc.chooseAddress = ^(CLLocationCoordinate2D pt) {
        [self.mapView setCenterCoordinate:pt animated:YES];
    };
}
#pragma mark - 初始化
- (void)initMapView{
    
    self.mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, self.topView.bottom, ScreenW, 320*Scale_H)];
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 16;
    self.mapView.showsCompass = NO;// 是否显示指南针
    self.mapView.showsScale = NO;// 是否显示比例尺
    self.mapView.showsUserLocation = YES;// 是否显示用户位置
    self.mapView.minZoomLevel = 12;// 限制最小缩放级别
    [self.view addSubview:self.mapView];
}
//中心点
- (void)initCenterMarker{
    
    UIImage *image = [UIImage imageNamed:@"centerIcon"];
    self.centerMaker = [[UIImageView alloc]initWithImage:image];
    self.centerMaker.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.centerMaker.center = CGPointMake(ScreenW/2.0f, self.mapView.height/2.0f);
    [self.view addSubview:self.centerMaker];
}
//定位自身
- (void)initLocationButton{
    
    self.locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenW - 46, self.mapView.height - 65, 40, 40)];
    [self.locationBtn setImage:[UIImage imageNamed:@"suoding"] forState:0];
    [self.locationBtn addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.locationBtn];
}
- (void)actionLocation{
    [self.mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
}
//搜索列表
- (void)initTableView{
    
    self.tableView = [[ZYJMapPoiTableView alloc]initWithFrame:CGRectMake(0, self.mapView.bottom - 64, ScreenW, ScreenH - self.topView.height - self.mapView.height)];
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}
//搜索
- (void)initSearch{
    searchPage = 1;
    self.searchAPI = [[AMapSearchAPI alloc]init];
    self.searchAPI.delegate = self.tableView;
}
#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    // 首次定位
    if (updatingLocation && isFirstLocated == YES ) {
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)];
        [self startSearch];
        isFirstLocated = NO;
    }
}
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if (_isMapViewRegionChangedFromTableView == NO && isFirstLocated == NO ) {
        [self startSearch];
        //范围移动时当前页面数重置
        searchPage = 1;
    }
    _isMapViewRegionChangedFromTableView = NO;
}
- (void)startSearch{
    AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:_mapView.centerCoordinate.latitude longitude:_mapView.centerCoordinate.longitude];
    [self searchReGeocodeWithAMapGeoPoint:point];
    [self searchPoiByAMapGeoPoint:point];
}
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    MAAnnotationView *view = views[0];
    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
    if ([view.annotation isKindOfClass:[MAUserLocation class]]){
        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
        pre.showsAccuracyRing = NO;
        [self.mapView updateUserLocationRepresentation:pre];
        view.calloutOffset = CGPointMake(0, 0);
    }
}
// 搜索逆向地理编码-AMapGeoPoint
- (void)searchReGeocodeWithAMapGeoPoint:(AMapGeoPoint *)location{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = location;
    // 返回扩展信息
    regeo.requireExtension = YES;
    [self.searchAPI AMapReGoecodeSearch:regeo];
}
//搜索中心点坐标周围的POI-AMapGeoPoint
- (void)searchPoiByAMapGeoPoint:(AMapGeoPoint *)location{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = location;
    // 搜索半径
    request.radius = 1000;
    // 搜索结果排序
    request.sortrule = 1;
    // 当前页数
    request.page = searchPage;
    [self.searchAPI AMapPOIAroundSearch:request];
}
#pragma mark - 列表代理
- (void)loadMorePOI{
    searchPage++;
    AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:_mapView.centerCoordinate.latitude longitude:_mapView.centerCoordinate.longitude];
    [self searchPoiByAMapGeoPoint:point];
}
- (void)setMapCenterWithPOI:(AMapPOI *)point isLocateImageShouldChange:(BOOL)isLocateImageShouldChange{
    // 切换定位图标
    _isMapViewRegionChangedFromTableView = YES;
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(point.location.latitude, point.location.longitude);
    [self.mapView setCenterCoordinate:location animated:YES];
    
    self.model.address = point.name;
    self.model.latitude = [NSString stringWithFormat:@"%f", point.location.latitude];
    self.model.longitude = [NSString stringWithFormat:@"%f", point.location.longitude];
}
- (void)setSendButtonEnabledAfterLoadFinished{
    self.navigationItem.rightBarButtonItem.enabled = YES;
}
- (void)setCurrentCity:(ZYJModel *)model{
    self.model.address = model.address;
    self.model.latitude = model.latitude;
    self.model.longitude = model.longitude;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
