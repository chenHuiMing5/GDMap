//
//  ViewController.m
//  MAMapView_Demo
//
//  Created by apple on 2021/6/24.
//

#define HSQUIColorFromRGBA(rgbValue, alphaValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)(rgbValue & 0x0000FF))/255.0 alpha:alphaValue]

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "HSQAnnotationModel.h"
#import "HSQScenicAnnotationView.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "CommonUtility.h"
#import "ProvinceMapViewViewController.h"

@interface ViewController ()<MAMapViewDelegate,HSQScenicAnnotationViewDelegate,AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapLocationManager *LocationManager;

@property (nonatomic, strong) AMapSearchAPI *search;  // 行政区域搜索

@property (nonatomic, strong) AMapDistrictSearchRequest *dist;  ///行政区划查询请求

@property (nonatomic, strong) NSMutableArray *overlays;

@property (nonatomic, assign) MACoordinateRegion boundary;

@property (nonatomic, strong) MAPolyline *polyline;

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (MAMapView *)mapView{
    
    if (!_mapView) {
        
        _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        _mapView.mapType = MAMapTypeStandard; //普通样式
        _mapView.desiredAccuracy = kCLLocationAccuracyThreeKilometers; //设置定位精度
        _mapView.distanceFilter = 5.0f; //设置定位距离
        _mapView.zoomEnabled = YES; // 是否支持缩放
        _mapView.scrollEnabled = YES; // 禁止拖动地图
        _mapView.rotateEnabled = NO; // 是否支持旋转, 默认YES
        _mapView.showsLabels = NO;  // 是否显示标注，就是地点的名字
        _mapView.showsBuildings = NO;
        [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES]; //地图跟着位置移动
        _mapView.showsCompass = NO; //设置成NO表示关闭指南针；YES表示显示指南针
        _mapView.compassOrigin= CGPointMake(_mapView.compassOrigin.x, 22); //设置指南针位置
        _mapView.scaleOrigin= CGPointMake(_mapView.scaleOrigin.x, 22);  //设置比例尺位置
        _mapView.showsScale= NO; //设置成NO表示不显示比例尺；YES表示显示比例尺
        _mapView.rotateCameraEnabled = NO;
        //开启定位  如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
//        _mapView.showsUserLocation = NO;
//        _mapView.userTrackingMode = MAUserTrackingModeNone;
        
        ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
        _mapView.minZoomLevel = 3.328329; //  最小缩放级别
        _mapView.maxZoomLevel = 5.0; //  最大缩放级别
        //缩放等级
        [_mapView setZoomLevel:3.328329 atPivot:self.view.center animated:YES];
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(25.400048, 105.684499) animated:NO];
        [AMapServices sharedServices].enableHTTPS = YES;
    }
    
    return _mapView;;
}

- (AMapSearchAPI *)search{
    
    if (_search == nil) {
        
        _search = [[AMapSearchAPI alloc] init];
        _search.delegate = self;
    }
    return _search;
}

- (AMapDistrictSearchRequest *)dist{
    
    if (_dist == nil) {
        
        _dist = [[AMapDistrictSearchRequest alloc] init];
        _dist.requireExtension = YES;
    }
    return _dist;
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
//    [self.mapView addOverlays:self.overlays];

    //注意，不要viewWillAppear里设置
    [self.mapView setLimitRegion:_boundary];
    
    NSLog(@"111111===%f===%f===%f",_boundary.span.latitudeDelta,_boundary.span.longitudeDelta,_boundary.center.latitude);
}

- (void)initBoundaryOverlay{
    
    self.overlays = [NSMutableArray array];
    
    CLLocationCoordinate2D line1Points[5];
    line1Points[0] = CLLocationCoordinate2DMake(69.739380, 72.206722);
    line1Points[1] = CLLocationCoordinate2DMake(69.739380, 139.162276);
    line1Points[2] = CLLocationCoordinate2DMake(-19.998048, 139.162276);
    line1Points[3] = CLLocationCoordinate2DMake(-19.998048, 72.206722);
    line1Points[4] = CLLocationCoordinate2DMake(69.739380, 72.206722);
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:line1Points count:5];
//    self.polyline = polyline;
    [self.overlays addObject:polyline];
    
    CGFloat latitudeDelta = line1Points[0].latitude - line1Points[2].latitude;
    CGFloat longitudeDelta = line1Points[1].longitude - line1Points[0].longitude;
    
    CGFloat center_lat = line1Points[0].latitude + line1Points[3].latitude;
    CGFloat center_long = line1Points[0].longitude + line1Points[1].longitude;
    _boundary = MACoordinateRegionMake(CLLocationCoordinate2DMake(center_lat/2, center_long/2), MACoordinateSpanMake(latitudeDelta, longitudeDelta));

    
