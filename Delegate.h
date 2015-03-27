//
//  Delegate.h
//  MyContacts
//
//  Created by iGuest on 3/26/15.
//  Copyright (c) 2015 Chuck Konkol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

@interface Delegate : NSObject <CHCSVParserDelegate>

@property (readonly) NSArray *lines;
-(void)executeParsing;

@end
