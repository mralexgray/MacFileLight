/* Copyright (C) 1996 Dave Vasilevsky 
 	This file is licensed under the GNU General Public License, see the file Copying.txt for details. */

#import "FLFile.h"

@interface FLScanner : NSObject
{
   NSProgressIndicator 	*m_pi;
   NSTextField  			*m_display;
   FLDirectory  			*m_tree;
   NSString 	  			*m_path,
								*m_error,
								*m_last_path;
   double 					m_increment,
					 			m_progress;
	uint32_t 				m_files,
								m_seen;
   SEL 						m_post_sel;
   id 						m_post_obj;
   NSLock 					*m_lock;
	BOOL 						m_cancelled;
}
@property (weak) NSImageView * iV;

- (id) initWithPath: (NSString*)path
           progress: (NSProgressIndicator*)progress
            display: (NSTextField*)display;

- (id) initWithPath: (NSString*)path
           progress: (NSProgressIndicator*)progress
            display: (NSTextField*)display
			  	   icon: (NSImageView*)view;

- (void) scanThenPerform:(SEL) selector
							 on:(id)obj;

-         (void) cancel;
-         (BOOL) isCancelled;
- (FLDirectory*) scanResult;
-    (NSString*) scanError;

+ (BOOL) isMountPoint: 		  (NSString*)path;
+ (BOOL) isMountPointCPath:(const char*)cpath;

@end
