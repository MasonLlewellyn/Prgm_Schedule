//
//  Weather.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/22/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "Weather.h"
#import <AFNetworking/AFNetworking.h>

NSString *API_KEY = @"bc4e17fd97575a98976af35841962bef";
@implementation Weather
+ (void)initialize:(void (^)(NSError * _Nonnull))completion{
    //Get the weather from the OpenWeatherAPI
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSString *baseURL = @"http://api.openweathermap.org/data/2.5/weather?q=London,uk&appid=";
    NSString *fullURL = [NSString stringWithFormat:@"%@%@", baseURL, API_KEY];
    
    NSURL *URL = [NSURL URLWithString:fullURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil
    completionHandler:^(NSURLResponse *response, id  responseObject, NSError *error) {
        if (!error){
            [self setTemperature:[responseObject[@"main"][@"temp"] floatValue]];
            [self setConditionStr:responseObject[@"weather"][@"main"]];
        }
        completion(error);
    }];
    
    [dataTask resume];
}

+ (void)setTemperature:(float)tempValue{
    temperature = tempValue;
}

+ (float)getTemperature{
    return temperature;
}

+ (void) setConditionStr:(NSString *)condition{
    conditionStr = condition;
}

+ (NSString*)getConditionStr{
    return conditionStr;
}
@end
