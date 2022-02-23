//
//  ProvinceMapViewViewController.m
//  MAMapView_Demo
//
//  Created by apple on 2021/7/9.
//

#import "ProvinceMapViewViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "HSQAnnotationModel.h"
#import "HSQScenicAnnotationView.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "CommonUtility.h"

@interface ProvinceMapViewViewController ()<MAMapViewDelegate,HSQScenicAnnotationViewDelegate,AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapSearchAPI *search;  // 行政区域搜索

@property (nonatomic, assign) MACoordinateRegion boundary;

@property (nonatomic, strong) UIImageView *Backgroup_View;

@end

@implementation ProvinceMapViewViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (AMapSearchAPI *)search{
    
    if (_search == nil) {
        
        _search = [[AMapSearchAPI alloc] init];
        _search.delegate = self;
    }
    return _search;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"我是省级地图";
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"yunNan"]];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
     [AMapServices sharedServices].enableHTTPS = YES;
    
    // 创建地图
    [self CreatMapView];
    
    // 限制地图的显示范围
    [self initBoundaryOverlay];
    
    self.mapView.minZoomLevel = 3.257381; //  最小缩放级别
    self.mapView.maxZoomLevel = 10.353432; //  最大缩放级别
        
//    AMapDistrictSearchRequest *dist = [[AMapDistrictSearchRequest alloc] init];
//    dist.keywords = self.annotation.title;
//    dist.requireExtension = YES;
//    [self.search AMapDistrictSearch:dist];
    
    // 云南
    MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake(35.668464, 108.457075),
                                                                 CLLocationCoordinate2DMake(14.126556, 94.990641)
                                                                 );
    MAGroundOverlay *groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageNamed:@"yunNan"]];

    [self.mapView addOverlay:groundOverlay];
    self.mapView.visibleMapRect = groundOverlay.boundingMapRect;

    [self.mapView setMinZoomLevel:5.727655];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.mapView.hidden = NO;
    });
    
    // 添加测试View
    UIView *text_View = [[UIView alloc] init];
    text_View.frame = CGRectMake(0, 0, 10, 10);
    text_View.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:text_View];
    
    // 返回按钮
    UIButton *back_btn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    back_btn.backgroundColor = [UIColor orangeColor];
    back_btn.frame = CGRectMake(200, 0, 200, 100);
    [back_btn addTarget:self action:@selector(back:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:back_btn];
}

- (void)back:(UIButton *)sender{
    
    NSLog(@"=====我来啦");
    
    [self.navigationController popViewControllerAnimated:YES];

}


/**
 * @brief 创建地图
 */
- (void)CreatMapView{
    
    MAMapView *mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    mapView.delegate = self;
    mapView.mapType = MAMapTypeStandard; //普通样式
    mapView.desiredAccuracy = kCLLocationAccuracyBest; //设置定位精度
    mapView.distanceFilter = 5.0f; //设置定位距离
    mapView.zoomEnabled = YES; // 是否支持缩放
    mapView.scrollEnabled = YES; // 禁止拖动地图
    mapView.rotateEnabled = NO; // 是否支持旋转, 默认YES
    mapView.showsLabels = NO;  // 是否显示标注，就是地点的名字
    [mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES]; //地图跟着位置移动
    mapView.showsCompass = NO; //设置成NO表示关闭指南针；YES表示显示指南针
    mapView.compassOrigin= CGPointMake(_mapView.compassOrigin.x, 22); //设置指南针位置
    mapView.scaleOrigin= CGPointMake(_mapView.scaleOrigin.x, 22);  //设置比例尺位置
    mapView.showsScale= NO; //设置成NO表示不显示比例尺；YES表示显示比例尺
    mapView.rotateCameraEnabled = NO;
    //开启定位  如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
//        _mapView.showsUserLocation = NO;
//        _mapView.userTrackingMode = MAUserTrackingModeNone;
    mapView.hidden = YES;
    ///把地图添加至view
    [self.view addSubview:mapView];
    self.mapView = mapView;
}


/**
 * @brief 限制地图的显示范围
 */
