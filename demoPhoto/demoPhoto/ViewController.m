//
//  ViewController.m
//  demoPhoto
//
//  Created by TechmasterVietNam on 5/31/13.
//  Copyright (c) 2013 TechmasterVietNam. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import "GPUImagePixellatePositionFilter.h"
#import <QuartzCore/QuartzCore.h>
#import "GPUImageFilter.h"


@interface ViewController () {
    UIImage *originalImage;
    GPUImagePicture* stillImageSource;
    UIImage* newImage;
    CGRect rectToZoomTo;
    float width;
    float height;
    int num ;
    CGPoint touchPoint;
}
@property(strong,nonatomic) UIImageView* selectedImageView;
@property (readwrite, nonatomic) UISlider* sliderRadius;
@property (readwrite, nonatomic) UISlider* sliderWidth;
@property (readwrite, nonatomic) UISlider* sliderHeight;


@property (readwrite, nonatomic) CGRect RectSize;

@property(readwrite,nonatomic) GPUImageCropFilter *cropFilter;
@property(readwrite,nonatomic) GPUImagePixellateFilter* pixel;

@property(readwrite,nonatomic) GPUImageView *subView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(readwrite,nonatomic) UIImageView* imageView;
@property(readwrite,nonatomic) UIView* rotateView;

@end
@implementation ViewController
@synthesize cropFilter,pixel,scrollView,imageView,sliderRadius,RectSize,rotateView,subView,rectangle,circle,toolBar,sliderHeight,sliderWidth;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 4
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    
    // 5
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;
    
    // 6
    [self centerScrollViewContents];
}


- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    touchPoint=[gesture locationInView:self.scrollView];
    
    NSLog(@"X location: %f", touchPoint.x);
    NSLog(@"Y Location: %f", touchPoint.y);
    NSLog(@"%i",num);
    
    rotateView.center = touchPoint;
    
    [stillImageSource addTarget:cropFilter];
    
    [stillImageSource processImage];
    
    pixel.fractionalWidthOfAPixel = 0.015;

    if (scrollView.contentSize.height<self.view.frame.size.height) {
        [subView setFrame:CGRectMake(0,0, scrollView.contentSize.width, scrollView.contentSize.height)];
        subView.center = CGPointMake(scrollView.contentSize.width/2,scrollView.contentSize.height/2+(scrollView.frame.size.height-scrollView.contentSize.height)/2);
        
        [cropFilter setCropRegion:CGRectMake(0,0,1,1)];
        
        rotateView.center = touchPoint;
        
        [imageView setFrame:subView.frame];
                
    }
    if (scrollView.contentSize.width<self.view.frame.size.width){
        [subView setFrame:CGRectMake(0,0, scrollView.contentSize.width, scrollView.contentSize.height)];
        subView.center = CGPointMake(scrollView.contentSize.width/2+(scrollView.frame.size.width-scrollView.contentSize.width)/2,scrollView.contentSize.height/2);
        
        [cropFilter setCropRegion:CGRectMake(0,0,1,1)];
        
        rotateView.center = touchPoint;
        
        [imageView setFrame:subView.frame];
        NSLog(@"123");
                
    }
    if (scrollView.contentSize.width>=self.view.frame.size.width && scrollView.contentSize.height>=self.view.frame.size.height){
        [subView setFrame:CGRectMake(0,0, scrollView.contentSize.width, scrollView.contentSize.height)];
        subView.center = CGPointMake(scrollView.contentSize.width/2,scrollView.contentSize.height/2);
        [cropFilter setCropRegion:CGRectMake(0,0,1,1)];
        
        rotateView.center = touchPoint;
        
        [imageView setFrame:subView.frame];
    }
    if (scrollView.contentSize.width<self.view.frame.size.width && scrollView.contentSize.height<self.view.frame.size.height){
        [subView setFrame:CGRectMake(0,0, scrollView.contentSize.width, scrollView.contentSize.height)];
        subView.center = CGPointMake(scrollView.contentSize.width/2+(scrollView.frame.size.width-scrollView.contentSize.width)/2,scrollView.contentSize.height/2+(scrollView.frame.size.height-scrollView.contentSize.height)/2);
        
        [cropFilter setCropRegion:CGRectMake(0,0,1,1)];
        
        rotateView.center = touchPoint;
        
        [imageView setFrame:subView.frame];
        NSLog(@"5678");
    }
    
    imageView.center = CGPointMake(rotateView.frame.size.width/2+(subView.center.x-rotateView.center.x), rotateView.frame.size.height/2+(subView.center.y-rotateView.center.y));


    UIImage *cropImage = [cropFilter imageFromCurrentlyProcessedOutput];
    
    GPUImagePicture* cropPicture = [[GPUImagePicture alloc] initWithImage:cropImage];
    
    [cropPicture addTarget:pixel];
    
    [cropPicture processImage];
    
    UIImage *pixelImage = [pixel imageFromCurrentlyProcessedOutput];
    
    UIGraphicsBeginImageContext(self.scrollView.contentSize);
    
    imageView.image = pixelImage;
    
    [self.scrollView addSubview:rotateView];

    UIGraphicsEndImageContext();
    
    self.selectedImageView.image = originalImage;
    
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return self.selectedImageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *output = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain
                                                              target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = output;
    
    UIBarButtonItem *input = [[UIBarButtonItem alloc] initWithTitle:@"Album" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(input)];
    self.navigationItem.leftBarButtonItem = input;
    
    UIButton *camera = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    [[camera layer] setCornerRadius:7.0f];
    
    [camera setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [camera addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = camera;
        
    self.subView = [[GPUImageView alloc] initWithFrame:scrollView.frame];
    
    rotateView = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    rotateView.clipsToBounds =YES;
    [rotateView.layer setMasksToBounds:YES];
    [rotateView.layer setBorderWidth:0.6];
    
    imageView =[[UIImageView alloc] initWithFrame:self.subView.frame];

    [rotateView addSubview:imageView];
    
    pixel = [[GPUImagePixellateFilter alloc]init];
    
    cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(self.subView.frame.origin.x/self.view.frame.size.width, self.subView.frame.origin.y/self.view.frame.size.height,self.subView.frame.size.width/self.view.frame.size.width, self.subView.frame.size.height/self.view.frame.size.height)];
    
    sliderRadius = [[UISlider alloc] initWithFrame:CGRectMake(20, 330, 280, 30)];
    [sliderRadius addTarget:self action:@selector(changeRadius) forControlEvents:UIControlEventValueChanged];
    
    sliderWidth = [[UISlider alloc] initWithFrame:CGRectMake(20, 330, 280, 30)];
    [sliderWidth addTarget:self action:@selector(changeWidth) forControlEvents:UIControlEventValueChanged];
    
    sliderHeight = [[UISlider alloc] initWithFrame:CGRectMake(20, 300, 280, 30)];
    [sliderHeight addTarget:self action:@selector(changeHeight) forControlEvents:UIControlEventValueChanged];
    
    originalImage = [[UIImage alloc] init];
}
- (IBAction)Rectange:(id)sender {
    num = 3;
    
    [self.view addSubview:sliderHeight];
    [self.view addSubview:sliderWidth];
    
    [subView setFrame:CGRectMake(subView.frame.origin.x, subView.frame.origin.y, scrollView.contentSize.width, scrollView.contentSize.height)];
        
    [imageView setFrame:subView.frame];
    
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sliderWidth.value*scrollView.zoomScale, sliderHeight.value*scrollView.zoomScale)];
    
    rotateView.center = subView.center;
    
    imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
        
    [rotateView.layer setCornerRadius:0];
    
    [sliderRadius removeFromSuperview];
    
    rotateView.layer.mask = nil;

}

- (IBAction)ellipse:(id)sender {
    num = 2;
    
    [self.view addSubview:sliderHeight];
    [self.view addSubview:sliderWidth];
    
    [sliderRadius removeFromSuperview];

    [subView setFrame:CGRectMake(subView.frame.origin.x, subView.frame.origin.y, scrollView.contentSize.width , scrollView.contentSize.height)];
    
    [imageView setFrame:subView.frame];
    
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sliderWidth.value*scrollView.zoomScale, sliderHeight.value*scrollView.zoomScale)];
    
    rotateView.center = subView.center;
    
    imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    CAShapeLayer *shapeMask = [CAShapeLayer layer];
    UIBezierPath *someClosedUIBezierPath = [UIBezierPath bezierPathWithOvalInRect:rotateView.bounds];
    shapeMask.path = someClosedUIBezierPath.CGPath;
    
    rotateView.layer.mask = shapeMask;

}

