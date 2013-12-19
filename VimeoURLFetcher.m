//
//  VimeoURLFetcher.m
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Russell Quinn / False Vacuum Industries
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "VimeoURLFetcher.h"

@implementation VimeoURLFetcher

@synthesize delegate;
@synthesize error;
@synthesize orignalURL;
@synthesize fetchedURL;

- (void)dealloc
{
    [orignalURL release];
    [fetchedURL release];
    [error release];
    [htmlConnection release];
    [jsonConnection release];
    [responseData release];
    [super dealloc];
}

- (BOOL)getRawVimeoURLFromURL:(NSString *)url
{
    if (orignalURL != nil)
    {
        return NO;
    }

    orignalURL = url;
    [orignalURL retain];
    
    [htmlConnection release];
    htmlConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
    [htmlConnection retain];
    
    return (htmlConnection != nil);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData release];
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theError
{
    [error release];
    error = theError;
    [error retain];
    
    [responseData release];
    responseData = nil;
    
    [self.delegate vimeoURLFetcherFinished:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([connection isEqual:htmlConnection])
    {
        NSString *rawHTML = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
        
        NSUInteger totalLength = rawHTML.length;
        
        NSRange dataConfigURLRange = [rawHTML rangeOfString:@"data-config-url="];
        NSUInteger searchStartPoint = dataConfigURLRange.location + dataConfigURLRange.length;
        NSRange openingQuoteRange = [rawHTML rangeOfString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(searchStartPoint, totalLength - searchStartPoint)];
        searchStartPoint = openingQuoteRange.location + openingQuoteRange.length;
        NSRange closingQuoteRange = [rawHTML rangeOfString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(searchStartPoint, totalLength - searchStartPoint)];
        NSString *jsonURL = [rawHTML substringWithRange:NSMakeRange(openingQuoteRange.location + openingQuoteRange.length, closingQuoteRange.location - (openingQuoteRange.location + openingQuoteRange.length))];
        
        [responseData release];
        responseData = nil;
        
        if (jsonURL != nil && jsonURL.length > 0)
        {
            jsonURL = [jsonURL stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            
            [jsonConnection release];
            jsonConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:jsonURL]] delegate:self];
            [jsonConnection retain];
        }
        else
        {
            [self.delegate vimeoURLFetcherFinished:self];
        }
    }
    else if ([connection isEqual:jsonConnection])
    {
        NSError *jsonError;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        
        [responseData release];
        responseData = nil;
        
        if (jsonData != nil)
        {
            [fetchedURL release];
            fetchedURL = [[[[[jsonData objectForKey:@"request"] objectForKey:@"files"] objectForKey:@"h264"] objectForKey:@"hd"] objectForKey:@"url"];
            [fetchedURL retain];
        }
        else
        {
            [error release];
            error = jsonError;
            [error retain];
        }
        
        [self.delegate vimeoURLFetcherFinished:self];
    }
}

@end