- (void)initBoundaryOverlay{
    
    CLLocationCoordinate2D line1Points[5];
    line1Points[0] = CLLocationCoordinate2DMake(35.028357, 95.492712);
    line1Points[1] = CLLocationCoordinate2DMake(35.028357, 108.232988);
    line1Points[2] = CLLocationCoordinate2DMake(14.617498, 108.232988);
    line1Points[3] = CLLocationCoordinate2DMake(14.617498, 95.492712);
    line1Points[4] = CLLocationCoordinate2DMake(35.028357, 95.492712);
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:line1Points count:5];
    [self.mapView addOverlay:polyline];
    
    CGFloat latitudeDelta = line1Points[0].latitude - line1Points[2].latitude;
    CGFloat longitudeDelta = line1Points[1].longitude - line1Points[0].longitude;
    
    CGFloat center_lat = (line1Points[0].latitude + line1Points[3].latitude)/2;
    CGFloat center_long = (line1Points[0].longitude + line1Points[1].longitude)/2;
    
    _boundary = MACoordinateRegionMake(CLLocationCoordinate2DMake(center_lat, center_long), MACoordinateSpanMake(latitudeDelta, longitudeDelta));
    
    //注意，不要viewWillAppear里设置
    [self.mapView setLimitRegion:_boundary];
}


/**
 * @brief 地图区域改变完成后会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    NSLog(@"地图区域改变完成后会调用此接口");
    
    CLLocationCoordinate2D centerPoint = mapView.centerCoordinate;
    
    NSLog(@"===%f===%f",centerPoint.latitude,centerPoint.longitude);
    
    NSLog(@"=zoomLevel==%f",mapView.zoomLevel);
    
//    [mapView setCenterCoordinate:CLLocationCoordinate2DMake(36.381034, 104.631776) animated:YES];
        
    MACoordinateSpan span = self.mapView.region.span;
    
    NSLog(@"==self.mapView.region==%f===%f===%f",span.latitudeDelta,span.longitudeDelta,self.mapView.region.center.latitude);
    
    // 将View的坐标点转化为经纬度
    CLLocationCoordinate2D top_left = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
    NSLog(@"top_left===%f===%f",top_left.latitude,top_left.longitude);
    
    CLLocationCoordinate2D top_right = [self.mapView convertPoint:CGPointMake(375, 0) toCoordinateFromView:self.mapView];
    NSLog(@"top_right===%f===%f",top_right.latitude,top_right.longitude);
    
    CLLocationCoordinate2D center = [self.mapView convertPoint:self.view.center toCoordinateFromView:self.mapView];
    NSLog(@"center===%f===%f",center.latitude,center.longitude);
    
    CLLocationCoordinate2D bottom_left = [self.mapView convertPoint:CGPointMake(0, 667) toCoordinateFromView:self.mapView];
    NSLog(@"bottom_left===%f===%f",bottom_left.latitude,bottom_left.longitude);
    
    CLLocationCoordinate2D bottom_right = [self.mapView convertPoint:CGPointMake(375, 667) toCoordinateFromView:self.mapView];
    NSLog(@"bottom_right===%f===%f",bottom_right.latitude,bottom_right.longitude);
    
    NSLog(@"frame==%@",NSStringFromCGRect(self.view.bounds));
    
    
    CLLocationCoordinate2D shandong_right = [self.mapView convertPoint:CGPointMake(375, 230) toCoordinateFromView:self.mapView];
    NSLog(@"bottom_right===%f===%f",shandong_right.latitude,shandong_right.longitude);
    
    CLLocationCoordinate2D shandong_left = [self.mapView convertPoint:CGPointMake(0, 455) toCoordinateFromView:self.mapView];
    NSLog(@"bottom_right===%f===%f",shandong_left.latitude,shandong_left.longitude);
    
    
    CGRect ViewRect = [self.mapView convertRegion:MACoordinateRegionMake(centerPoint, span) toRectToView:self.mapView];
    NSLog(@"==ViewRect==%@",NSStringFromCGRect(ViewRect));
    
    MACoordinateRegion region = [self.mapView convertRect:CGRectMake(0, 0, 375, 667) toRegionFromView:self.view];
    NSLog(@"===region==%f===%f===%f==longitudeDelta=%f",region.center.latitude,region.center.longitude,region.span.latitudeDelta,region.span.longitudeDelta);
    
    
}


#pragma mark **************************************************** 行政区域查询 ****************************************

- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response{
    
    NSLog(@"response: %@", response);
    
//    //解析response获取行政区划，具体解析见 Demo
//    for (AMapDistrict *dist in response.districts)
//    {
////        NSLog(@"==行政区域查询=%f===%f===%@==%@",dist.center.latitude,dist.center.longitude,dist.name,dist.polylines);
////        NSLog(@"==行政区域查询 =%f===%f===%@==",dist.center.latitude,dist.center.longitude,dist.name);
//
//
//    }
    
//    if ([self.annotation.title isEqualToString:@"云南省"])
//    {
//        // 云南
//        MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake(35.668464, 108.457075),
//                                                                     CLLocationCoordinate2DMake(14.126556, 94.990641)
//                                                                     );
//        MAGroundOverlay *groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageNamed:@"yunNan"]];
//
//        [_mapView addOverlay:groundOverlay];
//        _mapView.visibleMapRect = groundOverlay.boundingMapRect;
//
//        [_mapView setMinZoomLevel:5.727655];
//
//    }
    
//    [self.mapView removeOverlays:self.mapView.overlays];
    
//    [self.mapView removeAnnotations:self.mapView.annotations];
    
//    [self handleDistrictResponse:response];
    
    NSLog(@"我在bounds的后面");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        self.mapView.hidden = NO;
        
        
    });
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    
    NSLog(@"Error: %@", error);
}

/**
 * @brief 根据overlay生成对应的Renderer
 * @param mapView 地图View
 * @param overlay 指定的overlay
 * @return 生成的覆盖物Renderer
 */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygonRenderer *render = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        
        render.lineWidth   = 2.0f;
