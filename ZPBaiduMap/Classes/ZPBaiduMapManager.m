//
//  ZPBaiduMapManager.m
//  Pods-ZPBaiduMap_Example
//
//  Created by Uncel_Left on 2019/9/16.
//

#import "ZPBaiduMapManager.h"

//复用annotationView的指定唯一标识
static NSString *annotationViewIdentifier = @"com.Baidu.BMKPointAnnotation";

@interface ZPBaiduMapManager ()<ZPBaiduDelegate, BMKLocationManagerDelegate, BMKMapViewDelegate>
@property (nonatomic, strong) NSMutableArray     *arr;//要展示的坐标点数组
@property (nonatomic, strong) BMKUserLocation    *userLocation; //当前位置对象
@property (nonatomic, strong) BMKPointAnnotation *annotation; //当前界面的标注

@end

@implementation ZPBaiduMapManager

#pragma mark - Initialization method
+ (void)initialize {
    //获取个性化地图模板文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"zm_map" ofType:@""];
    //设置个性化地图样式
    [BMKMapView customMapStyle:path];
}

- (instancetype)initWithFrame:(CGRect)frame zoomLevel:(int)zoomLevel {
    self = [super init];
    if(self != nil) {
        [self setMapViewWithFrame:frame zoomLevel:zoomLevel];
    }
    return self;
}

- (void)setMapViewWithFrame:(CGRect)frame zoomLevel:(int)zoomLevel {
    _mapView = [[BMKMapView alloc] initWithFrame:frame];
    [_mapView setZoomLevel:zoomLevel];
    self.mapView.showsUserLocation = NO;
    //设置定位模式为定位方向模式
    _mapView.userTrackingMode = BMKUserTrackingModeHeading;
    self.mapView.showsUserLocation = YES;
    self.mapView.isSelectedAnnotationViewFront = YES;//设定是否总让选中的annotaion置于最前面
    
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    //根据配置参数更新定位图层样式
    //定位图标名称，需要将该图片放到 mapapi.bundle/images 目录下
    param.locationViewImgName = @"home_map_current_position";
    //    param.isRotateAngleValid =true;//跟随态旋转角度是否生效
    param.isAccuracyCircleShow =false;//精度圈是否显示
    //    param.locationViewOffsetX =0;//定位偏移量(经度)
    //    param.locationViewOffsetY =0;//定位偏移量（纬度）
    [_mapView updateLocationViewWithParam:param];
}

- (void)zp_createMoreAnnotationWithData:(NSMutableArray<ZPBaiduModel *> *)data {
    self.arr = [NSMutableArray array];
    for (int i = 0; i < data.count; i++) {
        
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(data[i].latitude.doubleValue,data[i].longitude.doubleValue);
        //初始化标注类BMKPointAnnotation的实例
        _annotation = [[BMKPointAnnotation alloc] init];
        //设置标注的经纬度坐标
        _annotation.coordinate =  CLLocationCoordinate2DMake(coor.latitude, coor.longitude);
        //设置标注的标题(这个标题存的是网吧ID，可以根据这个网吧ID获取该坐标数据)
        _annotation.title = [NSString stringWithFormat:@"%@", data[i].title];
        [self.arr addObject:_annotation];
    }
    [_mapView addAnnotations:self.arr];
}

- (void)zp_createASingleAnnotationWithLatitude:(NSString *)latitude longitude:(NSString *)longitude {
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(latitude.doubleValue,longitude.doubleValue);
    //初始化标注类BMKPointAnnotation的实例
    _annotation = [[BMKPointAnnotation alloc] init];
    //设置标注的经纬度坐标
    _annotation.coordinate =  CLLocationCoordinate2DMake(coor.latitude, coor.longitude);
    [_mapView addAnnotation:_annotation];
    [_mapView setCenterCoordinate:_annotation.coordinate animated:YES];
}

- (void)zp_mapPositioningWithZoomLevel:(int)zoomLevel {
    //设置定位模式为定位方向模式
    _mapView.userTrackingMode = BMKUserTrackingModeHeading;
    self.mapView.showsUserLocation = YES;
    [_mapView setZoomLevel:zoomLevel];
    self.mapView.centerCoordinate = self.userLocation.location.coordinate;//设置地图中心
}

/**
 设置地图比例尺级别
 2D地图：4-21级
 3D地图：19-21级
 卫星图：4-20级
 路况交通图：7-20级
 城市热力图：11-20级
 室内图：17-22级
 */
- (void)zp_mapAmplification {
    [_mapView zoomIn];
}

