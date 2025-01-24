#!/bin/bash
#Remember to a). shrink a bit the target partition, before geeting its image, in order to be sure it will fit back when restoring it. b). If restoring onto a partition of a different type than the backup, then need to use Linux's `fdisk' to set the "partition type" ("t" command).

#WARNING: When running this Bash script, one should be in a directory on an ext4 partition (ntfs might also work - not sure, but Samba share (== cifs) and FAT32 are known not to work). This is because the filesystem of the partition where we are in, needs to support "named pipes". This should be no problem, as the filenames can be referred with full path. (One more warning: should make sure that the full path used, contains no spaces.)

#Examples (commands quoted with ` and '):
#`./dd_img.sh' or `./dd_img.sh --help' , for help
#`./dd_img.sh --what read --device /dev/sda11.7z --file1 dd_test1/test_bak1 -f2 dd_test2/tst_bak2'
#`./dd_img.sh -w verify -f1 dd_test1/test_bak1'
#`./dd_img.sh -w write -d /dev/sda20 -f1 dd_test2/tst_bak2'

#"--file2" and "--file3", are only used for "read" operation
#"verify" operation uses no "--device"
#for testing (or other purposes, maybe), one can use a file name (even with path) with "--device"

declare -A Params #associative array

function writeBackup {
#"$1" is the named pipe's name; "$2" is the save-file name
#  cat "$1"|tee >(md5sum --binary > "$2".dd.md5) >(sha1sum --binary > "$2".dd.sha1) >(sha256sum --binary > "$2".dd.sha256) |bzip2 -9|tee >(md5sum --binary > "$2".dd.compressed.md5) >(sha1sum --binary > "$2".dd.compressed.sha1) >(sha256sum --binary > "$2".dd.compressed.sha256) |cat > "$2".dd.bz2
  cat "$1"|tee >(md5sum --binary > "$2".dd.md5) >(sha1sum --binary > "$2".dd.sha1) >(sha256sum --binary > "$2".dd.sha256) |gzip -1|tee >(md5sum --binary > "$2".dd.compressed.md5) >(sha1sum --binary > "$2".dd.compressed.sha1) >(sha256sum --binary > "$2".dd.compressed.sha256) |cat > "$2".dd.gz
}

getArguments () {
  declare -A States #associative array

  States[--device]="device"
  States[-d]="device"
  States[--file1]="file1"
  States[-f1]="file1"
  States[--file2]="file2"
  States[-f2]="file2"
  States[--file3]="file3"
  States[-f3]="file3"
  States[--what]="what" #what to do (read, write or verify)
  States[-w]="what"
  States[--count]="count"
  States[-c]="count"
  States[--block]="block" #block size
  States[-b]="block"

  state="looking"
  for arg in "$@"
  do
    case "$state" in

    "looking")
      for keyWord in  "${!States[@]}" #all key strings
      do
        if [ "$arg" == "$keyWord" ]; then
          state="${States[$keyWord]}"
          break
        fi
      done
      if [ "$state" == "looking" ]; then
        echo "Ununderstood argument \"" "$arg" "\"! Exiting."
        #break
        exit
      fi
      ;;

    *)  #read a value
      Params[$state]="$arg"
      state="looking"
      ;;

    esac
  done
}

if [ "$#" -eq "0" -o "$1" == "-h" -o "$1" == "--help" ]; then
  echo "Arguments: \`--what' or \`-w' for what to do: \"read\", \"write\" or \"verify\"; \`--device' or \`-d' for device (e.g. \"/dev/sdb2\"); \`--file1' or \`-f1' for file (e.g. \"Win7_last_year\" - don't include spaces in filename); same way \`--file2' or \`-f2' and \`--file3' or \`-f3'; \`--block' or \`-b' (e.g. \"512\") for block size; \`--count' or \`-c' for block count (e.g. \"102132\")"
else  #acceptable number of arguments (at least so far - further checks may be performed)
  getArguments "$@"

  if [ -z ${Params["block"]} ]; then
    Params[block]="1M" #probably optimal for flash memory (speed and wearing)
  fi

  if [ -z ${Params["count"]} ]; then
    Params[count]="2147483647" #probably optimal for flash memory (speed and wearing)
  fi

  for param in "${!Params[@]}" #all parameter names
  do
    echo "Param["\""$param"\""] == " ${Params[$param]}
  done

  #echo "Param[file] == " ${Params["file"]}

  if [ ${Params["what"]} = "write" ] ; then
    read -p "Ready to write partition \""${Params["device"]}"\" from file \""${Params["file1"]}"\"? Please answer \"yes\", if so: " yesNo
    if [ "$yesNo" = "yes" ]
    then
      echo "Proceeding ..."
