//
//  HSQScenicAnnotationView.h
//  MAMapView_Demo
//
//  Created by apple on 2021/6/24.
//

#import <MAMapKit/MAMapKit.h>

@class MAPointAnnotation;

@protocol HSQScenicAnnotationViewDelegate <NSObject>

@optional

- (void)ProvinceButtonClickAction:(UIButton *)sender annotation:(MAPointAnnotation *)annotation;

@end

@interface HSQScenicAnnotationView : MAAnnotationView

@property (nonatomic, strong) MAPointAnnotation *model;

@property (nonatomic, weak) id<HSQScenicAnnotationViewDelegate>delegate;

@end


