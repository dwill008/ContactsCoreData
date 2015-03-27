//
//  Delegate.m
//  MyContacts
//
//  Created by iGuest on 3/26/15.
//  Copyright (c) 2015 Chuck Konkol. All rights reserved.
//

#import "Delegate.h"

@implementation Delegate {
    NSMutableArray *_lines;
    NSMutableArray *_currentLine;
}
- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    _lines = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    _currentLine = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    NSLog(@"%@", field);
    [_currentLine addObject:field];
}
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    [_lines addObject:_currentLine];
    _currentLine = nil;
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
    //	NSLog(@"parser ended: %@", csvFile);
}
- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"ERROR: %@", error);
    _lines = nil;
}

-(void)executeParsing{
    @autoreleasepool {
        NSString *file = @(__FILE__);
        file = [[file stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Top_10_Rides_Content_pictureReplaced.csv"];
        
        NSLog(@"Beginning...");
        NSStringEncoding encoding = 0;
        NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:file];
        CHCSVParser * p = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:&encoding delimiter:','];
        [p setRecognizesBackslashesAsEscapes:YES];
        [p setSanitizesFields:YES];
        
        NSLog(@"encoding: %@", CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(encoding)));
        
        Delegate * d = [[Delegate alloc] init];
        [p setDelegate:d];
        
        NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
        [p parse];
        NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
        
        NSLog(@"raw difference: %f", (end-start));
        
        NSLog(@"%@", [d lines]);
    }
}

@end
