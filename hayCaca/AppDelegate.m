//
//  AppDelegate.m
//  hayCaca
//
//  Created by Dario Segura on 2013-04-02.
//  Copyright (c) 2013 Dario Segura. All rights reserved.
//

#import "AppDelegate.h"
#include "config.h"
#include "caca.h"


static caca_canvas_t *cv;
static caca_display_t *dp;
static int XSIZ, YSIZ;
static caca_dither_t *caca_dither;
static char *bitmap;
static int paused = 0;
#define MAXTABLE (256*5)
static unsigned int table[MAXTABLE];

static int const pal[] =
{
    0, 0, 0, 0, 0, 6, 0, 0, 6, 0, 0, 7, 0, 0, 8, 0, 0, 8, 0, 0, 9, 0, 0, 10,
    2, 0, 10, 4, 0, 9, 6, 0, 9, 8, 0, 8, 10, 0, 7, 12, 0, 7, 14, 0, 6, 16, 0, 5,
    18, 0, 5, 20, 0, 4, 22, 0, 4, 24, 0, 3, 26, 0, 2, 28, 0, 2, 30, 0, 1, 32, 0, 0,
    32, 0, 0, 33, 0, 0, 34, 0, 0, 35, 0, 0, 36, 0, 0, 36, 0, 0, 37, 0, 0, 38, 0, 0,
    39, 0, 0, 40, 0, 0, 40, 0, 0, 41, 0, 0, 42, 0, 0, 43, 0, 0, 44, 0, 0, 45, 0, 0,
    46, 1, 0, 47, 1, 0, 48, 2, 0, 49, 2, 0, 50, 3, 0, 51, 3, 0, 52, 4, 0, 53, 4, 0,
    54, 5, 0, 55, 5, 0, 56, 6, 0, 57, 6, 0, 58, 7, 0, 59, 7, 0, 60, 8, 0, 61, 8, 0,
    63, 9, 0, 63, 9, 0, 63, 10, 0, 63, 10, 0, 63, 11, 0, 63, 11, 0, 63, 12, 0, 63, 12, 0,
    63, 13, 0, 63, 13, 0, 63, 14, 0, 63, 14, 0, 63, 15, 0, 63, 15, 0, 63, 16, 0, 63, 16, 0,
    63, 17, 0, 63, 17, 0, 63, 18, 0, 63, 18, 0, 63, 19, 0, 63, 19, 0, 63, 20, 0, 63, 20, 0,
    63, 21, 0, 63, 21, 0, 63, 22, 0, 63, 22, 0, 63, 23, 0, 63, 24, 0, 63, 24, 0, 63, 25, 0,
    63, 25, 0, 63, 26, 0, 63, 26, 0, 63, 27, 0, 63, 27, 0, 63, 28, 0, 63, 28, 0, 63, 29, 0,
    63, 29, 0, 63, 30, 0, 63, 30, 0, 63, 31, 0, 63, 31, 0, 63, 32, 0, 63, 32, 0, 63, 33, 0,
    63, 33, 0, 63, 34, 0, 63, 34, 0, 63, 35, 0, 63, 35, 0, 63, 36, 0, 63, 36, 0, 63, 37, 0,
    63, 38, 0, 63, 38, 0, 63, 39, 0, 63, 39, 0, 63, 40, 0, 63, 40, 0, 63, 41, 0, 63, 41, 0,
    63, 42, 0, 63, 42, 0, 63, 43, 0, 63, 43, 0, 63, 44, 0, 63, 44, 0, 63, 45, 0, 63, 45, 0,
    63, 46, 0, 63, 46, 0, 63, 47, 0, 63, 47, 0, 63, 48, 0, 63, 48, 0, 63, 49, 0, 63, 49, 0,
    63, 50, 0, 63, 50, 0, 63, 51, 0, 63, 52, 0, 63, 52, 0, 63, 52, 0, 63, 52, 0, 63, 52, 0,
    63, 53, 0, 63, 53, 0, 63, 53, 0, 63, 53, 0, 63, 54, 0, 63, 54, 0, 63, 54, 0, 63, 54, 0,
    63, 54, 0, 63, 55, 0, 63, 55, 0, 63, 55, 0, 63, 55, 0, 63, 56, 0, 63, 56, 0, 63, 56, 0,
    63, 56, 0, 63, 57, 0, 63, 57, 0, 63, 57, 0, 63, 57, 0, 63, 57, 0, 63, 58, 0, 63, 58, 0,
    63, 58, 0, 63, 58, 0, 63, 59, 0, 63, 59, 0, 63, 59, 0, 63, 59, 0, 63, 60, 0, 63, 60, 0,
    63, 60, 0, 63, 60, 0, 63, 60, 0, 63, 61, 0, 63, 61, 0, 63, 61, 0, 63, 61, 0, 63, 62, 0,
    63, 62, 0, 63, 62, 0, 63, 62, 0, 63, 63, 0, 63, 63, 1, 63, 63, 2, 63, 63, 3, 63, 63, 4,
    63, 63, 5, 63, 63, 6, 63, 63, 7, 63, 63, 8, 63, 63, 9, 63, 63, 10, 63, 63, 10, 63, 63, 11,
    63, 63, 12, 63, 63, 13, 63, 63, 14, 63, 63, 15, 63, 63, 16, 63, 63, 17, 63, 63, 18, 63, 63, 19,
    63, 63, 20, 63, 63, 21, 63, 63, 21, 63, 63, 22, 63, 63, 23, 63, 63, 24, 63, 63, 25, 63, 63, 26,
    63, 63, 27, 63, 63, 28, 63, 63, 29, 63, 63, 30, 63, 63, 31, 63, 63, 31, 63, 63, 32, 63, 63, 33,
    63, 63, 34, 63, 63, 35, 63, 63, 36, 63, 63, 37, 63, 63, 38, 63, 63, 39, 63, 63, 40, 63, 63, 41,
    63, 63, 42, 63, 63, 42, 63, 63, 43, 63, 63, 44, 63, 63, 45, 63, 63, 46, 63, 63, 47, 63, 63, 48,
    63, 63, 49, 63, 63, 50, 63, 63, 51, 63, 63, 52, 63, 63, 52, 63, 63, 53, 63, 63, 54, 63, 63, 55,
    63, 63, 56, 63, 63, 57, 63, 63, 58, 63, 63, 59, 63, 63, 60, 63, 63, 61, 63, 63, 62, 63, 63, 63};

