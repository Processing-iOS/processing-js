//
//  PDESketch.m
//  Processing for iOS
//
//  Created by Frederik Riedel on 10/25/17.
//  Copyright © 2017 Frederik Riedel. All rights reserved.
//

#import "PDESketch.h"
#import "SketchController.h"
#import "Processing_for_iOS-Swift.h"
#import "FRFileManager.h"

@implementation PDESketch

-(instancetype)initWithSketchName:(NSString*)sketchName {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.sketchName = sketchName;
    return self;
}

-(NSArray<PDEFile *> *)pdeFiles {
    NSArray *filePathsArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[SketchController documentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"sketches/%@",self.sketchName]]  error:nil];
    NSMutableArray* pdeFiles = [NSMutableArray array];
    for (NSString* pdeFileName in filePathsArray) {
        if ([pdeFileName.pathExtension isEqualToString:@"pde"]) {
            PDEFile* pdeFile = [[PDEFile alloc] initWithFileName:pdeFileName.stringByDeletingPathExtension partOfSketch:self];
            [pdeFiles addObject:pdeFile];
        }
    }
    
    if (!pdeFiles.count) {
        // check main bundle if we can copy the associated sample file
    }
    
    return pdeFiles.copy;
}

-(NSString*)filePath {
    return [NSString stringWithFormat:@"%@/sketches/%@",[FRFileManager documentsDirectory],self.sketchName];
}

-(NSString*)cummulatedSourceCode {
    NSMutableString* result = [NSMutableString string];
    for (PDEFile* file in self.pdeFiles) {
        [result appendString:file.loadCode];
    }
    
    return result.copy;
}

-(NSString*)htmlPage {
    NSString *processingjs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"processing.min" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    
    UIImage* appIconImage = [self.appIcon resizeWithNewWidth:192];
    NSString* base64 = [appIconImage base64];
    
    NSString* content = [NSString stringWithFormat: [FRFileManager containerFile], base64, processingjs, _sketchName, self.cummulatedSourceCode];
    
    return content;
}

-(NSDate *)creationDate {
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:self.filePath error:nil];
    
    if (attrs != nil) {
        return (NSDate*)[attrs objectForKey: NSFileCreationDate];
    }
    
    return nil;
}

@end

