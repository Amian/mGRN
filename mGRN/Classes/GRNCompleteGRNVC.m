//
//  GRNCompleteGRNVC.m
//  mGRN
//
//  Created by Anum on 02/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNCompleteGRNVC.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "M1XmGRNService.h"
#import "GRNM1XHeader.h"
#import "GRNItem+Management.h"
#import "PurchaseOrder.h"
#import "CoreDataManager.h"
#import "PhotoPreviewVC.h"
#import "UIImage+fixOrientation.h"
#import "GRNLineItemVC.h"
#import <QuartzCore/QuartzCore.h>
#import "LoadingView.h"
#import "GRNOrderDetailsVC.h"
#import "SDN+Management.h"

#define SignTagSave 0
#define SignTagSignAgain 1

#define SignAgainButtonTag 123
#define SignSaveButtonTag 345


@interface GRNCompleteGRNVC()<UIImagePickerControllerDelegate, M1XmGRNDelegate,DrawViewDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate, UITextViewDelegate>
@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, strong) UIImage *image3;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIPopoverController *popVC;
@property (nonatomic, strong) UIImageView *fakeSignature;
@property (nonatomic, strong) UIView *loadingView;
@property BOOL grnDisplayed;
@end

@implementation GRNCompleteGRNVC
@synthesize grn = _grn, image1, image2, image3, popVC = _popVC, fakeSignature, loadingView, grnDisplayed;

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self checkOrientation];
    [self refreshImageView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.grnDisplayed)
        [self displayGRN];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkOrientation];
}

- (void)viewDidUnload {
    [self setComments:nil];
    [self setSignatureView:nil];
    [self setPhotoView:nil];
    [self setPhotoLabel:nil];
    [self setTakePhotoButton:nil];
    [self setDateButton:nil];
    [self setSignButton:nil];
    [self setPhotoAndSignContainer:nil];
    [self setDateAndNoteContainer:nil];
    [super viewDidUnload];
}

-(void)displayGRN
{
    if (self.grn.deliveryDate)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd/MM/yyyy";
        NSString *date = [formatter stringFromDate:self.grn.deliveryDate];
        [self.dateButton setTitle:date forState:UIControlStateNormal];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.image1 = [UIImage imageWithData:[defaults objectForKey:KeyImage1]];
    self.image2 = [UIImage imageWithData:[defaults objectForKey:KeyImage2]];
    self.image3 = [UIImage imageWithData:[defaults objectForKey:KeyImage3]];
    [self refreshImageView];
    UIImage *fakeImage = [UIImage imageWithData:[defaults objectForKey:KeySignature]];
    if (fakeImage)
    {
        self.fakeSignature = [[UIImageView alloc] initWithFrame:self.signatureView.bounds];
        self.fakeSignature.image = fakeImage;
        [self.signatureView addSubview:self.fakeSignature];
        self.signatureView.userInteractionEnabled = NO;
        self.signatureView.superview.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.fakeSignature.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    else
    {
        self.signatureView.superview.layer.borderColor = [UIColor orangeColor].CGColor;
    }
    [(UIButton*)[self.view viewWithTag:SignSaveButtonTag] setEnabled:NO];
    [(UIButton*)[self.view viewWithTag:SignAgainButtonTag] setEnabled:fakeImage? YES : NO];

    self.signatureView.superview.layer.borderWidth = 1.0;
    self.comments.text = self.grn.notes;
    
    //Remove data from nsuserdefaults
    [defaults removeObjectForKey:KeyImage1];
    [defaults removeObjectForKey:KeyImage2];
    [defaults removeObjectForKey:KeyImage3];
    [defaults removeObjectForKey:KeySignature];
    [defaults synchronize];
    
    self.grnDisplayed = YES;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"back"])
    {
        self.grn.notes  = self.comments.text;
        [[CoreDataManager moc] save:nil];
        GRNLineItemVC *vc = segue.destinationViewController;
        vc.grn = self.grn;
        
        //Saving pics
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:UIImagePNGRepresentation(self.image1) forKey:KeyImage1];
        [defaults setValue:UIImagePNGRepresentation(self.image2) forKey:KeyImage2];
        [defaults setValue:UIImagePNGRepresentation(self.image3) forKey:KeyImage3];
        if (self.signatureView.hasSigned)
        {
            [defaults setValue:UIImagePNGRepresentation([self.signatureView makeImage]) forKey:KeySignature];
        }
        else if (self.fakeSignature.window)
        {
            [defaults setValue:UIImagePNGRepresentation(self.fakeSignature.image) forKey:KeySignature];
        }
        [defaults synchronize];
    }
    else if ([segue.identifier isEqualToString:@"preview"])
    {
        PhotoPreviewVC *vc = segue.destinationViewController;
        vc.image = self.selectedImage;
    }
}
- (IBAction)submit:(id)sender {
    
    if (!self.grn.purchaseOrder.orderNumber.length)
    {
        NSLog(@"po = %@",self.grn.purchaseOrder);
    }
    self.grn.notes = self.comments.text;
    
    if (!self.grn.signatureURI.length)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The signature can't be blank."
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[CoreDataManager moc] save:nil];
    self.loadingView = [LoadingView loadingViewWithFrame:self.view.bounds];
    [self.view addSubview:self.loadingView];
    self.grn.submitted = [NSNumber numberWithBool:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                             (unsigned long)NULL), ^(void) 
    {
        [[CoreDataManager sharedInstance] submitAnyGrnsAwaitingSubmittion];
    });
    
    //Add SDN to core data
    [SDN InsertSDN:self.grn.supplierReference InMOC:[CoreDataManager moc]];
    
    //Adjust purchase orders
    [self updatePurchaseOrder];
    
    GRNOrderDetailsVC *orderVC = [self.navigationController.viewControllers objectAtIndex:0];
    orderVC.returnedAfterSubmission = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