//        render.fillColor = HSQUIColorFromRGBA(0x3043DC, 1.0);
//        render.fillColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ProductPlacherImage"]];
        render.strokeColor = [UIColor purpleColor];
        
        return render;
    }
    else if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.lineWidth   = 2.f;
        polylineRenderer.fillColor = [UIColor greenColor];
        polylineRenderer.strokeColor = [UIColor redColor];
        
        return polylineRenderer;
    }
    else if ([overlay isKindOfClass:[MAGroundOverlay class]])
    {
        MAGroundOverlayRenderer *groundOverlayRenderer = [[MAGroundOverlayRenderer alloc] initWithGroundOverlay:overlay];

        return groundOverlayRenderer;
    }
    
    return nil;
}


- (void)handleDistrictResponse:(AMapDistrictSearchResponse *)response{
    
    if (response == nil)
    {
        return;
    }
    
    for (AMapDistrict *dist in response.districts)
    {
        MAPointAnnotation *poiAnnotation = [[MAPointAnnotation alloc] init];
        
        poiAnnotation.coordinate = CLLocationCoordinate2DMake(dist.center.latitude, dist.center.longitude);
        poiAnnotation.title      = dist.name;
        poiAnnotation.subtitle   = dist.adcode;
        
//        [self.mapView addAnnotation:poiAnnotation];
        
        if (dist.polylines.count > 0)
        {
            MAMapRect bounds = MAMapRectZero;
            
            for (NSString *polylineStr in dist.polylines)
            {
                MAPolyline *polyline = [CommonUtility polylineForCoordinateString:polylineStr];
                
                [self.mapView addOverlay:polyline];
                
                if(MAMapRectEqualToRect(bounds, MAMapRectZero))
                {
                    bounds = polyline.boundingMapRect;
                }
                else
                {
                    bounds = MAMapRectUnion(bounds, polyline.boundingMapRect);
                }
            }
            
            for (NSString *polylineStr in dist.polylines)
            {
                NSUInteger tempCount = 0;
                CLLocationCoordinate2D *coordinates = [CommonUtility coordinatesForString:polylineStr
                                                                          coordinateCount:&tempCount
                                                                               parseToken:@";"];
                
                
                MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:tempCount];
                free(coordinates);
                [self.mapView addOverlay:polygon];
            }
            [self.mapView setVisibleMapRect:bounds animated:YES];
        }
    }
}

/**
 * @brief 单击地图回调，返回经纬度
 * @param mapView 地图View
 * @param coordinate 经纬度
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
    NSLog(@"==单击地图回调=%f===%f",coordinate.latitude,coordinate.longitude);
    
    CGPoint View_point = [self.mapView convertCoordinate:coordinate toPointToView:self.view];
    NSLog(@"View_point===%f===%f",View_point.x,View_point.y);
}

@end
