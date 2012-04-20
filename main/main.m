//
//  main.m
//  main
//
//  Created by Kenji Maruyama on 12/04/19.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityManager.h"
#import "Hoge.h"


@interface ThreadTest : NSObject
+ (void) tMethod: (id)param ;
@end

@implementation ThreadTest 

+ (void) tMethod: (id)param {
  NSAutoreleasePool* pool = nil;
  NSLog(@"thread OK");
  @try {
    pool = [[NSAutoreleasePool alloc] init];
    EntityManager *entityManager = [[[EntityManager alloc] initWithDataPath:@"/Users/KENJI/Temp/test.db"] autorelease];
    Hoge *thoge = (Hoge *)[entityManager create:@"Hoge"];
    for(int i=0; i<5; i++) {
      thoge.count = 10;
      [thoge save];
    }
  }
  @finally {
    [pool release];
  }
  
}

@end


int main (int argc, const char * argv[])
{
  
  @autoreleasepool {
    
    EntityManager *entityManager = [[EntityManager alloc] initWithDataPath:@"/Users/KENJI/Temp/test.db"];
    NSLog(@"sqliteVersion: %@", [entityManager sqliteVersion]);
    NSLog(@"getdbPath: %@", [entityManager getdbPath]);
    
    // test create table
    Hoge *hoge = (Hoge *)[entityManager create:@"Hoge"];
    
    // test insert
    hoge.count = 3;
    hoge.f = 1.2f;
    hoge.d = 3.45;
    hoge.date = [NSDate date];
    hoge.str = @"test";
    hoge.i = 1;
    hoge.b = NO;
    
    NSDictionary *dic =[NSDictionary dictionaryWithObject:@"hoge" forKey:@"KEY"];
    hoge.data = [NSKeyedArchiver archivedDataWithRootObject:dic];; 
  
    [hoge save];
    
    // test update
    hoge.count = 4;
    [hoge save];
    
    // test sequence of updating
    hoge.str = @"OK?";
    [hoge save];
    
    // test another entity if table is already exist.
    Hoge *hogehoge = (Hoge *)[entityManager create:@"Hoge"];
    hogehoge.count = 10;
    hogehoge.str = @"OK2";
    [hogehoge save];
    
    
    // test find all data
    NSArray *na = [entityManager find:@"Hoge"];
    NSLog(@" ==================== Start find all ====================");
    for (id obj in na) {
      Hoge *fHoge = (Hoge*)obj;
      NSLog(@"count is: %d", fHoge.count);
      NSLog(@"str is : %@", fHoge.str);
      NSLog(@"date is : %@", fHoge.date);
      NSLog(@"data is : %@", fHoge.data);
      NSLog(@"i is : %ld", fHoge.i);
      NSLog(@"b is : %d", fHoge.b);
      NSLog(@"f is : %f", fHoge.f);
      NSLog(@"d is : %f", fHoge.d);
      
    }
    NSLog(@" ==================== End of find all ====================");
    
    // test find data
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"='OK?'", @"str", @"< 6", @"count", nil];
    NSArray *nb = [entityManager find:@"Hoge" withArgument:args];
    NSLog(@" ==================== Start find  ====================");
    for (id obj in nb) {
      Hoge *fHoge = (Hoge*)obj;
      NSLog(@"count is: %d", fHoge.count);
      NSLog(@"str is : %@", fHoge.str);
      NSLog(@"date is : %@", fHoge.date);
      NSLog(@"data is : %@", fHoge.data);
      NSLog(@"i is : %ld", fHoge.i);
      NSLog(@"b is : %d", fHoge.b);
      NSLog(@"f is : %f", fHoge.f);
      NSLog(@"d is : %f", fHoge.d);
    }
    NSLog(@" ==================== End of find  ====================");
    
    // test delete data
    NSDictionary *delargs = [NSDictionary dictionaryWithObjectsAndKeys:@"='OK?'", @"str", @"< 6", @"count", nil];
    [entityManager delete:@"Hoge" withArgument:delargs];
    
    // test delete all data
    [entityManager delete:@"Hoge"];
    
    /*
    // test multi object
    [hoge release];
    [NSThread detachNewThreadSelector:@selector(tMethod:) toTarget:[ThreadTest class] withObject:nil];
    */
  }
  return 0;
}