-(void)onAPIRequestFailure:(M1XResponse *)response
{
    [self.navigationController popToRootViewControllerAnimated:YES];
//    NSLog(@"submit failure response = %@",response);
}

-(void)onAPIRequestSuccess:(NSDictionary *)orderData requestType:(RequestType)requestType
{
    [[CoreDataManager moc] deleteObject:self.grn];
    [[CoreDataManager moc] save:nil];
    
    //Refresh Purchase orders
    
    [self.navigationController popToRootViewControllerAnimated:YES];
//    NSLog(@"submit response = %@",orderData);
}

- (IBAction)takePhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = (id)self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects: (NSString *) kUTTypeImage,nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
    }
}


#pragma mark - ImagePicker Delegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self dismissModalViewControllerAnimated:YES];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (!self.image1)
    {
        self.grn.photo1URI = [self base64forData:imageData];
        self.image1 = image;
    }
    else if (!self.image2)
    {
        self.grn.photo2URI = [self base64forData:imageData];
        self.image2 = image;
    }
    else if (!self.image3)
    {
        self.grn.photo3URI = [self base64forData:imageData];
        self.image3 = image;
    }
    else
    {
        return;
    }
    [self refreshImageView];
}

-(void)refreshImageView
{
    [self.photoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    int i = 0;
    if (self.image1)
    {
        [self displayImage:image1 position:i tag:1];
        i++;
    }
    if(self.image2)
    {
        [self displayImage:image2 position:i tag:2];
        i++;
    }
    if(self.image3)
    {
        [self displayImage:image3 position:i tag:3];
        i++;
    }
    self.photoLabel.text = [NSString stringWithFormat:@"%i Photo%@",i, i > 1? @"s" : @""];
    self.takePhotoButton.enabled = i == 3? NO :YES;
}

-(void)displayImage:(UIImage*)image position:(int)position tag:(int)tag
{
    //calculate width
    CGFloat h = (self.photoView.frame.size.width - 10.0*3)/3;
    CGFloat w = self.photoView.frame.size.height *5/6;
    CGFloat width = h > w? w : h;

    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    int x = self.photoView.subviews.count/2;
    imageButton.frame = CGRectMake(width*position + 10.0*position, 0.0, width, width);
    [imageButton setImage:image forState:UIControlStateNormal];
    imageButton.imageView.contentMode = UIViewContentModeScaleToFill;
    imageButton.tag = tag;
    imageButton.backgroundColor = [UIColor clearColor];
    [imageButton addTarget:self
                    action:@selector(previewImage:)
          forControlEvents:UIControlEventTouchUpInside];
    imageButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.photoView addSubview:imageButton];
    
    UIButton *delete = [UIButton buttonWithType:UIButtonTypeCustom];
    delete.backgroundColor = GRNDarkBlueColour;
    delete.tag = tag;
    [delete setImage:[UIImage imageNamed:@"11-x.png"] forState:UIControlStateNormal];
    delete.imageView.contentMode = UIViewContentModeScaleAspectFit;
    delete.frame = CGRectMake(width*x + 10.0*x, width, width, width/5);
    [delete addTarget:self
               action:@selector(deletePhoto:)
     forControlEvents:UIControlEventTouchUpInside];
    delete.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.photoView addSubview:delete];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)previewImage:(UIButton*)sender
{
    self.selectedImage = sender.tag == 1? self.image1 : sender.tag == 2? self.image2 : self.image3;
    [self performSegueWithIdentifier:@"preview"
                              sender:self];
}

