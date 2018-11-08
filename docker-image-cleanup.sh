#!/bin/bash

# janek.idzie@gmail.com
# 02/2018

# a simple script to cleanup docker images
# but keeping a declared number of tags

# declaring variable
KEEP_IMAGES=$1

# checking if argument is numeric
# https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash
re='^[0-9]+$'

if ! [[ $# == 1 ]] || ! [[ $KEEP_IMAGES =~ $re ]]
  then
    echo "This scripts takes only 1 numeric argument"
    echo "Please provide number of tags to keep..."
    exit 1
fi

# running the cleanup using docker commands
# keeping declared number of image tags
echo "Preparing images list..."
IMAGES=`docker images --format '{{.Repository}}' | sort | uniq`
echo "List of images found:"
echo "$IMAGES"

for i in $IMAGES
  do
    echo "Counting number of $i images:"
    IMAGE_TAG=`docker images --format '{{.Repository}}:{{.Tag}}' $i`
    IMAGES_COUNT=`echo "$IMAGE_TAG" | wc -l`
    if [ $IMAGES_COUNT -gt $KEEP_IMAGES ] ; then
      echo $i: $IMAGES_COUNT images found. Keeping last $KEEP_IMAGES images only.
      REMOVAL_COUNT=`expr $IMAGES_COUNT - $KEEP_IMAGES`
      RMI_LIST=`echo "$IMAGE_TAG" | tail -$REMOVAL_COUNT`
      for i in $RMI_LIST
        do
          docker rmi $i
      done
    else
      echo $i: $IMAGES_COUNT images found. We keep $KEEP_IMAGES so not removing anything.
    fi
done