- (IBAction)Circle:(id)sender {
    num = 1;
    [sliderHeight removeFromSuperview];
    [sliderWidth removeFromSuperview];
    
    [subView setFrame:CGRectMake(subView.frame.origin.x, subView.frame.origin.y, scrollView.contentSize.width , scrollView.contentSize.height)];
    
    [imageView setFrame:subView.frame];

    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sliderRadius.value*scrollView.zoomScale , sliderRadius.value*scrollView.zoomScale)];
    [rotateView.layer setCornerRadius:rotateView.frame.size.height/2];
    
    rotateView.center = subView.center;
    
    imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    [self.view addSubview:sliderRadius];
}

-(void)changeWidth{    
    if (num==2) {
        
        [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sliderWidth.value*scrollView.zoomScale, rotateView.frame.size.height)];
        
        CAShapeLayer *shapeMask = [CAShapeLayer layer];
        UIBezierPath *someClosedUIBezierPath = [UIBezierPath bezierPathWithOvalInRect:rotateView.bounds];
        shapeMask.path = someClosedUIBezierPath.CGPath;
        
        rotateView.layer.mask = shapeMask;
        
    } else if (num==3){
        [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, sliderWidth.value*scrollView.zoomScale, rotateView.frame.size.height)];
    }

    rotateView.center = touchPoint;
    imageView.center = CGPointMake(rotateView.frame.size.width/2+(subView.center.x-rotateView.center.x), rotateView.frame.size.height/2+(subView.center.y-rotateView.center.y));

}
-(void)changeHeight{
    if (num==2) {
        [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, rotateView.frame.size.width, sliderHeight.value*scrollView.zoomScale)];
        
        CAShapeLayer *shapeMask = [CAShapeLayer layer];
        UIBezierPath *someClosedUIBezierPath = [UIBezierPath bezierPathWithOvalInRect:rotateView.bounds];
        shapeMask.path = someClosedUIBezierPath.CGPath;
        
        rotateView.layer.mask = shapeMask;
        
    } else if (num==3){
        [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y, rotateView.frame.size.width, sliderHeight.value*scrollView.zoomScale)];
    }
    
    rotateView.center = touchPoint;
    imageView.center = CGPointMake(rotateView.frame.size.width/2+(subView.center.x-rotateView.center.x), rotateView.frame.size.height/2+(subView.center.y-rotateView.center.y));

}
-(void)changeRadius{
    [rotateView setFrame:CGRectMake(rotateView.frame.origin.x, rotateView.frame.origin.y,sliderRadius.value*scrollView.zoomScale,sliderRadius.value*scrollView.zoomScale)];
    
    rotateView.center = touchPoint;
    imageView.center = CGPointMake(rotateView.frame.size.width/2+(subView.center.x-rotateView.center.x), rotateView.frame.size.height/2+(subView.center.y-rotateView.center.y));
    
    [rotateView.layer setCornerRadius:rotateView.frame.size.width/2];
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *alertTitle;
    NSString *alertMessage;
    if(!error)
    {
        alertTitle   = @"Image Saved";
        alertMessage = @"Image saved to photo album successfully.";
    }
    else
    {
        alertTitle   = @"Error";
        alertMessage = @"Unable to save to photo album.";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)input{
    
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.selectedImageView removeFromSuperview];
    
    originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    stillImageSource = [[GPUImagePicture alloc] initWithImage:originalImage];
    
    self.selectedImageView = [[UIImageView alloc] initWithImage:originalImage];
    
    self.selectedImageView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, originalImage.size.width, originalImage.size.height);
    
    [scrollView addSubview:self.selectedImageView];
    
    scrollView.contentSize = originalImage.size;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    sliderRadius.minimumValue = 10;
    sliderWidth.minimumValue = 10;
    sliderHeight.minimumValue = 10;
    
    if (originalImage.size.width>=originalImage.size.height) {
        sliderHeight.maximumValue = originalImage.size.width;
        sliderRadius.maximumValue = originalImage.size.width;
        sliderWidth.maximumValue = originalImage.size.width;
        
        sliderWidth.value = originalImage.size.width/4;
        sliderRadius.value = originalImage.size.width/4;
        sliderHeight.value = originalImage.size.width/4;

    } else if (originalImage.size.height<originalImage.size.height){
        sliderHeight.maximumValue = originalImage.size.height;
        sliderRadius.maximumValue = originalImage.size.height;
        sliderWidth.maximumValue = originalImage.size.height;
        
        sliderWidth.value = originalImage.size.height/4;
        sliderRadius.value = originalImage.size.height/4;
        sliderHeight.value = originalImage.size.height/4;

    }
    
    [self centerScrollViewContents];
    
    [self.view addSubview:self.scrollView];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.selectedImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.selectedImageView.frame = contentsFrame;
}
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // 1
    CGPoint pointInView = [recognizer locationInView:self.scrollView];
    
    // 2
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 1.0f);
    CGFloat y = pointInView.y - (h / 1.0f);
    
    rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
    [self centerScrollViewContents];
    
}
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
    [self centerScrollViewContents];

}
-(void)save{
    
    if (scrollView.contentSize.height<self.view.frame.size.height) {
        [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,(self.subView.frame.origin.y-(self.scrollView.frame.size.height-scrollView.contentSize.height)/2)/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
    }
    if (scrollView.contentSize.width<self.view.frame.size.width){
        [cropFilter setCropRegion:CGRectMake((self.subView.frame.origin.x-(self.scrollView.frame.size.width-scrollView.contentSize.width)/2)/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
    }
    if (scrollView.contentSize.width>=self.view.frame.size.width && scrollView.contentSize.height>=self.view.frame.size.height){
        [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
    }
    
    [stillImageSource addTarget:cropFilter];
    
    [stillImageSource processImage];
    
    UIImage *cropImage = [cropFilter imageFromCurrentlyProcessedOutput];
    
    GPUImagePicture* cropPicture = [[GPUImagePicture alloc] initWithImage:cropImage];
    
    [cropPicture addTarget:pixel];
    
    [cropPicture processImage];
    
    UIImage *pixelImage = [pixel imageFromCurrentlyProcessedOutput];
    
    float imageScale = sqrtf(powf(self.selectedImageView.transform.a, 2.f) + powf(self.selectedImageView.transform.c, 2.f));
    CGFloat widthScale = self.selectedImageView.bounds.size.width / self.selectedImageView.image.size.width;
    CGFloat heightScale = self.selectedImageView.bounds.size.height / self.selectedImageView.image.size.height;
    float contentScale = MIN(widthScale, heightScale);
    float effectiveScale = imageScale * contentScale;
    
    CGSize captureSize = CGSizeMake(self.selectedImageView.bounds.size.width / effectiveScale, self.selectedImageView.bounds.size.height / effectiveScale);

    UIGraphicsBeginImageContextWithOptions(captureSize, YES, 0.0);
        
   
    if (scrollView.contentSize.height<self.view.frame.size.height) {
        [rotateView setFrame:CGRectMake(rotateView.frame.origin.x / effectiveScale , (rotateView.frame.origin.y-(self.scrollView.frame.size.height-scrollView.contentSize.height)/2)/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale)];
    }
    
    if (scrollView.contentSize.width<self.view.frame.size.width){
        [rotateView setFrame:CGRectMake((rotateView.frame.origin.x-(self.scrollView.frame.size.width-scrollView.contentSize.width)/2)/ effectiveScale , rotateView.frame.origin.y/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale)];
    }
    
    if (scrollView.contentSize.width<self.view.frame.size.width && scrollView.contentSize.height<self.view.frame.size.height){
        [rotateView setFrame:CGRectMake((rotateView.frame.origin.x-(self.scrollView.frame.size.width-scrollView.contentSize.width)/2)/ effectiveScale , rotateView.frame.origin.y/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale)];
    }
    
    if(scrollView.contentSize.height>=self.view.frame.size.height && scrollView.contentSize.width>=self.view.frame.size.width){
        [rotateView setFrame:CGRectMake(rotateView.frame.origin.x/ effectiveScale, rotateView.frame.origin.y/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale, sqrtf(sliderRadius.value*scrollView.zoomScale*sliderRadius.value*scrollView.zoomScale/2)/ effectiveScale)];
    }
    
    [rotateView.layer setCornerRadius:rotateView.frame.size.width/2];

    [imageView setFrame:CGRectMake(imageView.frame.origin.x/ effectiveScale, imageView.frame.origin.y/ effectiveScale, imageView.frame.size.width/ effectiveScale, imageView.frame.size.height/ effectiveScale)];
    
    imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
    
    imageView.image = pixelImage;
    
    [self.selectedImageView addSubview:rotateView];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1/effectiveScale, 1/effectiveScale);
    
    [self.selectedImageView.layer renderInContext:context];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
    
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
@end