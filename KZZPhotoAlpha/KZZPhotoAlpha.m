//
//  PhotoAlpha.m
//  MyPhoto
//
//  Created by 陈又铜 on 2020/7/20.
//  Copyright © 2020 陈又铜. All rights reserved.
//

#import "KZZPhotoAlpha.h"

@interface KZZPhotoAlpha () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, nonnull) UIImageView * imageView;
@property(nonatomic, weak) UIWindow * window;

@end

@implementation KZZPhotoAlpha {

}

//单例
+ (instancetype)shared {
    static KZZPhotoAlpha *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KZZPhotoAlpha alloc] init];
    });
    return instance;
}

- (void)showTheView : (UIWindow *) window{
    _imageView = [[UIImageView alloc] init];
    _imageView.frame = window.bounds;
    _imageView.backgroundColor = [UIColor whiteColor];
    [_imageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _imageView.clipsToBounds = YES;

    _imageView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(panAction:)];
    [_imageView addGestureRecognizer:pan];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnHome:)];
    tap.numberOfTapsRequired = 3;
    [_imageView addGestureRecognizer:tap];
    [tap requireGestureRecognizerToFail:tap];
}

- (void)chooseImage:(UIWindow *) imageWindow{
    _window = imageWindow;
    [_imageView removeFromSuperview];//实现释放imageView，防止连续两次摇一摇时出现BUG
    [self showTheView:imageWindow];
    UIImagePickerController * pickerControll = [[UIImagePickerController alloc] init];
    pickerControll.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerControll.delegate = self;
    pickerControll.allowsEditing = YES;
    [imageWindow.rootViewController presentViewController:pickerControll animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:( NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _imageView.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
    [_window addSubview:_imageView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)panAction: (UIPanGestureRecognizer *) pan{
    CGPoint point;
    if(pan.state == UIGestureRecognizerStateBegan){
        point = [pan locationInView:_imageView];
    }
    if(pan.state == UIGestureRecognizerStateChanged){
        point = [pan translationInView:_imageView];
        CGFloat num = point.y / _imageView.frame.size.height;
        CGFloat alpha = _imageView.alpha - num;
        _imageView.alpha = (alpha>1) ? 1 : ((alpha<0.05) ? 0.05 : alpha);
    }
}

- (void)returnHome: (UITapGestureRecognizer *) tap{
    [_imageView removeFromSuperview];
}

@end
