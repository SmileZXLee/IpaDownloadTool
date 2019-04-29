//
//  SYFavoriteButton.m
//  SYFavoriteButton
//
//  Created by Sunnyyoung on 15/8/27.
//  Copyright (c) 2015年 GeekBean Technology Co., Ltd. All rights reserved.
//

#import "SYFavoriteButton.h"

@interface SYFavoriteButton ()

@property (nonatomic, strong) CAShapeLayer        * imageShape;
@property (nonatomic, strong) CAShapeLayer        * circleShape;
@property (nonatomic, strong) CAShapeLayer        * circleMask;
@property (nonatomic, strong) NSMutableArray      * lines;
@property (nonatomic, strong) CAKeyframeAnimation * circleTransform;
@property (nonatomic, strong) CAKeyframeAnimation * circleMaskTransform;
@property (nonatomic, strong) CAKeyframeAnimation * lineStrokeStart;
@property (nonatomic, strong) CAKeyframeAnimation * lineStrokeEnd;
@property (nonatomic, strong) CAKeyframeAnimation * lineOpacity;
@property (nonatomic, strong) CAKeyframeAnimation * imageTransform;

@end

@implementation SYFavoriteButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
        [self addTargets];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self addTargets];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
        [self addTargets];
    }
    return self;
}

- (void)setup {
    self.circleTransform     = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    self.circleMaskTransform = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    self.lineStrokeStart     = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
    self.lineStrokeEnd       = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    self.lineOpacity         = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    self.imageTransform      = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
}

