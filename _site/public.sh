#!/bin/bash
INPUT=$PWD
OUTPUT=$PWD/../cndaqiang
echo "Copy blog from  $INPUT"
echo "Copy blog to    $OUTPUT"

echo "Copy [y/n]?"
read mount
mount=${mount}_
if [ $mount == y_ ]
then
	echo "Starting...."
else
    exit
fi

if [ -d $OUTPUT ]
then
    for i in $( ls  $OUTPUT )
    do
        echo "rm -rf $OUTPUT/$i"
        rm -rf $OUTPUT/$i
    done
else
    echo "$OUTPUT not exits"
    exit
fi

if [ -d $INPUT ]
then
    for i in $( ls  $INPUT | grep -v _posts | grep -v public.sh | grep -v public.txt )
    do
        echo "cp -r $INPUT/$i $OUTPUT/$i"
        cp -r $INPUT/$i $OUTPUT/$i
    done
    mkdir $OUTPUT/_posts
    for i in $( cat $INPUT/public.txt | grep -v \# )
    do
        echo "cp $INPUT/_posts/$i $OUTPUT/_posts/$i"
        cp $INPUT/_posts/$i $OUTPUT/_posts/$i
    done
else
    echo "$INPUT not exits"
    exit
fi

cp $INPUT/.gitignore $OUTPUT/.gitignore
touch public.* $OUTPUT/.gitignore
