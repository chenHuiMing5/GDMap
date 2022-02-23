//
//  HSQAnnotationModel.h
//  MAMapView_Demo
//
//  Created by apple on 2021/6/24.
//

#import <MAMapKit/MAMapKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface HSQAnnotationModel : MAPointAnnotation

@property (nonatomic, assign) float latitude; // 经度

@property (nonatomic, assign) float longitude; // 维度

@property (nonatomic, copy) NSString *province; // 省

@property (nonatomic, copy) NSString *scenicCount; //景区数量

@end

NS_ASSUME_NONNULL_END