//    _boundary = MACoordinateRegionMake(CLLocationCoordinate2DMake(36.400048, 105.684499), MACoordinateSpanMake(latitudeDelta, longitudeDelta));

//    ==68.129840===66.955553===56.856683
//    ==89.737428=====66.955554
    NSLog(@"2222222====%f=====%f",latitudeDelta,longitudeDelta);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //把地图添加至view
    [self.view addSubview:self.mapView];
    
    // 限制地图的显示范围
    [self initBoundaryOverlay];
    
    // 添加点标
    [self AddAnnotations];
    
    // 将中国渲染成红色
//    AMapDistrictSearchRequest *dist = [[AMapDistrictSearchRequest alloc] init];
//    dist.keywords = @"中国";
//    dist.requireExtension = YES;
//    dist.offset = 1;
//    [self.search AMapDistrictSearch:dist];
    
    // 参数为当前地图东北跟西南角的坐标
    MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake(70.30433506065565, 136.17473682260024),
                                                                 CLLocationCoordinate2DMake(-41.462363094698584, 69.01756183451296)
                                                                 );
    MAGroundOverlay *groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageNamed:@"HomeMapBgView"]];

    [_mapView addOverlay:groundOverlay];

    _mapView.visibleMapRect = groundOverlay.boundingMapRect;
//
//    [_mapView setMinZoomLevel:3.328329];
    
}

