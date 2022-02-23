//
//  HSQScenicAnnotationView.m
//  MAMapView_Demo
//
//  Created by apple on 2021/6/24.
//

#define kSpacing 5
#define kDetailFontSize 12
#define kViewOffset 80

#import "HSQScenicAnnotationView.h"
#import "HSQAnnotationModel.h"

@interface HSQScenicAnnotationView ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UIImageView *icon_View;

@property (nonatomic, strong) UIButton *annotation_Btn;

@end

@implementation HSQScenicAnnotationView

-(instancetype)init{
    
    if(self=[super init]){
        [self layoutUI];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self=[super initWithFrame:frame]) {
        
        [self layoutUI];
    }
    
    return self;
}

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        
        [self layoutUI];
    }
    
    return self;
}

-(void)layoutUI{
    
//    self.backgroundColor = [UIColor redColor];
    
    //背景
    self.backgroundView=[[UIView alloc]init];
    self.backgroundView.backgroundColor=[UIColor clearColor];
        
    // 位置的名字
    self.detailLabel=[[UILabel alloc]init];
    self.detailLabel.lineBreakMode=NSLineBreakByWordWrapping;
    //[_text sizeToFit];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.font = [UIFont systemFontOfSize:kDetailFontSize];
    self.detailLabel.backgroundColor = [UIColor whiteColor];
    self.detailLabel.textColor = [UIColor purpleColor];
    
    // 绘制边框
    self.detailLabel.layer.masksToBounds = YES; //允许绘制
    self.detailLabel.layer.cornerRadius = 8;//边框弧度
    self.detailLabel.layer.borderColor = [UIColor redColor].CGColor; //边框颜色
    self.detailLabel.layer.borderWidth = 1; //边框的宽度
    
    self.icon_View = [[UIImageView alloc] init];
    self.icon_View.image = [UIImage imageNamed:@"pin"];
    [self addSubview:self.icon_View];
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.detailLabel];
    
    // 点击按钮
    UIButton *annotation_Btn = [UIButton buttonWithType:(UIButtonTypeSystem)];
//    annotation_Btn.backgroundColor = [UIColor orangeColor];
    [annotation_Btn addTarget:self action:@selector(annotation_BtnClickAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:annotation_Btn];
    self.annotation_Btn = annotation_Btn;
    
}


- (void)setModel:(MAPointAnnotation *)model{
    
    _model = model;
    
    self.detailLabel.text = [NSString stringWithFormat:@"%@ %@",model.title,model.subtitle];
        
    float detailWidth = 150.0;
    
    CGSize detailSize= [self.detailLabel.text boundingRectWithSize:CGSizeMake(detailWidth, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kDetailFontSize]}
                                                       context:nil].size;
    
//    self.detailLabel.frame = CGRectMake(0, kSpacing, detailSize.width + 10, detailSize.height + 5);
    
    CGFloat detailY = detailSize.height + 5 + 10;
    CGFloat detail_W = detailSize.width + 20;
    CGFloat detail_H = detailSize.height + 5;
    
    self.detailLabel.frame = CGRectMake(0, detailY, detail_W, detail_H);
    
    self.icon_View.frame = CGRectMake((detail_W - 23) / 2, detailY - 26, 23, 26);
        
    float backgroundWidth = CGRectGetMaxX(self.detailLabel.frame);
    
    self.backgroundView.frame = CGRectMake(0, 0, backgroundWidth, self.detailLabel.frame.size.height + 10);
    
    self.annotation_Btn.frame = CGRectMake(0, 0, backgroundWidth, self.detailLabel.frame.size.height + 10);
    
    self.bounds = CGRectMake(0, 0, backgroundWidth, self.detailLabel.frame.size.height + 10);
    
    
}

- (void)annotation_BtnClickAction:(UIButton *)sender{
    
    NSLog(@"111111111111==%f",self.model.coordinate.latitude);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ProvinceButtonClickAction:annotation:)]) {
        
        [self.delegate ProvinceButtonClickAction:sender annotation:self.model];
    }
}

@end