- (void)createLayersWithImage:(UIImage *)image {
    self.layer.sublayers = nil;
    
    CGRect imageFrame = CGRectMake(self.frame.size.width / 2 - self.frame.size.width / 4,
                                   self.frame.size.height / 2 - self.frame.size.height / 4,
                                   self.frame.size.width / 2,
                                   self.frame.size.height / 2);
    CGPoint imgCenterPoint = CGPointMake(CGRectGetMidX(imageFrame), CGRectGetMidY(imageFrame));
    CGRect lineFrame = CGRectMake(imageFrame.origin.x - imageFrame.size.width / 4,
                                  imageFrame.origin.y - imageFrame.size.height / 4 ,
                                  imageFrame.size.width * 1.5,
                                  imageFrame.size.height * 1.5);
    
    //===============
    // circle layer
    //===============
    self.circleShape = ({
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.bounds = imageFrame;
        shapeLayer.position = imgCenterPoint;
        shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:imageFrame].CGPath;
        shapeLayer.fillColor = self.circleColor.CGColor;
        shapeLayer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0);
        shapeLayer;
    });
    [self.layer addSublayer: self.circleShape];
    
    self.circleMask = ({
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.bounds = imageFrame;
        shapeLayer.position = imgCenterPoint;
        shapeLayer.fillRule = kCAFillRuleEvenOdd;
        self.circleShape.mask = shapeLayer;
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:imageFrame];
        [maskPath addArcWithCenter:imgCenterPoint radius: 0.1 startAngle: 0.0 endAngle: (M_PI * 2) clockwise:YES];
        shapeLayer.path = maskPath.CGPath;
        shapeLayer;
    });
    
    //===============
    // line layer
    //===============
    self.lines = [[NSMutableArray alloc] init];
    for (int i=0; i<5; i++) {
        CAShapeLayer *line = [CAShapeLayer layer];
        line.bounds = lineFrame;;
        line.position = imgCenterPoint;
        line.masksToBounds = true;
        line.actions = [NSDictionary dictionaryWithObjectsAndKeys:@"strokeStart", @"", @"strokeEnd", @"", nil];
        line.strokeColor = self.lineColor.CGColor;
        line.lineWidth = 1.25;
        line.miterLimit = 1.25;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, CGRectGetMidX(lineFrame), CGRectGetMidY(lineFrame));
        CGPathAddLineToPoint(path, nil, lineFrame.origin.x + lineFrame.size.width / 2, lineFrame.origin.y);
        line.path = path;
        line.lineCap = kCALineCapRound;
        line.lineJoin = kCALineJoinRound;
        line.strokeStart = 0.f;
        line.strokeEnd = 0.f;
        line.opacity = 0.f;
        line.transform = CATransform3DMakeRotation(M_PI / 5 * (i * 2 + 1), 0.0, 0.0, 1.0);
        [self.layer addSublayer: line];
        [self.lines addObject:line];
        CGPathRelease(path);
    }
    
    //===============
    // image layer
    //===============
    self.imageShape = ({
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.bounds = imageFrame;
        shapeLayer.position = imgCenterPoint;
        shapeLayer.path = [[UIBezierPath bezierPathWithRect:imageFrame] CGPath];
        shapeLayer.fillColor = self.defaultColor.CGColor;
        shapeLayer.actions = [NSDictionary dictionaryWithObjectsAndKeys:@"fillColor", @"", nil];
        shapeLayer;
    });
    [self.layer addSublayer: self.imageShape];
    
    self.imageShape.mask = [CALayer new];
    self.imageShape.mask.contents = (id)[image CGImage];
    self.imageShape.mask.bounds = imageFrame;
    self.imageShape.mask.position = imgCenterPoint;
    
    //==============================
    // circle transform animation
    //==============================
    self.circleTransform.values = @[
                                    [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.0,  0.0,  1.0)],    //  0/10
                                    [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.5,  0.5,  1.0)],    //  1/10
                                    [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.0,  1.0,  1.0)],    //  2/10
                                    [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.2,  1.2,  1.0)],    //  3/10
                                    [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.3,  1.3,  1.0)],    //  4/10
                                    [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.37, 1.37, 1.0)],    //  5/10
                                    [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.4,  1.4,  1.0)],    //  6/10
                                    [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.4,  1.4,  1.0)],    // 10/10
                                    ];
    self.circleTransform.keyTimes = @[
                                      [NSNumber numberWithFloat:0.0],    //  0/10
                                      [NSNumber numberWithFloat:0.1],    //  1/10
                                      [NSNumber numberWithFloat:0.2],    //  2/10
                                      [NSNumber numberWithFloat:0.3],    //  3/10
                                      [NSNumber numberWithFloat:0.4],    //  4/10
                                      [NSNumber numberWithFloat:0.5],    //  5/10
                                      [NSNumber numberWithFloat:0.6],    //  6/10
                                      [NSNumber numberWithFloat:1.0]     // 10/10
                                      ];
    
    self.circleMaskTransform.values = @[
                                        [NSValue valueWithCATransform3D: CATransform3DIdentity],    //  0/10
                                        [NSValue valueWithCATransform3D: CATransform3DIdentity],    //  2/10
                                        [NSValue valueWithCATransform3D: CATransform3DMakeScale(imageFrame.size.width * 1.25,  imageFrame.size.height * 1.25,  1.0)],    //  3/10
                                        [NSValue valueWithCATransform3D: CATransform3DMakeScale(imageFrame.size.width * 2.688, imageFrame.size.height * 2.688, 1.0)],    //  4/10
                                        [NSValue valueWithCATransform3D: CATransform3DMakeScale(imageFrame.size.width * 3.923, imageFrame.size.height * 3.923, 1.0)],    //  5/10
                                        [NSValue valueWithCATransform3D: CATransform3DMakeScale(imageFrame.size.width * 4.375, imageFrame.size.height * 4.375, 1.0)],    //  6/10
                                        [NSValue valueWithCATransform3D: CATransform3DMakeScale(imageFrame.size.width * 4.731, imageFrame.size.height * 4.731, 1.0)],    //  7/10
                                        [NSValue valueWithCATransform3D: CATransform3DMakeScale(imageFrame.size.width * 5.0,   imageFrame.size.height * 5.0,   1.0)],    // 9/10
                                        [NSValue valueWithCATransform3D: CATransform3DMakeScale(imageFrame.size.width * 5.0,   imageFrame.size.height * 5.0,   1.0)],    // 10/10
                                        ];
    self.circleMaskTransform.keyTimes = @[
                                          [NSNumber numberWithFloat:0.0],    //  0/10
                                          [NSNumber numberWithFloat:0.2],    //  2/10
                                          [NSNumber numberWithFloat:0.3],    //  3/10
                                          [NSNumber numberWithFloat:0.4],    //  4/10
                                          [NSNumber numberWithFloat:0.5],    //  5/10
                                          [NSNumber numberWithFloat:0.6],    //  6/10
                                          [NSNumber numberWithFloat:0.7],    //  7/10
                                          [NSNumber numberWithFloat:0.9],    //  9/10
                                          [NSNumber numberWithFloat:1.0]     // 10/10
                                          ];
    
    //==============================
    // line stroke animation
    //==============================
    self.lineStrokeStart.values = @[
                                    [NSNumber numberWithFloat:0.0],    //  0/18
                                    [NSNumber numberWithFloat:0.0],    //  1/18
                                    [NSNumber numberWithFloat:0.18],   //  2/18
                                    [NSNumber numberWithFloat:0.2],    //  3/18
                                    [NSNumber numberWithFloat:0.26],   //  4/18
                                    [NSNumber numberWithFloat:0.32],   //  5/18
                                    [NSNumber numberWithFloat:0.4],    //  6/18
                                    [NSNumber numberWithFloat:0.6],    //  7/18
                                    [NSNumber numberWithFloat:0.71],   //  8/18
                                    [NSNumber numberWithFloat:0.89],   // 17/18
                                    [NSNumber numberWithFloat:0.92]    // 18/18
                                    ];
    self.lineStrokeStart.keyTimes = @[
                                      [NSNumber numberWithFloat:0.0],    //  0/18
                                      [NSNumber numberWithFloat:0.056],  //  1/18
                                      [NSNumber numberWithFloat:0.111],  //  2/18
                                      [NSNumber numberWithFloat:0.167],  //  3/18
                                      [NSNumber numberWithFloat:0.222],  //  4/18
                                      [NSNumber numberWithFloat:0.278],  //  5/18
                                      [NSNumber numberWithFloat:0.333],  //  6/18
                                      [NSNumber numberWithFloat:0.389],  //  7/18
                                      [NSNumber numberWithFloat:0.444],  //  8/18
                                      [NSNumber numberWithFloat:0.944],  // 17/18
                                      [NSNumber numberWithFloat:1.0],    // 18/18
                                      ];
    
    self.lineStrokeEnd.values = @[
                                  [NSNumber numberWithFloat:0.0],    //  0/18
                                  [NSNumber numberWithFloat:0.0],    //  1/18
                                  [NSNumber numberWithFloat:0.32],   //  2/18
                                  [NSNumber numberWithFloat:0.48],   //  3/18
                                  [NSNumber numberWithFloat:0.64],   //  4/18
                                  [NSNumber numberWithFloat:0.68],   //  5/18
                                  [NSNumber numberWithFloat:0.92],   // 17/18
                                  [NSNumber numberWithFloat:0.92]    // 18/18
                                  ];
    self.lineStrokeEnd.keyTimes = @[
                                    [NSNumber numberWithFloat:0.0],    //  0/18
                                    [NSNumber numberWithFloat:0.056],  //  1/18
                                    [NSNumber numberWithFloat:0.111],  //  2/18
                                    [NSNumber numberWithFloat:0.167],  //  3/18
                                    [NSNumber numberWithFloat:0.222],  //  4/18
                                    [NSNumber numberWithFloat:0.278],  //  5/18
                                    [NSNumber numberWithFloat:0.944],  // 17/18
                                    [NSNumber numberWithFloat:1.0],    // 18/18
                                    ];
    
    self.lineOpacity.values = @[
                                [NSNumber numberWithFloat:1.0],    //  0/30
                                [NSNumber numberWithFloat:1.0],    // 12/30
                                [NSNumber numberWithFloat:0.0]     // 17/30
                                ];
    self.lineOpacity.keyTimes = @[
                                  [NSNumber numberWithFloat:0.0],    //  0/30
                                  [NSNumber numberWithFloat:0.40],    // 12/30
                                  [NSNumber numberWithFloat:0.567]   // 17/30
                                  ];
    
    //==============================
    // image transform animation
    //==============================
    self.imageTransform.values = @[
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.0,   0.0,   1.0)],  //  0/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.0,   0.0,   1.0)],  //  3/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.2,   1.2,   1.0)],  //  9/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.25,  1.25,  1.0)],  // 10/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.2,   1.2,   1.0)],  // 11/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.9,   0.9,   1.0)],  // 14/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.875, 0.875, 1.0)],  // 15/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.875, 0.875, 1.0)],  // 16/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.9,   0.9,   1.0)],  // 17/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.013, 1.013, 1.0)],  // 20/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.025, 1.025, 1.0)],  // 21/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(1.013, 1.013, 1.0)],  // 22/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.96,  0.96,  1.0)],  // 25/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.95,  0.95,  1.0)],  // 26/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.96,  0.96,  1.0)],  // 27/30
                                   [NSValue valueWithCATransform3D: CATransform3DMakeScale(0.99,  0.99,  1.0)],  // 29/30
                                   [NSValue valueWithCATransform3D: CATransform3DIdentity]                       // 30/30
                                   ];
    self.imageTransform.keyTimes = @[
                                     [NSNumber numberWithFloat:0.0],    //  0/30
                                     [NSNumber numberWithFloat:0.1],    //  3/30
                                     [NSNumber numberWithFloat:0.3],    //  9/30
                                     [NSNumber numberWithFloat:0.333],  // 10/30
                                     [NSNumber numberWithFloat:0.367],  // 11/30
                                     [NSNumber numberWithFloat:0.467],  // 14/30
                                     [NSNumber numberWithFloat:0.5],    // 15/30
                                     [NSNumber numberWithFloat:0.533],  // 16/30
                                     [NSNumber numberWithFloat:0.567],  // 17/30
                                     [NSNumber numberWithFloat:0.667],  // 20/30
                                     [NSNumber numberWithFloat:0.7],    // 21/30
                                     [NSNumber numberWithFloat:0.733],  // 22/30
                                     [NSNumber numberWithFloat:0.833],  // 25/30
                                     [NSNumber numberWithFloat:0.867],  // 26/30
                                     [NSNumber numberWithFloat:0.9],    // 27/30
                                     [NSNumber numberWithFloat:0.967],  // 29/30
                                     [NSNumber numberWithFloat:1.0]     // 30/30
                                     ];
}