-(void)removePreview:(UIButton*)button
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    button.alpha = 0.0;
    [UIView commitAnimations];
    [button performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
}

-(void)deletePhoto:(UIButton*)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to remove this photo?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    alert.tag = sender.tag;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        switch (alertView.tag)
        {
            case 1:
                self.grn.photo1URI = nil;
                self.image1 = nil;
                break;
            case 2:
                self.grn.photo2URI = nil;
                self.image2 = nil;
                break;
            case 3:
                self.grn.photo3URI = nil;
                self.image3 = nil;
                break;
            default:
                break;
        }
        [self refreshImageView];
    }
}


- (NSString*)base64forData:(NSData*)theData {
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

#pragma  mark - IBActions
- (IBAction)signAgain:(UIButton*)sender
{
    [self.fakeSignature removeFromSuperview];
    [self.signatureView clearView];
    self.signatureView.userInteractionEnabled = YES;
    self.signatureView.superview.layer.borderColor = [UIColor orangeColor].CGColor;
    self.grn.signatureURI = nil;
    sender.enabled = NO;
    [(UIButton*)[self.view viewWithTag:SignSaveButtonTag] setEnabled:NO];
}
- (IBAction)saveSignature:(UIButton*)sender
{
    self.signatureView.userInteractionEnabled = NO;
    self.signatureView.superview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    sender.enabled = NO;
    [(UIButton*)[self.view viewWithTag:SignAgainButtonTag] setEnabled:YES];
}

- (IBAction)showDatePicker:(UIButton*)button
{
    UIViewController* popoverContent = [[UIViewController alloc] init]; //ViewController
    
    UIView *popoverView = [[UIView alloc] init];   //view
    popoverView.backgroundColor = [UIColor blackColor];
    
    UIDatePicker *datePicker=[[UIDatePicker alloc]init];//Date picker
    datePicker.frame=CGRectMake(0,44,320, 216);
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setMinuteInterval:5];
    [datePicker setMaximumDate:[NSDate date]];
    [datePicker setTag:10];
    [datePicker addTarget:self action:@selector(donePickingDate:) forControlEvents:UIControlEventValueChanged];
    [popoverView addSubview:datePicker];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, datePicker.frame.size.width, 44.0)];
    toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(removeDatePicker)];
    toolbar.items = [NSArray arrayWithObject:done];
    [popoverView addSubview:toolbar];
    
    popoverContent.view = popoverView;
    self.popVC = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    self.popVC.delegate=self;
    
    [self.popVC setPopoverContentSize:CGSizeMake(320, 264) animated:NO];
    [self.popVC presentPopoverFromRect:button.superview.frame inView:button.superview.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    self.dateButton.superview.layer.borderColor = [UIColor orangeColor].CGColor;
    [self.comments resignFirstResponder];
}

