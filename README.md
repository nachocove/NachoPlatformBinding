If you want to bring in some ObjC, but you don't want to go through the hassle of creating an independent Xamarin Binding Project, this is your Ticket.

Just add the ObjC code to the embedded XCode project. Make sure you reference it in the external open-source repo if it is OS, rather than copying it in. True Nacho ObjC can be commited here.

# Notes on SQLite integration
Here is a description of what is done currently to get from SQLite source to the nc_sqlite.c file in this repo. This will likely change as SQLite changes, and as OSes change.

1. Download the amalgamation: https://www.sqlite.org/amalgamation.html, https://www.sqlite.org/download.html
2. Ungzip, untar, and find the sqlite.c file.
3. Add the prefix to all exported symbols. For now, this works:
```
sed 's/sqlite3_/nc_sqlite3_/g' sqlite3.c > nc_sqlite3.c
```
4. Uncover the compile options used by the OS's version of SQLite. In theory, this is only needed once - because this SQLite is exclusive to our platform-independent code. For iOS, the options we have been running with are:
ENABLE_FTS3
ENABLE_FTS3_PARENTHESIS
ENABLE_LOCKING_STYLE=1
ENABLE_RTREE
MAX_MMAP_SIZE=0
OMIT_AUTORESET
OMIT_BUILTIN_TEST
OMIT_LOAD_EXTENSION
SYSTEM_MALLOC
THREADSAFE=2
5. Add a section of #define at the top of nc_sqlite3.c to reflect the chosen options. We kept all of these except we enabled FTS4. We add OMIT_COMPILEOPTION_DIAGS because of a compile issue. locking style, system malloc and mmap size are set automatically - don't mess with them.
6. Fix any platform issues. In this version there is a reference to gethostuuid() that needed to be eliminated.

