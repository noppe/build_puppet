#!/bin/bash
#
# Check syntax of perl files
#
for i in $(find bin/ -type f -name \*.pl); do
  perl -c $i
  if [ $? -ne 0 ]; then
    echo -e "\n\nFailure detected in ${i}. Stopped checking any other files. Fix and run this script again."
    exit 1
  fi
done
exit 0