-(void)donePickingDate:(UIDatePicker*)picker
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd/MM/yyyy";
    NSString *date = [formatter stringFromDate:picker.date];
    [self.dateButton setTitle:date forState:UIControlStateNormal];
    self.grn.deliveryDate = picker.date;
}

-(void)removeDatePicker
{
    self.dateButton.superview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.popVC dismissPopoverAnimated:YES];
}

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    self.dateButton.superview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.superview.layer.borderColor = GRNLightBlueColour.CGColor;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    textView.superview.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

-(void)disableUserInteractionForSignatureView
{
    self.signatureView.userInteractionEnabled = NO;
}

-(void)drawViewDidEndDrawing
{
    self.grn.signatureURI = [self base64forData:UIImageJPEGRepresentation([self.signatureView makeImage],1.f)];
    [(UIButton*)[self.view viewWithTag:SignSaveButtonTag] setEnabled:YES];
    [(UIButton*)[self.view viewWithTag:SignAgainButtonTag] setEnabled:YES];
}


-(void)updatePurchaseOrder
{
    PurchaseOrder *po = self.grn.purchaseOrder;
    int poItemsRemoved = 0;
    for (PurchaseOrderItem *poItem in po.lineItems)
    {
        GRNItem *grnItem = [self itemForPurchaseOrderItem:poItem];
        poItem.quantityBalance = [NSNumber numberWithInt:[[poItem quantityBalance] intValue] - ([grnItem.quantityDelivered intValue] - [grnItem.quantityRejected intValue])];
        if ([poItem.quantityBalance intValue] <= 0)
        {
            @try
            {
                [[CoreDataManager moc] deleteObject:poItem];
            }
            @catch (NSException *e)
            {
                //TOOD
            }
            poItemsRemoved++;
        }
    }
    if ([po.lineItems count] == poItemsRemoved)
    {
        @try
        {
        [[CoreDataManager moc] deleteObject:po];
        }
        @catch (NSException *e)
        {
            //TOOD
        }
    }
    [[CoreDataManager moc] save:nil];
}

-(GRNItem*)itemForPurchaseOrderItem:(PurchaseOrderItem*)item
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemNumber = %@", item.itemNumber];
    return [[self.grn.lineItems filteredSetUsingPredicate:predicate] anyObject];
}


#pragma mark - Orientation Adjustments

-(void)checkOrientation
{
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        [self showLandscapeView];
    }
    else
    {
        [self showPortraitView];
    }
}

-(void)showPortraitView
{
    CGRect frame = self.dateAndNoteContainer.frame;
    frame.origin.x = 41.0;
    frame.origin.y = 137.0;
    frame.size.width = 713.0;
    frame.size.height = 300.0;
    self.dateAndNoteContainer.frame = frame;
    
    frame = self.photoAndSignContainer.frame;
    frame.origin.x = 51.0;
    frame.origin.y = 441.0;
    frame.size.width = 672.0;
    frame.size.height = 489.0;
    self.photoAndSignContainer.frame = frame;
    
    frame = self.signButton.frame;
    frame.origin.x = 531.0;
    frame.origin.y = 356.0;
    self.signButton.frame = frame;
}

-(void)showLandscapeView
{
    CGRect frame = self.dateAndNoteContainer.frame;
    frame.origin.x = 20.0;
    frame.origin.y = 134.0;
    frame.size.width = 450.0;
    frame.size.height = 500.0;
    self.dateAndNoteContainer.frame = frame;
    
    frame = self.photoAndSignContainer.frame;
    frame.origin.x = 482.0;
    frame.origin.y = 134.0;
    frame.size.width = 530.0;
    frame.size.height = 500.0;
    self.photoAndSignContainer.frame = frame;
    
    frame = self.signButton.frame;
    frame.origin.x = 7.0;
    frame.origin.y = 216.0;
    self.signButton.frame = frame;
}

@end
