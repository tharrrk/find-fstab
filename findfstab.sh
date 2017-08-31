#!/bin/bash

# You can customize your search by setting these variables:
#
# FILE       - original filename; used to determine a disk drive where to look for the contents
# CONTENTS   - part of contents you remember; works best if it's a beginning of the file
# RBS        - read block size; affects speed
# DUMPFS     - where to save blocks found; SHOULD NEVER BE THE SAME DEVICE AS SEARCHED ONE
# START      - starting block number

: ${FILE:='/etc/fstab'} ${CONTENTS:='# /etc/fstab: static file system information'} ${RBS:=4096} ${DUMPFS:='/dev/shm'};[ ! -d "${DUMPFS}" -o ! -w "${DUMPFS}" ]&&echo "ERROR: ${DUMPFS} must be a writable directory.">&2&&exit 3;I=$((START));M="$(stat -c%m "${FILE}" 2>/dev/null||stat -c%m "${FILE%/*}")";[ -z "${M}" ]&&exit 1;D="$(findmnt -n -oSOURCE "${M}")";[ ! -b "${D}" ]&&echo "ERROR: ${D} is not a local block device" >&2&&exit 7;[ "$(findmnt -n -oSOURCE `stat -c%m "${DUMPFS}"`)" = "${D}" ]&&{ TRR="";read -p"WARNING: DUMPFS seems to be the same device as search target! Type 'I know what I am doing' and press Enter if you want to proceed anyway: " TRR;[ "${TRR}" = "I know what I am doing" ]||exit 4;};PBC="$(blockdev --getsize64 "${D}")";RBN=$((PBC/RBS));H=0;RC=0;while [ ${RC} -eq 0 ];do { dd if="${D}" bs=${RBS} skip=${I} iflag=direct count=1 2>/dev/null; RC=$?; }|grep -Fq "${CONTENTS}"&&dd if="${D}" bs=${RBS} skip=${I} iflag=direct count=1 of="${DUMPFS}/dump$((H++))_block${I}" 2>/dev/null;echo -en "Device ${D} Block ${I}/${RBN} ($((I++*100/RBN))%), found ${H}\r";done
