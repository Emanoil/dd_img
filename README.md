Remember to:
a). shrink a bit the target partition, before geeting its image, in order to be sure it will fit back when restoring it.
b. If restoring onto a partition of a different type than the backup, then need to use Linux's `fdisk' to set the "partition type" ("t" command).

WARNING: When running this Bash script, one should be in a directory on an ext4 partition (ntfs might also work - not sure, but Samba share (== cifs) and FAT32 are known not to work). This is because the filesystem of the partition where we are in, needs to support "named pipes". This should be no problem, as the filenames can be referred with full path. (One more warning: should make sure that the full path used, contains no spaces.)

Examples (commands quoted with ` and '):
`./dd_img.sh' or `./dd_img.sh --help' , for help
`./dd_img.sh --what read --device /dev/sda11.7z --file1 dd_test1/test_bak1 -f2 dd_test2/tst_bak2'
`./dd_img.sh -w verify -f1 dd_test1/test_bak1'
`./dd_img.sh -w write -d /dev/sda20 -f1 dd_test2/tst_bak2'

"--file2" and "--file3", are only used for "read" operation
"verify" operation uses no "--device"

For testing (or other purposes, maybe), one can use a file name (even with path) with "--device".
