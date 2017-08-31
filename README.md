DESCRIPTION

A bash one-liner to help find overwritten file on the disk.

EXPLANATION

You can still find a previous (or even current) version somewhere on the disk if you are lucky.
Should work even if the file was deleted unless you deleted containing directory.
Not tested. You may try this or undelete if the filesystem supports such operation.
No guarantee, of course. It depends on a number of conditions.

MODIFYING RECOVERY PARAMETERS

You can set few environmental variables (upper case) to change the default behavior.
Take a look at the script file. Explanation is there.
- You have to know part of the CONTENTS, preferably the header of the file.
- Adjust RBS (read block size) to fit a whole file in or use dd to retrieve the contents later.
- Try specifying FILE as /{mount_point}/{original_filename} if you removed the containing directories.
- Discovered blocks are saved to the directory specified in DUMPFS so setting DUMPFS to the same device you are searching through is really stupid and may create loops.
Mount a tmpfs somewhere if you have no other permanent device and copy files later.

BEST PRACTICES

- If you do some stupid thing, remount your filesystem readonly. Immediately.
- Then (export variables and) execute the one-liner.
- *BACKUP YOUR IMPORTANT FILES BEFORE DOING STUPID THINGS!* LOL :)

DEPENDENCIES (Ubuntu packages as reference)

- bash (bash)
- findmnt (mount)
- stat (coreutils)
- blockdev (util-linux)
- dd (coreutils)
- grep (grep)

It may or may not work with busybox, not tested.

CONCLUSION

Worked for me after mistyping > as in the first example and while /etc (rootfs) was on SSD without TRIM enabled.

LIMITATIONS

- The tool is designed as a one-liner so you don't need to create any files on your drive.
  If you create one after you've overwritten your file you may be overwriting the data you are search for in the blocks.
- Whole matching blocks are saved. You need to truncate/correct the contents manually.
- Read permission on a whole block device and write permission on DUMPFS are needed for user who runs this tool.
- Please note that FDE (i.e. LUKS) DOES NOT block you from finding your content as long as the filesystem is mounted.
  File level encryption like EncryptFS DOES.
- CONTENTS may contain any characters except NULL (\x00).
  So NO - you cannot search for UTF16 text documents, unless you modify the grep command.
- Too short CONTENTS will match too many blocks
- If the device is a partition or logical volume, the search won't start until it reaches the physical end of device.
  Press Ctrl-C if you are running over 100%.

EXAMPLES

[1]
You accidentally run echo "something" > /etc/fstab instead of echo "something" >> /etc/fstab.
Well you can use /proc/mounts or /etc/mtab but it may contain mounts you don't need to have in fstab.
Or the nice UUID becomes /dev/sdXY. Or anything else.

[2]
You can use it for different files:
  - CONTENTS='#!/bin/bash' or CONTENTS='#!/usr/bin/env bash' may find you your overwritten bash script (note the header)
  - CONTENTS='%PDF-' can find you "over-printed" PDFs
  - CONTENTS='JFIF' or CONTENTS='Exif' may find your deleted holiday photos.
  - CONTENTS=$'\x89PNG' can find your deleted PNG images
and so on.

[3]
You find what you were looking for but it's truncated and/or CONTENTS was not the header so you need data before it.
During recovery the "Device XXXX Block ... " message appears.
Findings are saved with names like "dumpNNN_YYYY"
- If you need data before CONTENTS, decrease YYYY by 1 or more now.
- By default only 1 block is saved. If you need data after CONTENTS, increase NUMBER_OF_BLOCKS.
- If you didn't change the RBS it should default to 4096
- Use following command and adjust values accordingly:
  dd if=XXXX of=YOUR_OUTPUT_FILENAME bs=RBS skip=YYYY count=NUMBER_OF_BLOCKS iflag=direct
  Replace uppercase parameters with your values.

