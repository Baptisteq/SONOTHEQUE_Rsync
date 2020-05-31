#!/bin/bash

if [ $FUTUREDIRASIZE != $FUTUREDIRBSIZE ]; then
  echo "
After rsync operations both DIRA $FUTUREDIRASIZEGB GiB ($FUTUREDIRASIZEMB MiB) and DIRB $FUTUREDIRBSIZEGB GiB ($FUTUREDIRBSIZEMB MiB) do not share the same size"  
# ----list all files sharing the same file name on both dir in an array
  # list all files from DIRA (LOF=ListOfFiles)
  LOFDIRA=$(find $DIRA -type f | sed "s|$DIRA||")
  # list all files from DIRB (LOF=ListOfFiles)
  LOFDIRB=$(find $DIRB -type f | sed "s|$DIRB||")
  # List of all files sharing the same filename
  touch LOFDIRA.txt
  echo "$LOFDIRA" >>LOFDIRA.txt
  touch LOFDIRB.txt
  echo "$LOFDIRB" >>LOFDIRB.txt
  LOFSHAREFILENAME=$(comm -12 LOFDIRA.txt LOFDIRB.txt)
  rm LOFDIRA.txt
  rm LOFDIRB.txt
  # For each Filename
  IFS=$'\n'
  touch FILEISSUES.txt
  for SHAREFILENAME in ${LOFSHAREFILENAME[@]}
    do
    # search DIRA path of the specific filename and get its size value
    AFILESIZE=$(stat -c%s "$DIRA/$SHAREFILENAME")
    # search DIRB path of the specific filename and get its size value
    BFILESIZE=$(stat -c%s "$DIRA/$SHAREFILENAME")
    # Does DIRA specific file and DIRB specific file share the same size ? NO ?: write in a log so these files need to be manually checked
    [ $AFILESIZE -eq $BFILESIZE ] || echo "filename both present on dirA and dirB: $SHAREFILENAME doesn't share the same file size (A: $AFILESIZE bytes B: $BFILESIZE bytes)" >>FILEISSUES.txt 
    done
  IFS=$OLDIFS
fi

