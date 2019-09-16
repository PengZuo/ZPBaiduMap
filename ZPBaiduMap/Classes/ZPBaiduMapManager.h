//
//  ZPBaiduMapManager.h
//  Pods-ZPBaiduMap_Example
//
//  Created by Uncel_Left on 2019/9/16.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import "ZPBaiduModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZPBaiduDelegate <NSObject>
    
@end

@interface ZPBaiduMapManager : NSObject

@property (nonatomic, strong) BMKMapView *mapView; //当前界面的mapView

@property (nonatomic, weak) id<ZPBaiduDelegate> ZPBaiduDelegate;
@property (nonatomic, strong) BMKLocationManager *locationManager; //定位对象

- (instancetype)initWithFrame:(CGRect)frame zoomLevel:(int)zoomLevel;

/**
 创建(多)标注点
 
 @param data 数据
 */
- (void)zp_createMoreAnnotationWithData:(NSMutableArray<ZPBaiduModel *> *)data;
/**
 创建(单个)标注点
 
 @param latitude 纬度
 @param longitude 经度
 */
- (void)zp_createASingleAnnotationWithLatitude:(NSString *)latitude longitude:(NSString *)longitude;

/**
 地图定位

 @param zoomLevel 地图比例尺村
 */
- (void)zp_mapPositioningWithZoomLevel:(int)zoomLevel;

/**
 地图比例放大
 */
- (void)zp_mapAmplification;

/**
 地图比例缩小
 */
- (void)zp_mapNarrow;

/**
 根据anntation生成对应的annotationView（自定义图标View）
 
 @param mapView 地图
 @param annotation 坐标点
 @param pointName 点的名称（不为空为单点，空为多点）
 @param textColor 文字颜色
 @param backgroundColor 背景颜色
 @return 坐标点view
 */
+ (BMKPinAnnotationView *)zp_mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation pointName:(NSString *)pointName textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor ;

/**
 选中view动画
 
 @param view 坐标点View
 */
- (void)zp_didSelectView:(BMKAnnotationView *)view;

/**
 未选中view动画
 
 @param view 坐标点View
 */
- (void)zp_didDeselectView:(BMKAnnotationView *)view;

@end

NS_ASSUME_NONNULL_END
