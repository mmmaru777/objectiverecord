//
//  Hoge.h
//  objectiverecord
//
//  Created by Kenji Maruyama on 12/04/19.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entity.h"

@interface Hoge : Entity 

@property (nonatomic, copy) NSString *str;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSData *data;
@property NSInteger i;
@property BOOL b; 
@property int count;
@property float f;
@property double d;

@end
