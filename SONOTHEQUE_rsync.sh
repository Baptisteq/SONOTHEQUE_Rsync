#!/bin/bash
# set -x
OLDIFS=$IFS
# usage: at initiating, rsync will add all new files from dirB to dirA (where files are non-existing yet). 
# Then rsync will add all new files from dirA to dirB (where files are non-existing yet) 

Usage(){
local ISSUE=$1
echo "$0
copy all new files from DIRB to DIRA, then copy all new files from DIRA to DIRB
ISSUE: $ISSUE"
exit
}
#Define DIRA & DIRB locations
DIRA=/cygdrive/d/SONOTHEQUE/
DIRB=/cygdrive/k/SONOTHEQUE/

#Validate DIRA & DIRB
[ -d $DIRA ] || usage "$DIRA is not a valid dir"
[ -d $DIRB ] || usage "$DIRB is not a valid dir"

#-----Estimate future size of DIRA
echo "Transfer DIRB:$DIRB to DIRA:$DIRA (only all non-existing files)"
# list of files that will be transfered from DIRA to DIRB
rsync -avP --ignore-existing --dry-run "$DIRB" "$DIRA"

# Transfered files' size
TRANSFERSIZEBA=$(rsync -avP --ignore-existing --dry-run --stats "$DIRB" "$DIRA" | grep "Total transferred file size:" | sed "s/[^0-9]//g")
echo "Transfer file size from DIRB to DIRA:$TRANSFERSIZEBA bytes."
# actual DIRA size
DIRASIZE=$(du -h -B1 --max-depth=0 $DIRA | sed "s/[^0-9]//g")
echo "DIRA ($DIRA) size:$DIRASIZE"
# Estimated future DIRA size
((FUTUREDIRASIZE=DIRASIZE+TRANSFERSIZEBA))
FUTUREDIRASIZEGB=$(echo "scale=2; $FUTUREDIRASIZE/1024/1024/1024" | bc -l)
FUTUREDIRASIZEMB=$(echo "scale=2; $FUTUREDIRASIZE/1024/1024" | bc -l)
echo "Future dirA:$DIRA size will be:$FUTUREDIRASIZEGB GiB ($FUTUREDIRASIZEMB MiB)."

#-----Estimate future size of DIRB
# list of files that will be transfered from DIRA to DIRB
rsync -avP --ignore-existing --dry-run "$DIRA" "$DIRB"
echo "
Transfer DIRA:$DIRA to DIRB:$DIRB (only all non-existing files)"
# Transfered files' size
TRANSFERSIZEAB=$(rsync -avP --ignore-existing --dry-run --stats "$DIRA" "$DIRB" | grep "Total transferred file size:" | sed "s/[^0-9]//g")
echo "Transfer file size from DIRA to DIRB:$TRANSFERSIZEAB bytes."
# actual DIRB size
DIRBSIZE=$(du -h -B1 --max-depth=0 $DIRB | sed "s/[^0-9]//g")
echo "DIRB ($DIRB) size:$DIRBSIZE"
# Estimated future DIRA size
((FUTUREDIRBSIZE=DIRBSIZE+TRANSFERSIZEAB))
FUTUREDIRBSIZEGB=$(echo "scale=2; $FUTUREDIRBSIZE/1024/1024/1024" | bc -l)
FUTUREDIRBSIZEMB=$(echo "scale=2; $FUTUREDIRBSIZE/1024/1024" | bc -l)

echo "Future dirB:$DIRB size would be:$FUTUREDIRBSIZEGB GiB ($FUTUREDIRBSIZEMB MiB)."
echo "

Both dirA($DIRA) and dirB($DIRB) will share these final sizes:
$DIRA -- $FUTUREDIRASIZEGB GiB ($FUTUREDIRASIZEMB MiB).
$DIRB -- $FUTUREDIRBSIZEGB GiB ($FUTUREDIRBSIZEMB MiB). 
Do you want to proceed [y/n]
"

read USERANSWER

if [[ $USERANSWER == "y" ]]; then 
  # Add all files from DIRB that does not already exists in DIRA
  rsync -avP --ignore-existing  "$DIRB" "$DIRA"
  # Add all files from DIRA that does not already exists in DIRB
  rsync -avP --ignore-existing "$DIRA" "$DIRB"
  elif [[ $USERANSWER == "n" ]]; then
  echo "Process aborted"
  exit
  else	
  echo "Process aborted"
  exit
fi
exit

# rsync DIRA/* DIRB/
# copy all content from DIRA to DIRB (do not include subdir from DIRA).

# rsync -r DIRA/* DIRB/
# copy all content from DIRA to DIRB (including all recusrives subdir).

# rsync -rv --dry-run -v DIRA/* DIRB/
# Launch simulation. copy all content from DIRA to DIRB (including all recusrives subdir). Verbose stdout

# rsync --delete DIRA/ DIRB/
# synch entirely DIRA's contents to DIRB (Meaning that if DIRB has contents that aren't presebt in DIRA there will be delted).

# -a (archiving purpose is concatening all these arg: -rlptgoD)

    # -r: recursive
    # -l: copy symlinks as files, not the file to which they point.  Why do you want this? It prevents your rsync job from looping back to a directory above itself, causing an infinite loop, in the case there are a few unruly symlinks in your filesystem tree.
    # -p: preserve permissions
    # -t: preserve modification timestamps
    # -g: preserve group ownership. rsync is smart enough to change the group ID by name, rather than numerical group ID on the destination.
    # -o: preserve ownership. Same behavior applies to user ID by name, rather than numerical ID.
    # -D: preserve special files. Such as device files, named pipes, etc.