static void
initialize (void)
{
    int i;
    uint32_t r[256], g[256], b[256], a[256];
    cv = caca_create_canvas(32, 38);
    if (!cv)
    {
        printf ("Failed to initialize libcaca\n");
        exit (1);
    }
    dp = caca_create_display(cv);
    if (!dp)
    {
        printf ("Failed to initialize libcaca\n");
        exit (1);
    }
    caca_set_display_time(dp, 10000);
    XSIZ = caca_get_canvas_width(cv) * 2;
    YSIZ = caca_get_canvas_height(cv) * 2 - 4;
    
    for (i = 0; i < 256; i++)
    {
        r[i] = pal[i * 3] * 64;
        g[i] = pal[i * 3 + 1] * 64;
        b[i] = pal[i * 3 + 2] * 64;
        a[i] = 0xfff;
    }
    
    caca_dither = caca_create_dither(8, XSIZ, YSIZ - 2, XSIZ, 0, 0, 0, 0);
    caca_set_dither_palette(caca_dither, r, g, b, a);
    bitmap = malloc(4 * caca_get_canvas_width(cv)
                    * caca_get_canvas_height(cv));
    memset(bitmap, 0, 4 * caca_get_canvas_width(cv)
           * caca_get_canvas_height(cv));
    
}

static void
uninitialize (void)
{
    caca_free_display(dp);
    caca_free_canvas(cv);
    exit (0);
}

