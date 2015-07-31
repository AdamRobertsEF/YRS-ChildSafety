//
//  CreateCaseViewController.m
//  CyberBullyingReporter
//

#import "CreateCaseViewController.h"

@interface CreateCaseViewController()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *howDidThisMakeYouFeel;
@property (strong, nonatomic) IBOutlet UIImage *image;
@property (strong, nonatomic) UISegmentedControl *segment;
@property (strong, nonatomic) NSArray *segmentItems;
@end

PFLogInViewController *logInController;

@implementation CreateCaseViewController

-(void)viewDidAppear:(BOOL)animated{
    [self configureToolbar];
    NSLog(@"frame:%@",NSStringFromCGRect(_segment.frame));
    [super viewDidAppear:animated];
}

- (IBAction)pickScreenshots:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker
                       animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Code here to work with media
    [self dismissViewControllerAnimated:NO completion:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *mediaType = info [UIImagePickerControllerMediaType];
            
            if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
            {
                // Media is an image
                _image = info [UIImagePickerControllerOriginalImage];
                
                _imageView.image = _image;
                _imageView.clipsToBounds = TRUE;
                
                //NSURL *url = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
            };
        });
    }];

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitCase:(id)sender {
  
    PFObject *caseObject = [PFObject objectWithClassName:@"BullyingReports"];
    caseObject[@"ReporterName"] = @"Adam Roberts";
    caseObject[@"HowDidThisMakeYouFeel"] = _howDidThisMakeYouFeel.text;
    //caseObject[@"SocialMediaURL"] = _socialMediaURL.text;
    
    NSLog(@"current Segment:%@",[_segmentItems objectAtIndex:_segment.selectedSegmentIndex]);
    
    caseObject.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    
    if (_image){
        NSData *imageData = UIImageJPEGRepresentation(_image, 1.0f);
        PFFile *imageFile = [PFFile fileWithName:@"screenshot.jpg" data:imageData];
        caseObject[@"screenshot"] = imageFile;
    }

    [caseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"saved!");
            // The object has been saved.
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                    message:@"Case logged with police!"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                [self cancelStatus:nil];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"failed to save with error:%@",error.description);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                                    message:@"Please try again!"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                // There was a problem, check error.description
            });
        }
    }];

}
- (IBAction)cancelStatus:(id)sender {
    _howDidThisMakeYouFeel.text = @"";
    _image = nil;
    _imageView.image = nil;

}

-(void)configureToolbar{
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(pickScreenshots:)];
    
//    UIBarButtonItem *peopleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(pickPeople:)];
    
    _segmentItems = @[@"Upset",@"Scared",@"Threatened"];
    _segment = [[UISegmentedControl alloc] initWithItems:_segmentItems];
    
    UIBarButtonItem *segmentBarButton = [[UIBarButtonItem alloc] initWithCustomView:_segment];
    
    [toolbar setItems:@[cameraButton,segmentBarButton]];
    [toolbar sizeToFit];
    
    [_howDidThisMakeYouFeel setInputAccessoryView:toolbar];
    [_howDidThisMakeYouFeel becomeFirstResponder];
}

- (BOOL)prefersStatusBarHidden{
    return TRUE;
}

@end
