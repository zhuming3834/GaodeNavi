//
//  ViewController.m
//  WeatherSearch
//
//  Created by HGDQ on 15/10/9.
//  Copyright (c) 2015年 HGDQ. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>


#define APIKEY   @"bef268d13caddb05409bc6f68b913367"

@interface ViewController ()<MAMapViewDelegate,UISearchBarDelegate,AMapSearchDelegate>

@property (nonatomic,strong)MAMapView *mapView;
@property (nonatomic,strong)AMapSearchAPI *NaviSearch;
@property (nonatomic,strong)AMapSearchAPI *GeoSearch;
@property (nonatomic,strong)AMapGeoPoint *originPoint;      //搜索的起点
@property (nonatomic,strong)AMapGeoPoint *destinationPoint; //搜索的终点
@property (nonatomic,strong)NSString *originAddress;        //起点
@property (nonatomic,strong)NSString *destinationAddress;   //终点
@property (nonatomic,strong)NSMutableArray *annotationArr;  //大头针数组
@property (nonatomic,strong)MAPolyline *currentPolyline;    //当前的导航线路


@property (nonatomic,strong)UISearchBar *searchBar1;
@property (nonatomic,strong)UISearchBar *searchBar2;

@property (nonatomic,assign)BOOL isOrigin;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	//初始化大头针数组
	self.annotationArr = [NSMutableArray array];
	//给destinationPoint增加一个KVO
	[self addObserver:self forKeyPath:@"destinationPoint" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
	
	[self setMySearchConterl];
	[self set2DMapView];
	// Do any additional setup after loading the view, typically from a nib.
}
/**
 *  设置2D地图显示
 */
- (void)set2DMapView{
	[MAMapServices sharedServices].apiKey = APIKEY;
	self.mapView = [[MAMapView alloc] init];
	self.mapView.frame = CGRectMake(0, 108, 320, self.view.frame.size.height - 108);
	self.mapView.delegate = self;
	self.mapView.showsUserLocation = YES;
	self.mapView.userTrackingMode = MAUserTrackingModeFollow;
	[self.view addSubview:self.mapView];
}
/**
 *  2D地图显示回调方法
 *
 *  @param mapView          mapView description
 *  @param userLocation     userLocation description
 *  @param updatingLocation updatingLocation description
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
	if (updatingLocation) {
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
		//设置的当前位置 为地图中心
		self.mapView.centerCoordinate = coordinate;
	}
}
/**
 *  设置大头针点击后的气泡
 *
 *  @param mapView    mapView
 *  @param annotation annotation
 *
 *  @return 气泡
 */
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
	//	if ([annotation isKindOfClass:[MAAnnotationView class]]) {
	static NSString *identify = @"annotation";
	//在原有的大头针中添加自定义的修饰
	MAPinAnnotationView *pointAnnotation = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identify];
	if (pointAnnotation == nil) {
		//在原有的大头针中创建一个新的自定义的大头针
		pointAnnotation = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identify];
	}
	//设置是否能选中的标题
	pointAnnotation.canShowCallout = YES;
	//是否允许拖拽
	pointAnnotation.draggable = YES;
	//是否允许退拽动画
	pointAnnotation.animatesDrop = YES;
	return pointAnnotation;
}
#pragma mark - 驾车导航搜索部分
/**
 *  设置导航搜索
 */
- (void)setMapNaviSearchWithOrigin:(AMapGeoPoint *)originPoint  destination:(AMapGeoPoint *)destinationPoint{
	self.NaviSearch = [[AMapSearchAPI alloc] initWithSearchKey:APIKEY Delegate:self];
	//设置一个搜索请求
	AMapNavigationSearchRequest *naviRequest = [[AMapNavigationSearchRequest alloc] init];
	//设置搜索类型 驾车导航搜索
	naviRequest.searchType = AMapSearchType_NaviDrive;
	//设置导航的起点
	naviRequest.origin = [AMapGeoPoint locationWithLatitude:originPoint.latitude longitude:originPoint.longitude];
	//设置导航的终点
	naviRequest.destination = [AMapGeoPoint locationWithLatitude:destinationPoint.latitude longitude:destinationPoint.longitude];
	//发起导航请求
	[self.NaviSearch AMapNavigationSearch:naviRequest];
}
/**
 *  导航请求回调方法
 *  在地图线路上增加一层绿色覆盖物
 *  @param request  请求头
 *  @param response 请求结果
 */
- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response{
	if (response.route == nil) {
		return;
	}
	NSMutableArray *rounArr = [[NSMutableArray alloc] init];
	AMapRoute *ro = response.route;
	AMapPath *pa = (AMapPath *)ro.paths[0];
	for (AMapStep *step in pa.steps) {
		NSArray *arr = [step.polyline componentsSeparatedByString:@";"];
		for (NSString *ss in arr) {
			[rounArr addObject:ss];
		}
	}
	//先移除 上一次的折线对象
	[self.mapView removeOverlay:self.currentPolyline];
	//构造折线数据对象
	CLLocationCoordinate2D commonPolylineCoords[rounArr.count];
	for (int i = 0; i < rounArr.count; i ++) {
		NSString *ss = rounArr[i];
		NSArray *a = [ss componentsSeparatedByString:@","];
		commonPolylineCoords[i].latitude = ((NSString *)a[1]).floatValue;
		commonPolylineCoords[i].longitude = ((NSString *)a[0]).floatValue;
	}
	//构造折线对象
	MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:rounArr.count];
	//重新给折线对象赋值
	self.currentPolyline = commonPolyline;
	//在地图上添加折线对象
	[self.mapView addOverlay:commonPolyline];
}
/**
 *  设置折线样式
 *
 *  @param mapView mapView
 *  @param overlay overlay
 *
 *  @return 折线样式
 */
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay{
	if ([overlay isKindOfClass:[MAPolyline class]]) {
		MAPolylineView *po = [[MAPolylineView alloc] initWithPolyline:overlay];
		//设置线宽
		po.lineWidth = 8.f;
		//设置线的颜色
		po.strokeColor = [UIColor greenColor];
		return po;
 	}
	return nil;
}
#pragma mark - 正向地理编码部分
/**
 *  设置正向地理编码
 */