- (void)zp_mapNarrow {
    [_mapView zoomOut];
}

+ (BMKPinAnnotationView *)zp_mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation pointName:(NSString *)pointName textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor {
    
    BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier];
    annotationView.canShowCallout = NO;//解决annotation.title = @""或nil时候点击方法不好用的问题
    
    if ([pointName isEqualToString:@""]) {//多点
        annotationView.image = [UIImage imageNamed:@"home_map_locale"];
        [annotationView setBounds:CGRectMake(0, 0, 36, 36)];
        annotationView.draggable = YES;
        annotationView.annotation = annotation;
        
    }else {//单点
        UILabel *annotationLabel = [[UILabel alloc] init];
        annotationLabel.textColor = textColor;
        annotationLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size: 12];
        annotationLabel.textAlignment = NSTextAlignmentCenter;
        annotationLabel.hidden = NO;
        annotationLabel.text = pointName;
        annotationLabel.backgroundColor = backgroundColor;
        annotationLabel.layer.cornerRadius = 3;
        annotationLabel.clipsToBounds = YES;
        CGSize maximumLabelSize = CGSizeMake(142, 9999);//labelsize的最大值
        CGSize expectSize = [annotationLabel sizeThatFits:maximumLabelSize];
        if (expectSize.width > 142) {//目前做最宽142，字多了省略号，并且不换行
            expectSize.width = 142;
        }
        annotationLabel.frame = CGRectMake(50, 12, expectSize.width+6, 27);
        
        [annotationView addSubview:annotationLabel];
        
        annotationView.image = [UIImage imageNamed:@"home_map_locale"];
        [annotationView setBounds:CGRectMake(0, 0, 50, 50)];
        annotationView.draggable = YES;
        annotationView.annotation = annotation;
    }
    return annotationView;
}

- (void)zp_didSelectView:(BMKAnnotationView *)view {
    [view setBounds:CGRectMake(0, 0, 50, 50)];
}

- (void)zp_didDeselectView:(BMKAnnotationView *)view {
    [view setBounds:CGRectMake(0, 0, 36, 36)];
}

#pragma mark - BMKLocationManagerDelegate
/**
 @brief 当定位发生错误时，会调用代理的此方法
 @param manager 定位 BMKLocationManager 类
 @param error 返回的错误，参考 CLError
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"定位失败");
    //此处搞一个默认坐标
//    CLLocation *defaultLocation = [[CLLocation alloc] initWithLatitude:[ZMLocationManager locationCache].latitude longitude:[ZMLocationManager locationCache].longitude];
//    self.userLocation.location = defaultLocation;
//    [_mapView updateLocationData:self.userLocation];
}

/**
 @brief 该方法为BMKLocationManager提供设备朝向的回调方法
 @param manager 提供该定位结果的BMKLocationManager类的实例
 @param heading 设备的朝向结果
 */
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    if (!heading) {
        return;
    }
    //        NSLog(@"用户方向更新");
    self.userLocation.heading = heading;
    [_mapView updateLocationData:self.userLocation];
}

/**
 @brief 连续定位回调函数
 @param manager 定位 BMKLocationManager 类
 @param location 定位结果，参考BMKLocation
 @param error 错误信息。
 */
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if (!location) {
        return;
    }
    self.userLocation.location = location.location;
    //实现该方法，否则定位图标不出现
    [_mapView updateLocationData:self.userLocation];
}

#pragma mark - Lazy loading
- (BMKLocationManager *)locationManager {
    if (!_locationManager) {
        //初始化BMKLocationManager类的实例
        _locationManager = [[BMKLocationManager alloc] init];
        //设置定位管理类实例的代理
        _locationManager.delegate = self;
        //设定定位坐标系类型，默认为 BMKLocationCoordinateTypeGCJ02
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        //设定定位精度，默认为 kCLLocationAccuracyBest
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设定定位类型，默认为 CLActivityTypeAutomotiveNavigation
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        //指定定位是否会被系统自动暂停，默认为NO
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        /**
         是否允许后台定位，默认为NO。只在iOS 9.0及之后起作用。
         设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
         由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
         */
        _locationManager.allowsBackgroundLocationUpdates = NO;
        /**
         指定单次定位超时时间,默认为10s，最小值是2s。注意单次定位请求前设置。
         注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)
         后开始计算。
         */
        _locationManager.locationTimeout = 10;
    }
    return _locationManager;
}

- (BMKUserLocation *)userLocation {
    if (!_userLocation) {
        //初始化BMKUserLocation类的实例
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}

@end