- (void)addTargets {
    //===============
    // add target
    //===============
    [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [self addTarget:self action:@selector(touchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchCancel];
}

- (void)touchDown:(id)sender {
    self.layer.opacity = 0.4;
}

- (void)touchUpInside:(id)sender {
    self.layer.opacity = 1.0;
}

- (void)touchDragExit:(id)sender {
    self.layer.opacity = 1.0;
}

- (void)touchDragEnter:(id)sender {
    self.layer.opacity = 0.4;
}

- (void)touchCancel:(id)sender {
    self.layer.opacity = 1.0;
}

- (void)select {
    self.imageShape.fillColor = self.favoredColor.CGColor;
    
    self.userInteractionEnabled = NO;
    [CATransaction setCompletionBlock:^{
        self.userInteractionEnabled = YES;
    }];
    
    [CATransaction begin];
    
    [self.circleShape addAnimation:self.circleTransform forKey:@"transform"];
    [self.circleMask addAnimation:self.circleMaskTransform forKey:@"transform"];
    [self.imageShape addAnimation:self.imageTransform forKey:@"transform"];
    
    for (int i=0; i<5; i++) {
        [self.lines[i] addAnimation:self.lineStrokeStart forKey:@"strokeStart"];
        [self.lines[i] addAnimation:self.lineStrokeEnd forKey:@"strokeEnd"];
        [self.lines[i] addAnimation:self.lineOpacity forKey:@"opacity"];
    }
    
    [CATransaction commit];
}

- (void)deselect {
    self.imageShape.fillColor = self.defaultColor.CGColor;
    
    // remove all animations
    [self.circleShape removeAllAnimations];
    [self.circleMask removeAllAnimations];
    [self.imageShape removeAllAnimations];
    [self.lines[0] removeAllAnimations];
    [self.lines[1] removeAllAnimations];
    [self.lines[2] removeAllAnimations];
    [self.lines[3] removeAllAnimations];
    [self.lines[4] removeAllAnimations];
}

#pragma mark - Getter && Setter
- (void)setImage:(UIImage *)image {
    _image = image;
    [self createLayersWithImage:_image];
}

- (void)setFavoredColor:(UIColor *)favoredColor {
    _favoredColor = favoredColor;
    if (self.selected) {
        self.imageShape.fillColor = favoredColor.CGColor;
    }
}

- (void)setDefaultColor:(UIColor *)defaultColor {
    _defaultColor = defaultColor;
    if (!self.selected) {
        self.imageShape.fillColor = defaultColor.CGColor;
    }
}

- (void)setCircleColor:(UIColor *)circleColor {
    _circleColor = circleColor;
    self.circleShape.fillColor = circleColor.CGColor;
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    for (CAShapeLayer *line in self.lines) {
        line.strokeColor = lineColor.CGColor;
    }
}

- (void)setDuration:(CGFloat)duration {
    _duration = duration;
    self.circleTransform.duration     = 0.333 * _duration;
    self.circleMaskTransform.duration = 0.333 * _duration;
    self.lineStrokeStart.duration     = 0.6 * _duration;
    self.lineStrokeEnd.duration       = 0.6 * _duration;
    self.lineOpacity.duration         = 1.0 * _duration;
    self.imageTransform.duration      = 1.0 * _duration;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.imageShape.fillColor = self.favoredColor.CGColor;
        [self select];
    } else {
        [self deselect];
    }
}

@end