- (void)setMapGeoSearch:(NSString *)address{
	self.GeoSearch = [[AMapSearchAPI alloc] initWithSearchKey:APIKEY Delegate:self];
	AMapGeocodeSearchRequest *geoRequest = [[AMapGeocodeSearchRequest alloc] init];
	geoRequest.searchType = AMapSearchType_Geocode;
	geoRequest.address = address;
	geoRequest.city = @[@"guangzhou"];
	[self.GeoSearch AMapGeocodeSearch:geoRequest];
}
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response{
	if (response.count == 0) {
		return;
	}
	if (self.isOrigin == YES) {
		AMapGeocode *p = (AMapGeocode *)response.geocodes[0];
		self.originPoint = p.location;
		self.originAddress = request.address;
		NSLog(@"originPoint = %@",self.originPoint);
	}
	else{
		AMapGeocode *p = (AMapGeocode *)response.geocodes[0];
		self.destinationPoint = p.location;
		self.destinationAddress = request.address;
		NSLog(@"destinationPoint = %@",self.destinationPoint);
	}
}
#pragma mark - searchBar部分
/**
 *  设置searchBar
 */
- (void)setMySearchConterl{
	//起点搜索栏
	self.searchBar1 = [[UISearchBar alloc] init];
	self.searchBar1.frame = CGRectMake(0, 20, self.view.frame.size.width, 44);
	self.searchBar1.delegate = self;
	self.searchBar1.tag = 100;
	self.searchBar1.placeholder = @"请输入起点";
	[self.view addSubview:self.searchBar1];
	//终点搜索栏
	self.searchBar2 = [[UISearchBar alloc] init];
	self.searchBar2.frame = CGRectMake(0, 64, self.view.frame.size.width, 44);
	self.searchBar2.delegate = self;
	self.searchBar2.tag = 101;
	self.searchBar2.placeholder = @"请输入终点";
	[self.view addSubview:self.searchBar2];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
	return YES;
}
/**
 *  设置左边的“取消”按钮
 *
 *  @param searchBar searchBar
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
//	self.searchBar1.showsCancelButton = YES;
	searchBar.showsCancelButton = YES;
	for (id cc in [searchBar.subviews[0] subviews]) {
		if ([cc isKindOfClass:[UIButton class]]) {
			UIButton * cancelButton = (UIButton *)cc;
			[cancelButton setTitle:@"取消" forState:UIControlStateNormal];
		}
	}
}// called when text starts editing
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
	return YES;
}// return NO to not resign first responder

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0){
 return YES;
}// called before text changes
/**
 *  键盘搜索按钮按下就会调用这个方法
 *
 *  @param searchBar searchBar本身
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	//	NSLog(@"text = %@",searchBar.text);
	//发起地理编码搜索请求
	if (searchBar.tag == 100) {
		[self setMapGeoSearch:searchBar.text]; //发起起点搜索
		self.isOrigin = YES;  //是起点
	}
	if (searchBar.tag == 101) {
		[self setMapGeoSearch:searchBar.text]; //发起终点搜索
		self.isOrigin = NO;
	}
	//收起键盘
	[searchBar resignFirstResponder];
}// called when keyboard search button pressed
/**
 *  “取消”按钮按下会调用这个方法
 *  收起键盘
 *  @param searchBar searchBar本身
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
	searchBar.showsCancelButton = NO;
}// called when cancel button pressed

/**
 *  KVO键值监听回调方法
 *  终点不一样就发起搜索
 *  @param keyPath keyPath description
 *  @param object  object description
 *  @param change  change description
 *  @param context context description
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	//发起驾车导航搜索
	[self setMapNaviSearchWithOrigin:self.originPoint destination:self.destinationPoint];
	
	//添加大头针之前先移除上一次添加的大头针
	[self.mapView removeAnnotations:self.annotationArr];
	[self.annotationArr removeAllObjects];
	//添加终点大头针
	MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
	CLLocationCoordinate2D destinationCoordinate = CLLocationCoordinate2DMake(self.destinationPoint.latitude, self.destinationPoint.longitude);
	destinationAnnotation.coordinate = destinationCoordinate;
	destinationAnnotation.title = @"终点";
	destinationAnnotation.subtitle = self.destinationAddress;
	[self.annotationArr addObject:destinationAnnotation];
	[self.mapView addAnnotation:destinationAnnotation];
	//添加起点大头针
	MAPointAnnotation *originAnnotation = [[MAPointAnnotation alloc] init];
	CLLocationCoordinate2D originCoordinate = CLLocationCoordinate2DMake(self.originPoint.latitude, self.originPoint.longitude);
	originAnnotation.coordinate = originCoordinate;
	originAnnotation.title = @"起点";
	originAnnotation.subtitle = self.originAddress;
	[self.annotationArr addObject:originAnnotation];
	[self.mapView addAnnotation:originAnnotation];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
