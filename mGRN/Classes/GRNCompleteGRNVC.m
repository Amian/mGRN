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

@interface GRNCompleteGRNVC()<UIImagePickerControllerDelegate, M1XmGRNDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, strong) UIImage *image3;
@property (nonatomic, strong) UIImage *selectedImage;
@end

@implementation GRNCompleteGRNVC
@synthesize grn = _grn, image1, image2, image3;

-(void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setDelivery:nil];
    [self setComments:nil];
    [self setSignatureView:nil];
    [self setPhotoView:nil];
    [self setPhotoLabel:nil];
    [self setTakePhotoButton:nil];
    [super viewDidUnload];
}
- (IBAction)clearSignatureView:(id)sender
{
    [self.signatureView clearView];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"id = %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"submitGRN"])
    {
        //TODO: submit GRN
        [self submit];
    }
    else if ([segue.identifier isEqualToString:@"back"])
    {
        GRNCompleteGRNVC *vc = segue.destinationViewController;
        vc.grn = self.grn;
    }
    else if ([segue.identifier isEqualToString:@"preview"])
    {
        PhotoPreviewVC *vc = segue.destinationViewController;
        vc.image = self.selectedImage;
    }
}

-(void)submit
{
    M1XmGRNService *service = [[M1XmGRNService alloc] init];
    service.delegate = self;
    NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
    kco = [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
    
    M1XGRN *grn = [[M1XGRN alloc] init];
    if (self.delivery.text.length)
    {
        grn.deliveryDate = [NSString stringWithFormat:@"\/Date(%@)\/",[self.delivery.text stringByReplacingOccurrencesOfString:@"/" withString:@""]];
    }
    else
    {
        grn.deliveryDate = @"\/Date(121212)\/"; //TODO:
    }
    
    grn.ID = self.grn.orderNumber; //TODO: whats this?
    grn.kco = kco;
    grn.notes = self.grn.notes;
    grn.orderNumber = self.grn.purchaseOrder.orderNumber;
    grn.photo1 = self.grn.photo1URI;
    grn.photo2 = self.grn.photo2URI;
    grn.photo3 = self.grn.photo3URI;
    grn.signature = [self base64forData:UIImageJPEGRepresentation([self.signatureView makeImage],1.f)];
    grn.supplierReference = self.grn.supplierReference;
    NSMutableArray *items = [NSMutableArray array];
    for (GRNItem *item in self.grn.lineItems)
    {
        M1XLineItems *newItem = [[M1XLineItems alloc] init];
        newItem.exception = item.exception;
        //        newItem.ID = item.itemNumber; //TODO: item description
        newItem.item = item.itemNumber;
        newItem.notes = item.notes;
        newItem.quantityDelivered = [NSString stringWithFormat:@"%i",[item.quantityDelivered intValue]];
        newItem.quantityRejected = [NSString stringWithFormat:@"%i",[item.quantityRejected intValue]];
        newItem.serialNumber = item.serialNumber;
        newItem.unitOfQuantityDelivered = item.uoq;
        newItem.wbsCode = item.wbsCode;
        [items addObject:newItem];
    }
    
    [service DoSubmissionWithHeader:[GRNM1XHeader GetHeader]
                                grn:grn
                          lineItems:items
                                kco:kco];
    
}

-(void)onGetContractsFailure:(M1XResponse *)response
{
    //If communication failed, use cached data
    NSLog(@"submit response = %@",response);
}

-(void)onGetContractsSuccess:(NSDictionary *)orderData
{
    [[CoreDataManager sharedInstance].managedObjectContext deleteObject:self.grn];
    [[CoreDataManager sharedInstance].managedObjectContext save:nil];
    NSLog(@"submit response = %@",orderData);
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
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = 130.0;
    int x = self.photoView.subviews.count/2;
    imageButton.frame = CGRectMake(width*position + 10.0*position, 0.0, width, width);
    [imageButton setImage:image forState:UIControlStateNormal];
    imageButton.imageView.contentMode = UIViewContentModeScaleToFill;
    imageButton.tag = tag;
    imageButton.backgroundColor = [UIColor clearColor];
    [imageButton addTarget:self
                    action:@selector(previewImage:)
          forControlEvents:UIControlEventTouchUpInside];
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
//    UIButton *imagePreview = [UIButton buttonWithType:UIButtonTypeCustom];
//    imagePreview.frame = self.view.bounds;
//    switch (sender.tag) {
//        case 1:
//            [imagePreview setImage:self.image1 forState:UIControlStateNormal && UIControlStateHighlighted];
//            break;
//        case 2:
//            [imagePreview setImage:self.image2 forState:UIControlStateNormal && UIControlStateHighlighted];
//            break;
//        case 3:
//            [imagePreview setImage:self.image3 forState:UIControlStateNormal && UIControlStateHighlighted];
//            break;
//        default:
//            break;
//    }
//    imagePreview.backgroundColor = GRNDarkBlueColour;
//    [imagePreview addTarget:self
//                     action:@selector(removePreview:)
//           forControlEvents:UIControlEventTouchUpInside];
//    imagePreview.alpha = 0.0;
//    [self.view addSubview:imagePreview];
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.3];
//    imagePreview.alpha = 1.0;
//    [UIView commitAnimations];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Photo"
                                                    message:@"Are you sure you want to remove this photo?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Delete", nil];
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
@end
