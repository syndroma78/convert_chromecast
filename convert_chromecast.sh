#! /bin/sh

# Batch Convert Script by StevenTrux
# The Purpose of this Script is to batch convert any video file to mp4 or mkv format for chromecast compatibility
# this script only convert necessary tracks if the video is already
# in H.264 format it won't convert it saving your time!

# Put all video files need to be converted in a folder!
# the name of files must not have " " Space!
# Rename the File if contain space

# Variable used:
# outmode should be mp4 or mkv
# sourcedir is the directory where to be converted videos are
# indir is the directory where converted video will be created

# usage:
#########################
# cast.sh mp4 /home/user/divx /home/user/chromecastvideos
# or
# cast.sh mkv /home/user/divx /home/user/chromecastvideos
#########################

# working mode
outmode=$1
# check output mode
if [[ $outmode ]]; then
if [ $outmode = "mp4" ] || [ $outmode = "mkv" ]
	then
	echo "WORKING MODE $outmode"
	else
	echo "$outmode is NOT a Correct target format. You need to set an output format! like cast.sh mp4 xxxx or cast.sh mkv xxxx"
	exit
fi
else
echo "Working mode is missing. You should set a correct target format like mp4 or mkv"
exit
fi

# Source dir
sourcedir=$2
if [[ $sourcedir ]]; then
     echo "Using $sourcedir as Input Folder"
	else
	 echo "Error: Check if you have set an input folder"
	 exit
fi

# Target dir
indir=$3
if [[ $indir ]]; then
if mkdir -p $indir/castable
	then
	 echo "Using $indir/castable as Output Folder"
	else
	 echo "Error: Check if you have the rights to write in $indir"
	 exit
fi
	else
	 echo "Error: Check if you have set an output folder"
	 exit
fi

# set format
if [ $outmode=mp4 ]
	then
	 outformat=mp4
	else
	 outformat=matroska
fi

# Check FFMPEG Installation
if ffmpeg -formats > /dev/null 2>&1
	then
	 ffversion=`ffmpeg -version 2> /dev/null | grep ffmpeg | sed -n 's/ffmpeg\s//p'`
	 echo "Your ffmpeg verson is $ffversion"
	else
	 echo "ERROR: You need ffmpeg installed with x264 and libfdk_aac encoder"
	 exit
fi

if ffmpeg -formats 2> /dev/null | grep "E mp4" > /dev/null
	then
	 echo "Check mp4 container format ... OK"
	else
	 echo "Check mp4 container format ... NOK"
	 exit
fi

if ffmpeg -formats 2> /dev/null | grep "E matroska" > /dev/null
        then
         echo "Check mkv container format ... OK"
        else
         echo "Check mkv container format ... NOK"
         exit
fi

#if ffmpeg -codecs 2> /dev/null | grep "libfdk_aac" > /dev/null
#        then
#         echo "Check AAC Audio Encoder ... OK"
#        else
#         echo "Check AAC Audio Encoder ... NOK"
#         exit
fi

if ffmpeg -codecs 2> /dev/null | grep "libx264" > /dev/null
        then
         echo "Check x264 the free H.264 Video Encoder ... OK"
        else
         echo "Check x264 the free H.264 Video Encoder ... NOK"
         exit
fi

echo "Your FFMpeg is OK Entering File Processing"

################################################################
cd "$sourcedir"
for filelist in `ls`
do
	if ffmpeg -i $filelist 2>&1 | grep 'Invalid data found'		#check if it's video file
	   then
	   echo "ERROR File $filelist is NOT A VIDEO FILE can be converted!"
	   continue

	fi

	if ffmpeg -i $filelist 2>&1 | grep Video: | grep h264		#check video codec
	   then
	    vcodec=copy
	   else
	    vcodec=libx264
	fi

	if ffmpeg -i $filelist 2>&1 | grep Video: | grep "High 10"	#10 bit H.264 can't be played by Hardware.
	   then
	    vcodec=libx264
	fi

	#if [ ffmpeg -i $filelist 2>&1 | grep Audio: | grep aac ] || [ 	ffmpeg -i $filelist 2>&1 | grep Audio: | grep mp3 ]	#check audio codec
	#   then
	#    acodec=copy
	#   else
	#    acodec=libfdk_aac
	#fi

	echo "Converting $filelist"
	echo "Video codec: $vcodec Audio codec: $acodec Container: $outformat"

  echo "#######################################################################"
	echo "ffmpeg -i $filelist -c:v libx264 -profile:v high -level 4.2 -crf 18 -maxrate 10M -bufsize 16M -pix_fmt yuv420p -vf "scale=iw*sar:ih, scale='if(gt(iw,ih),min(1920,iw),-1)':'if(gt(iw,ih),-1,min(1080,ih))'" -x264opts bframes=3:cabac=1 -movflags faststart -c:a libfaac -b:a 320k -ac 2 -y $indir/castable/$filelist.$outmode"
	echo "#######################################################################"

# using ffmpeg for real converting
	#echo "ffmpeg -i $filelist -y -f $outformat -acodec $acodec -ab 192k -ac 2 -absf aac_adtstoasc -async 1 -vcodec $vcodec -vsync 0 -profile:v main -level 3.1 -qmax 22 -qmin 20 -x264opts no-cabac:ref=2 -threads 0 $indir/castable/$filelist.$outmode"
	#ffmpeg -i $filelist -y -f $outformat -acodec $acodec -ab 192k -ac 2 -absf aac_adtstoasc -async 1 -vcodec $vcodec -vsync 0 -profile:v main -level 3.1 -qmax 22 -qmin 20 -x264opts no-cabac:ref=2 -threads 0 $indir/castable/$filelist.$outmode

	ffmpeg -i $filelist -c:v libx264 -profile:v high -level 4.2 -crf 18 -maxrate 10M -bufsize 16M -pix_fmt yuv420p -vf "scale=iw*sar:ih, scale='if(gt(iw,ih),min(1920,iw),-1)':'if(gt(iw,ih),-1,min(1080,ih))'" -x264opts bframes=3:cabac=1 -movflags faststart -c:a libfaac -b:a 320k -ac 2 -y $indir/castable/$filelist.$outmode

done
	echo ALL Processed!

###################
echo "DONE, your video files are chromecast ready"
exit
