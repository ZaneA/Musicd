#!/bin/bash
FILENAME="$1"
ARTIST="$2"
TITLE="$3"

if [ -n "$ARTIST" ]
then
	echo "$ARTIST - $TITLE" > ${HOME}/.musicd/current
else
	echo "$FILENAME" > ${HOME}/.musicd/current
fi

# Album ART!
PATHNAME=`grep "${FILENAME:0:${#FILENAME}-1}" ${HOME}/.musicd/playlist`

if [ -n "$PATHNAME" ]
then
	FOLDERNAME=`dirname "$PATHNAME"`
	IMAGENAME=`find "$FOLDERNAME" -maxdepth 1 -type f -print | grep -E '.png|.jpg|.jpeg' | head -n1`
fi

if [ -n "$IMAGENAME" ]
then
	ln -f -s "$IMAGENAME" ${HOME}/.musicd/albumart
else
	ln -f -s ${HOME}/.musicd/none.png ${HOME}/.musicd/albumart
fi

notify-send -i ${HOME}/.musicd/albumart "Musicd" "$(cat ${HOME}/.musicd/current)" &
#sawfish-client -q -c "(rename-window-func (get-window-by-name \"MPlayer\") \"$(cat ${HOME}/.musicd/current)\")" &
