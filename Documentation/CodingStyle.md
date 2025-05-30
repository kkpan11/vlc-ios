# Coding Style Rules

This document defines Swift and Objective-C code style rules for this project.

## Table of Contents
* [Swift](#swift)
* [Objective-C](#objective-c)
* [Commit naming](#commit-naming)

## Swift

The swift code style rules are defined by [this set of swiftlint rules](../.swiftlint.yml)

## Objective-C

Variable names should use capitalization on all word expect the first, and never '_' ie

**Right:**
```obj-c
BOOL isFirstTimeReading;
int age;
NSArray *myArray;
```

**Wrong:**
```objc-c
BOOL is_first_time_reading;
int Age;
int isFirstTimeReading_ever;
```

Objective-C Instance variables must be prefixed with _

**Right:**
```obj-c
@interface Object {
	  BOOL _isFirstTimeReading;
	  int _age;
}
```

**Wrong:**
```objc-c
@interface Object {
	  BOOL isFirstTimeReading;
	  int age;
}
```

Pointer * must be preceded with a space and with no space after ie

**Right:**
```obj-c
void *pointer;
```

**Wrong:**
```objc-c
void * pointer;
void* pointer;
void*pointer;
```

If, switch, and other keyword that are not function but takes parameter should have a space before ()

**Right:**
```obj-c
if (a) {
  ...
}
function();
```

**Wrong:**
```objc-c
if( a )
if ( a )
if(a)
function ();
```

Brackets usage

**Right:**
```obj-c
if (a) {
   ...
}
while (a) {
   ...
}
void function()
{
   ...
}
- (void)functionWithParameter:(BOOL)parameter
{
   ...
}
```

**Wrong:**
```objc-c
- (void)function {
   ...
}
if (a)
{
   ...
}
```

Prefer early return ie:

**Prefer:**
```obj-c
if (!a)
    return;
```

**Over:**
```objc-c
if (a) {
  ...
  ...
}
```

Objective C code - Don't call multiply the same method.

**Right:**
```obj-c
NSWindow *window = [self window];
NSRect frame = [window frame];
frame.origin.x = 0;
[window setFrame:frame display:NO];
```

**Wrong:**
```objc-c
NSRect frame = [[self window] frame];
frame.origin.x = 0;
[[self window] setFrame:frame display:NO];
objectAtIndex is gone - keep it like this
```

**Right:**
```obj-c
NSArray *array;
…filled with lots of stuff
id object = array[index];
```

**Wrong:**
```objc-c
NSArray *array;
…filled with lots of stuff
id object = [array objectAtIndex:index];
NSArray literals improve readability - use them
```

**Right:**
```obj-c
NSArray *array = @[obj1, obj2, obj3];
```

**Wrong:**
```objc-c
NSArray *array = [NSArray arrayWithObjects: obj1, obj2, obj3, nil];
```

## Commit naming

Commit titles should follow a certain template in order to keep a better track of them.

A commit message can be added if needed to explain the purpose of the commit and give more context.

This is how you should title your commits:

```
filename: Brief description

or

subject: Brief description
```

Example: Some changes were made to the UPnP integration in order to drop the obsolete iOS 7 support in the VLCNetworkServerBrowserUPnP.m file.

**Right:**
```
VLCNetworkServerBrowserUPnP: Remove iOS 7 compatibility code

or

UPnP: Remove iOS 7 compatibility code
```

**Wrong:**
```
Remove iOS 7 compatibility code => Lack of context

VLCNetworkServer: Remove iOS 7 compatibility code => Incomplete file name

VLCNetworkServerBrowserUPnP.m: Remove iOS 7 compatibility code => Useless file extension
```
