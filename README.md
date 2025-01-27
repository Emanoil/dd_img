#![Visitor Badge](https://visitor-badge.glitch.me/badge?page_id=Emanoil.dd_img)
![Profile views](https://komarev.com/ghpvc/?username=Emanoil&repo=dd_img)
# dd_img
Like Clonezilla, takes and restores a partition or hard disk backup. All code easy to see.

<h1>Importat warning</h1>
<p style="font-size:18px;">This program can destroy data on your computer, if misused (i.e. wrong commands).</p>
So, please do not use if you don't understand well the commands that it takes. I take no responsibility for any data loss on your computer.

Here is the **big picture**: this is a Linux program, so it can only be used in a Linux terminal, with "*root*" privileges. You can save (operation "*read*") an image of a partition (e.g. "*/dev/sda20*") or even a whole hard disk (e.g. "*dev/sdb*"). Will be saved with many checksums. Can be restored (operation "*write*") on same or other computer. Can also be just verified (that checksums are OK; operation "*verify*"). Restoration (operation "*write*") is the dangerous part, so please, carefully check the displayed paramaters, an only type "yes" if you are sure the parameters are OK. (Note: for a test, can use an ordinary file (e.g. "*tests/a_test_file*"), instead of a device (e.g. "*/dev/sdb30*"). This is safe.)  

Please use **no spaces** in file names and paths.  

Remember to:
a). shrink a bit the target partition, before geeting its image, in order to be sure it will fit back when restoring it.
b. If restoring onto a partition of a different type than the backup, then need to use Linux's `fdisk' to set the "partition type" ("t" command).

WARNING: When running this Bash script, one should be in a directory on an ext4 partition (ntfs might also work - not sure, but Samba share (== cifs) and FAT32 are known not to work). This is because the filesystem of the partition where we are in, needs to support "named pipes". This should be no problem, as the filenames can be referred with full path. (One more warning: should make sure that the full path used, contains no spaces.)

**Examples**:  
*./dd_img.sh* or *./dd_img.sh --help* , for help  
*./dd_img.sh --what read --device /dev/sda11.7z --file1 dd_test1/test_bak1 -f2 dd_test2/tst_bak2*  
*./dd_img.sh -w verify -f1 dd_test1/test_bak1*  
*./dd_img.sh -w write -d /dev/sda20 -f1 dd_test2/tst_bak2*  

"*--file2*" and "*--file3*", are only used for "*read*" operation  
"*verify*" operation uses no "*--device*"  

For testing (or other purposes, maybe), one can use a file name (even with path) with "--device".
