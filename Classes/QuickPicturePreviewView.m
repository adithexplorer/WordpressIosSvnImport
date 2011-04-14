//
//  QuickPicturePreviewView.m
//  WordPress
//
//  Created by Jorge Bernal on 4/8/11.
//  Copyright 2011 WordPress. All rights reserved.
//

#import "QuickPicturePreviewView.h"
#define QPP_MARGIN 10.0f
#define QPP_FRAME_WIDTH 7.0f
#define QPP_SHADOW_SIZE 5.0f

@implementation QuickPicturePreviewView
@synthesize delegate;

- (void)dealloc {
    [paperClipImageView release]; paperClipImageView = nil;
    [imageView release]; imageView = nil;
    [super dealloc];
}

- (void)setupView {
    zoomed = NO;
    zooming = NO;
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)layoutSubviews {
    UIImage *image = imageView.image;
    if (image != nil) {
        if (!zooming && !zoomed) {
            CGSize imageSize = image.size;
            CGFloat imageRatio = imageSize.width / imageSize.height;
            CGSize frameSize = self.bounds.size;
            CGRect imageFrame;
            
            CGFloat width = (imageRatio > 1) ? frameSize.width - 2.0f * (QPP_MARGIN + QPP_FRAME_WIDTH) : (frameSize.height - 2.0f * (QPP_MARGIN + QPP_FRAME_WIDTH)) * imageRatio;
            CGFloat height = (imageRatio < 1) ? frameSize.height - 2.0f * (QPP_MARGIN + QPP_FRAME_WIDTH) : (frameSize.width - 2.0f * (QPP_MARGIN + QPP_FRAME_WIDTH)) / imageRatio;
            
            imageFrame = CGRectMake(
                                    frameSize.width - width - (QPP_MARGIN + QPP_FRAME_WIDTH),
                                    QPP_MARGIN + QPP_FRAME_WIDTH,
                                    width,
                                    height
                                    );
            
            imageView.frame = imageFrame;
            if (frameLayer == nil) {
                frameLayer = [CALayer layer];
                frameLayer.backgroundColor = [UIColor whiteColor].CGColor;
                frameLayer.zPosition = -5;
                frameLayer.shadowColor = [UIColor blackColor].CGColor;
                frameLayer.shadowOffset = CGSizeMake(0.0f, 0.75f);
                frameLayer.shadowOpacity = 0.5f;
                frameLayer.shadowRadius = 1.0f;
                [self.layer addSublayer:frameLayer];
            }
            imageFrame.size.width += 2 * QPP_FRAME_WIDTH;
            imageFrame.size.height += 2 * QPP_FRAME_WIDTH;
            imageFrame.origin.x -= QPP_FRAME_WIDTH;
            imageFrame.origin.y -= QPP_FRAME_WIDTH;
            frameLayer.frame = imageFrame;
            
            paperClipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paperclip"]];
            paperClipImageView.frame = CGRectMake(3.0f, -10.0f, 15.0f, 41.0f);
            [paperClipImageView setHidden:NO];
            [imageView addSubview:paperClipImageView];
        }
    }
    [super layoutSubviews];
}

- (UIImage *)image {
    return imageView.image;
}

- (void)setImage:(UIImage *)image {
    [imageView setImage:image];
    [self setNeedsLayout];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    zooming = NO;
    if (!zoomed) {
        frameLayer.opacity = 1.0f;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger numTaps = [touch tapCount];
    
    if (numTaps == 1) {
        zooming = YES;
        zoomed = ! zoomed;
        if (zoomed) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(pictureWillZoom)]) {
                [self.delegate pictureWillZoom];
            }
            frameLayer.opacity = 0.0f;
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(pictureWillRestore)]) {
                [self.delegate pictureWillRestore];
            }
        }
        [UIView beginAnimations:@"zoom" context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        if (zoomed) {
            normalFrame = self.frame;
            normalImageFrame = imageView.frame;
            self.frame = [self.superview bounds];
            self.backgroundColor = [UIColor blackColor];
            imageView.frame = self.frame;
            [paperClipImageView setHidden:YES];
        } else {
            self.frame = normalFrame;
            self.backgroundColor = [UIColor clearColor];
            imageView.frame = normalImageFrame;
            [paperClipImageView setHidden:NO];
        }
        [UIView commitAnimations];

        if (zoomed) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(pictureDidZoom)])
                [self.delegate pictureDidZoom];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(pictureDidRestore)])
                [self.delegate pictureDidRestore];
        }
    }
}

@end
