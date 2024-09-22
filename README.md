# Bootin

Bootin is a tool to prepare Magisk modules that contains Android boot animations.


# Usage


Just run the script hehe (make sure you have `ffmpeg` and `zip` installed beforehand!). Read below only if you are interested in script.


```bash
chmod +x bootin.sh  
./bootin.sh
```


You need to put the media file that you want to create animation from to project folder.

Some devices do not support playing audio during boot animation. This happens either cause "ro.config.play.bootsound=1" is not included in build.prop or the boot animation binary on your device doesn't support it (/system/bin/bootanimation). You can decompile the binary to see if audio support is included (binary is written in c++)


## Steps in script

1. Media file name, enter the plain name and extension in unix format.
2. Your phone screen resolution in WidthxHeight format. (like 1080x2400)
3. The script will ask you if you want audio (not supported in some devices). Let script detect the audio from media file you provided or choose audio yourself
4. File format for frames of animation. Since PNG is loseless, it will take a massive amount of space compared to JPG option. Note that JPG lowers file quality significantly while PNG preserves. If you don't mind your boot animation taking about 100 MiB to 1 GiB space, use PNG. Otherwise use JPG.
5. Program will warn you in case your media exceeds phone screen and will request your permission to continue creating the animation, i don't even know if it will work properly so it's at your discretion to try. This alert won't show if media fits your screen.
6. Program will inform you of media file duration and will ask you how many times to play it. Note that boot process usually takes less than 10 seconds after beginning of boot animation.
7. What you want as background color. Only options currently are black and white.
8. Animation type. This is really important since it will decide if animation will pause immediately after boot process is complete, or will continue to play and finish as many times as you specified.
9. Name your animation using unix file name type. (Example: If you write "Shiggy", the module will be created in name of Shiggy-Bootanimation.zip) Dont try fancy names, use simple names.

After your module is created you can flash it from Magisk Manager app. Needs at least Magisk v20.4.

## About GIF files

Gif files usually have limited frames in a higher framerate. So you may need to do a simple calculation before specifying repeat count of animation during 5th step.

For example:

- We have a GIF file that have 10 frames inside it. (You can learn frame count by extracting frames with `ffmpeg -i file.gif frames_%03d.jpg`)
- Let's say that framerate of this GIF file is 50. (Learn it by `ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate "$video" | bc`) 
- It means that these 10 frames is being looped 5 times per second, with a delay of 20 milliseconds.
- Repeat time you specified in 5th step is this loop count. So if you want to play the animation from GIF file for 10 seconds, you have to set repeat time to 50.
- The script initializes the FPS automatically for Android to read. So you only have to specify the repeat count as; Repeat Count = (FPS / Frame Count) * (Seconds)
- This problem doesnt exist in video files since they have so many frames more than an average GIF file. So only couple of repeats is enough.


