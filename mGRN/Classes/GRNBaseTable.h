//
//  GRNBaseTable.h
//  mGRN
//
//  Created by Anum on 02/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M1XmGRNService.h"
#import "GRNM1XHeader.h"
#import "CoreDataManager.h"

@protocol MyTableDelegate <NSObject>
-(void)tableWillGetDataFromAPI;
-(void)tableDidEndLoadingData:(UITableView*)table;
-(void)failedToGetData:(UITableView*)tableView;
@end

typedef enum
{
    TableStateNormal,
    TableStateSelected
}TableState;

//Abstract Class
@interface GRNBaseTable : UITableView <M1XmGRNDelegate, UITableViewDataSource>
@property (nonatomic) TableState state;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, strong) IBOutlet id<MyTableDelegate> myDelegate;
@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, strong) M1XmGRNService *service;
@property (readonly) NSString *kco;
@property BOOL reloading;
@property (nonatomic) BOOL sessionExpired;
-(NSArray*)getDataArray;
-(void)getDataFromAPI;
-(id)selectedObject;
-(void)rowSelected;
-(void)searchForString:(NSString*)searchString;
-(void)doneSearching;
@end