- (void)AddAnnotations{
        
    MAPointAnnotation *model_01 = [[MAPointAnnotation alloc] init];
    model_01.coordinate = CLLocationCoordinate2DMake(26.494494,100.981085);
    model_01.title = @"云南省";
    model_01.subtitle = @"7";
    [self.mapView addAnnotation:model_01];
    
    MAPointAnnotation *model_02 = [[MAPointAnnotation alloc] init];
    model_02.coordinate = CLLocationCoordinate2DMake(36.675807, 117.000923);
    model_02.title = @"山东省";
    model_02.subtitle = @"2";
    [self.mapView addAnnotation:model_02];
    
    MAPointAnnotation *model_03 = [[MAPointAnnotation alloc] init];
    model_03.coordinate = CLLocationCoordinate2DMake(32.05000, 119.78333);
    model_03.title = @"江苏省";
    model_03.subtitle = @"1";
    [self.mapView addAnnotation:model_03];
    
    MAPointAnnotation *model_04 = [[MAPointAnnotation alloc] init];
    model_04.coordinate = CLLocationCoordinate2DMake(30.26667, 120.20000);
    model_04.title = @"浙江省";
    model_04.subtitle = @"1";
    [self.mapView addAnnotation:model_04];

//    [self.mapView addAnnotations:dataSource];
//
//     // 添加大头针
//    [self.mapView setSelectedAnnotations:dataSource];
    
    NSLog(@"annotations=====%@",self.mapView.annotations);
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *string = @"HSQScenicAnnotationView";
        
        HSQScenicAnnotationView *annotationView = (HSQScenicAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:string];
        
        //如果缓存池中不存在则新建
        if (!annotationView)
        {
            annotationView=[[HSQScenicAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:string];            
        }
        
        annotationView.model = (MAPointAnnotation *)annotation;
        
        annotationView.delegate = self;
                        
        return annotationView;
        
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    
    NSLog(@"我被点击啦");
}

- (void)ProvinceButtonClickAction:(UIButton *)sender annotation:(MAPointAnnotation *)annotation{
    
    NSLog(@"==你点击了==%f===%f",annotation.coordinate.latitude,annotation.coordinate.longitude);
    
//    [self.mapView setZoomLevel:5.694433 animated:YES];
//    [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    
//    AMapDistrictSearchRequest *dist = [[AMapDistrictSearchRequest alloc] init];
//    dist.keywords = annotation.title;
//    dist.requireExtension = YES;
//    [self.search AMapDistrictSearch:dist];
    
    ProvinceMapViewViewController *vc = [[ProvinceMapViewViewController alloc] init];
    vc.annotation = annotation;
    [self.navigationController pushViewController:vc animated:YES];
    
     // 图片覆盖物类为 MAGroundOverlay，可完成将一张图片以合适的大小贴在地图指定的位置上的功能。 northEast ：东北  southWest ：西南
    
//    if ([annotation.title isEqualToString:@"云南省"])
//    {
//        // 云南
//        MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake(35.668464, 108.457075),
//                                                                     CLLocationCoordinate2DMake(14.126556, 94.990641)
//                                                                     );
//        MAGroundOverlay *groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageNamed:@"yunNan"]];
//
//        [_mapView addOverlay:groundOverlay];
//        _mapView.visibleMapRect = groundOverlay.boundingMapRect;
//    }
//    else if([annotation.title isEqualToString:@"江苏省"])
//    {
//        // 江苏省
//        MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake(38.870907, 123.270562),
//                                                                     CLLocationCoordinate2DMake(26.837380, 115.189625)
//                                                                     );
//        MAGroundOverlay *groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageNamed:@"jiangSu"]];
//
//        [_mapView addOverlay:groundOverlay];
//        _mapView.visibleMapRect = groundOverlay.boundingMapRect;
//    }
//    else if ([annotation.title isEqualToString:@"山东省"])
//    {
//        MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake(42.582500, 123.265798),
//                                                                     CLLocationCoordinate2DMake(29.718001, 114.269416)
//                                                                     );
//        MAGroundOverlay *groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageNamed:@"shandongProvince"]];
//
//        [_mapView addOverlay:groundOverlay];
//        _mapView.visibleMapRect = groundOverlay.boundingMapRect;
//    }
    
//    // 限制地图的显示范围
//    MACoordinateSpan span = MACoordinateSpanMake(21.386985, 13.379271);
//    MACoordinateRegion region = MACoordinateRegionMake(CLLocationCoordinate2DMake(25.472011, 101.670350), span);
//    
//    //解决地图越拉近，指定的坐标越偏右的问题。
//    MAMapRect rect = MAMapRectForCoordinateRegion(region);
//    [self.mapView setVisibleMapRect:rect animated:YES];
//    
//    [self.mapView setRegion:region animated:YES];
}




/**
 * @brief 地图区域即将改变时会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
    NSLog(@"地图区域即将改变时会调用此接口");
}

/**
 * @brief 地图区域改变完成后会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    NSLog(@"地图区域改变完成后会调用此接口");
    
    
    CLLocationCoordinate2D centerPoint = mapView.centerCoordinate;

    NSLog(@"==地图的中心坐标=%f===%f",centerPoint.latitude,centerPoint.longitude);

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
    
    //解析response获取行政区划，具体解析见 Demo
    for (AMapDistrict *dist in response.districts)
    {
//        NSLog(@"==行政区域查询=%f===%f===%@==%@===%@===%@",dist.center.latitude,dist.center.longitude,dist.name,dist.polylines,dist.level,dist.districts);
        NSLog(@"==行政区域查询=%f===%f===%@=====%@===%ld",dist.center.latitude,dist.center.longitude,dist.name,dist.level,dist.districts.count);
//        NSLog(@"==行政区域查询 =%f===%f===%@==",dist.center.latitude,dist.center.longitude,dist.name);
        
        
//        if ([dist.name isEqualToString:@"云南省"])
//        {
//            // 云南
//            MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake(35.668464, 108.457075),
//                                                                         CLLocationCoordinate2DMake(14.126556, 94.990641)
//                                                                         );
//            MAGroundOverlay *groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageNamed:@"yunNan"]];
//
//            [_mapView addOverlay:groundOverlay];
//            _mapView.visibleMapRect = groundOverlay.boundingMapRect;
//
//            [_mapView setMinZoomLevel:5.727655];
//
//        }
    }

    [self handleDistrictResponse:response];
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
            NSLog(@"=bounds==%f===%f===%f==%f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
            

        }
        
    }
    
}

/**
 * @brief 单击地图回调，返回经纬度
 * @param mapView 地图View
 * @param coordinate 经纬度
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
    NSLog(@"==单击地图回调=经度：%f===纬度：%f",coordinate.longitude,coordinate.latitude);
    
    CGPoint View_point = [self.mapView convertCoordinate:coordinate toPointToView:self.view];
    NSLog(@"View_point===%f===%f",View_point.x,View_point.y);
}

@end