#the following command, writes a partition from a file
#      time nice -15 cat "$3".dd.bz2|tee >(md5sum --binary > "$3".dd.bz2.md5) >(sha1sum --binary > "$3".dd.bz2.sha1) >(sha256sum --binary > "$3".dd.bz2.sha256) |bzip2 -dc|tee >(md5sum --binary > "$3".dd.restored.md5) >(sha1sum --binary > "$3".dd.restored.sha1) >(sha256sum --binary > "$3".dd.restored.sha256) |dd of="$2"
      time nice -15 cat ${Params["file1"]}.dd.gz|tee >(md5sum --binary > ${Params["file1"]}.dd.gz.md5) >(sha1sum --binary > ${Params["file1"]}.dd.gz.sha1) >(sha256sum --binary > ${Params["file1"]}.dd.gz.sha256) |gzip -d|tee >(md5sum --binary > ${Params["file1"]}.dd.restored.md5) >(sha1sum --binary > ${Params["file1"]}.dd.restored.sha1) >(sha256sum --binary > ${Params["file1"]}.dd.restored.sha256) |dd iflag=fullblock bs=${Params["block"]} count=${Params["count"]} of=${Params["device"]}
      diff -s ${Params["file1"]}.dd.md5 ${Params["file1"]}.dd.restored.md5
      diff -s ${Params["file1"]}.dd.sha1 ${Params["file1"]}.dd.restored.sha1
      diff -s ${Params["file1"]}.dd.sha256 ${Params["file1"]}.dd.restored.sha256
      diff -s ${Params["file1"]}.dd.compressed.md5 ${Params["file1"]}.dd.gz.md5
      diff -s ${Params["file1"]}.dd.compressed.sha1 ${Params["file1"]}.dd.gz.sha1
      diff -s ${Params["file1"]}.dd.compressed.sha256 ${Params["file1"]}.dd.gz.sha256
    else
      echo "Aborting (since not answered \"yes\")."
    fi
  elif [ ${Params["what"]} = "verify" ] ; then #only verification
    time nice -15 cat ${Params["file1"]}.dd.gz|tee >(md5sum --binary > ${Params["file1"]}.dd.gz.md5) >(sha1sum --binary > ${Params["file1"]}.dd.gz.sha1) >(sha256sum --binary > ${Params["file1"]}.dd.gz.sha256) |gzip -d|tee >(md5sum --binary > ${Params["file1"]}.dd.restored.md5) >(sha1sum --binary > ${Params["file1"]}.dd.restored.sha1) |sha256sum --binary > ${Params["file1"]}.dd.restored.sha256
    diff -s ${Params["file1"]}.dd.md5 ${Params["file1"]}.dd.restored.md5
    diff -s ${Params["file1"]}.dd.sha1 ${Params["file1"]}.dd.restored.sha1
    diff -s ${Params["file1"]}.dd.sha256 ${Params["file1"]}.dd.restored.sha256
    diff -s ${Params["file1"]}.dd.compressed.md5 ${Params["file1"]}.dd.gz.md5
    diff -s ${Params["file1"]}.dd.compressed.sha1 ${Params["file1"]}.dd.gz.sha1
    diff -s ${Params["file1"]}.dd.compressed.sha256 ${Params["file1"]}.dd.gz.sha256
  elif [ ${Params["what"]} = "read" ] ; then #read
    echo "Reading partition \""${Params["device"]}"\", to file \""${Params["file1"]}"\" ..."

    fifo3=''
    fifo2=''

    if [ ! -z ${Params["file3"]} ] ; then
      fifo3=$(basename ${Params["file3"]})a
      mkfifo "$fifo3"
      writeBackup "$fifo3" ${Params["file3"]} &
    fi

    if [ ! -z ${Params["file2"]} ] ; then
      fifo2=$(basename ${Params["file2"]})b
      mkfifo "$fifo2"
      writeBackup "$fifo2" ${Params["file2"]} &
    fi

    if [ ! -z ${Params["file1"]} ] ; then
      fifo1=$(basename ${Params["file1"]})c
      mkfifo "$fifo1"
      writeBackup "$fifo1" ${Params["file1"]} &
      time nice -15 dd iflag=fullblock bs=${Params["block"]} count=${Params["count"]} if=${Params["device"]}|tee "$fifo3" "$fifo2" >"$fifo1"
    fi

    if [ ! -z ${Params["file3"]} ] ; then
      rm "$fifo3"
    fi

    if [ ! -z ${Params["file2"]} ] ; then
      rm "$fifo2"
    fi

    if [ ! -z ${Params["file1"]} ] ; then
      rm "$fifo1"
    fi

  fi
fi