static void
gentable (void)
{
    unsigned int i, p2;
    unsigned int minus = 800 / YSIZ;
    if (minus == 0)
        minus = 1;
    for (i = 0; i < MAXTABLE; i++)
    {
        if (i > minus)
        {
            p2 = (i - minus) / 5;
            table[i] = p2;
        }
        else
            table[i] = 0;
    }
}

#define MA 5
static void
firemain (void)
{
    register unsigned int i;
    unsigned char *p;
    i = 0;
#define END (bitmap + XSIZ * YSIZ)
    for (p = (unsigned char*)bitmap;
         (char*)p <= (( char *) (END));
         p += 1)
    {
        *p = table[(*(p + XSIZ - 1) + *(p + XSIZ + 1) + *(p + XSIZ)) +
                   (*(p + 2 * XSIZ - 1) + *(p + 2 * XSIZ + 1))];
    }
}

#define min(x,y) ((x)<(y)?(x):(y))
static void
drawfire (void)
{
    unsigned int i, last1, i1, i2;
    static int loop = 0, sloop = 0;
    static unsigned int height = 0;
    register unsigned char *p;
    if(paused)
        goto _paused;
    
    height++;
    loop--;
    if (loop < 0)
        loop = rand () % 3, sloop++;;
    i1 = 1;
    i2 = 4 * XSIZ + 1;
    for (p = (unsigned char *) bitmap + XSIZ * (YSIZ + 0);
         p < ((unsigned char *) bitmap + XSIZ * (YSIZ + 1));
         p++, i1 += 4, i2 -= 4)
    {
        last1 = rand () % min (i1, min (i2, height));
        i = rand () % 6;
        for (; p < (unsigned char *) bitmap + XSIZ * (YSIZ + 1) && i != 0;
             p++, i--, i1 += 4, i2 -= 4)
            *p = last1, last1 += rand () % 6 - 2, *(p + XSIZ) = last1, last1 +=
            rand () % 6 - 2;
        *(p + 2 * XSIZ) = last1, last1 += rand () % 6 - 2;
    }
    i = 0;
    firemain ();
_paused:
    caca_dither_bitmap(cv, 0, 0, caca_get_canvas_width(cv),
                       caca_get_canvas_height(cv), caca_dither, bitmap);
    caca_set_color_ansi(cv, CACA_WHITE, CACA_BLUE);
    if (sloop < 100)
        caca_put_str(cv, caca_get_canvas_width(cv) - 30,
                     caca_get_canvas_height(cv) - 2,
                     " -=[ Powered by libcaca ]=- ");
    
    caca_refresh_display(dp);
    /*XSIZ = caca_get_width() * 2;
     YSIZ = caca_get_height() * 2 - 4;*/
}

static void
game (void)
{
    gentable ();
    //for(;;)
    {
        caca_event_t ev;
        if(caca_get_event(dp, CACA_EVENT_KEY_PRESS|CACA_EVENT_QUIT, &ev, 0))
        {
            if (caca_get_event_type(&ev) & CACA_EVENT_QUIT)
                return;
            switch(caca_get_event_key_ch(&ev))
            {
                case CACA_KEY_CTRL_C:
                case CACA_KEY_CTRL_Z:
                case CACA_KEY_ESCAPE: return;
                case ' ': paused = !paused;
            }
        }
        drawfire ();
    }
}

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

-(void) loopy
{
    while (1)
    {
        @autoreleasepool
        {
            NSTimeInterval before = [NSDate timeIntervalSinceReferenceDate];
            game();
            [NSThread sleepForTimeInterval:0.016 - ([NSDate timeIntervalSinceReferenceDate] - before)];
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    initialize ();
    [NSThread detachNewThreadSelector:@selector(loopy) toTarget:self withObject:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    uninitialize ();
}

@end
