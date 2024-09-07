# initialize the directories
rm -rf .bootanimation
mkdir .bootanimation
mkdir .bootanimation/part0
rm -rf .module
mkdir .module


echo "LOG STARTS" > log.txt
echo "########################" >> log.txt

# ask user for media file 
read -p "Enter media file name: " video


splitVideo() { # split video into its frames 
  printf "Choose file format (1 or 2): \n"
  printf "1.jpg (Recommended) (Low file size= 5-50MB)\n"
  printf "2.png (High file size= 100MB-1GB)\n"
  
  readImageType() {
    read -p "> " imageType
    if [[ ! "$imageType" = "1" && ! "$imageType" = "2" ]]; then
      printf "\n"
      printf "You can only choose 1 or 2\n"
      readImageType
    fi
  }

  readImageType
  # split image regarding to user choice
  if [ "$imageType" = "1" ]; then 
    printf "Splitting video...\n"
    ffmpeg -i ${video} .bootanimation/part0/boot_%05d.jpg >> log.txt 2>&1
  fi
  if [ "$imageType" = "2" ]; then 
    printf "Splitting video...\n"
    ffmpeg -i ${video} .bootanimation/part0/boot_%05d.png >> log.txt 2>&1
  fi
}

# ask user screen res then grab width and height with regular expressions
printf "Enter your phone screen resolution in order of Width and Height (example: 1080x1920, 1080x2400): \n" 
read -p "> " phoneRes
screenWidth="${phoneRes%x*}"
screenHeight="${phoneRes#*x}"

splitVideo
printf "Splitting is successfull\n"

echo "########################" >> log.txt
echo "########################" >> log.txt
echo "splitVideo function is ended" >> log.txt
echo "########################" >> log.txt
echo "########################" >> log.txt

getFramerate() { # get the video framerate using ffprobe which is part of ffmpeg
  videoFramerate=$(ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate "$video" | bc) >> log.txt 2>&1
}

getResolution() { # get the video resolution using ffprobe
  videoWidth=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$video") >> log.txt 2>&1
  videoHeight=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 "$video") >> log.txt 2>&1 
  # why this function isnt colored in syntax lol?
}

getDuration() { # get the video duration using ffprobe
  videoDuration=$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of csv=p=0 "$video") >> log.txt 2>&1
}

# get some info regarding the media
getFramerate
getResolution
getDuration

printf "\nYour video is "$videoWidth"x""$videoHeight and $videoFramerate FPS\n"


centerAnimation() {
  frames=$(ls -1 .bootanimation/part0/ | wc -l)
  count=0
 
  trimX=$(( (screenWidth - videoWidth) / 2 ))
  trimY=$(( (screenHeight - videoHeight) / 2 ))
  # Check if video resolution is bigger than the screen in X, Y and both X-Y planes
  #
  #
  # check X
  if [[ "$trimX" -lt 0 && ! "$trimY" -lt 0 ]]; then
    echo -e "\e[31m!!!\e[0m"
    echo -e "\e[31m!!!\e[0m"
    echo -e "\e[31m!!! \e[32mHorizontal \e[31mdimension of your video exceeds your phone's screen by $((0 - trimX)) pixels. In this case the video will be cropped from both sides to fit the screen.\e[0m"
    read -p "Do you still want to continue? (y/n): " continue
    case "$continue" in
      "y"|"Y")
        echo ""
        ;;
      *)
        echo "Process has been terminated."
        exit 1;
        ;;
    esac
  fi

  # check Y
  if [[ ! "$trimX" -lt 0 && "$trimY" -lt 0 ]]; then
    echo -e "\e[31m!!!\e[0m"
    echo -e "\e[31m!!!\e[0m"
    echo -e "\e[31m!!! \e[32mVertical \e[31mdimension of your video exceeds your phone's screen by $((0 - trimY)) pixels. In this case the video will be cropped from both sides to fit the screen.\e[0m"
    read -p "Do you still want to continue? (y/n): " continue
    case "$continue" in
      "y"|"Y")
        echo ""
        ;;
      *)
        echo "Process has been terminated."
        exit 1;
        ;;
    esac
  fi

  # check both X and Y
  if [[ "$trimX" -lt 0 && "$trimY" -lt 0 ]]; then
    echo -e "\e[31m!!!\e[0m"
    echo -e "\e[31m!!!\e[0m"
    echo -e "\e[31m!!! Both \e[32mHorizontal and Vertical \e[31mdimension of your video exceeds your phone's screen by $((0 - trimX)) and $((0 - trimY)) pixels. In this case the video will be cropped from both sides to fit the screen.\e[0m"
    read -p "Do you still want to continue? (y/n): " continue
    case "$continue" in
      "y"|"Y")
        echo ""
        ;;
      *)
        echo "Process has been terminated."
        exit 1;
        ;;
    esac
  fi

  # add trim info of frames to trim.txt
  while [ $count -lt $frames ]; do
    echo "$videoWidth""x""$videoHeight+$trimX+$trimY" >> .bootanimation/part0/trim.txt
    ((count++))  
  done

}

centerAnimation

createDescription() {
  echo "$screenWidth $screenHeight $videoFramerate" > .bootanimation/desc.txt

  printf "Your video duration is %.2f seconds\n" "$videoDuration"
  read -p "How many times you want to play the animation: " repeat
  printf "\n"
  
  readColor () {
    printf "What you want as background color: \n"
    printf "Black: b \n"
    printf "White: w \n"
    read -p "> " backgroundColor
    printf "\n"
    # check if given color is correct
    if [[ ! "$backgroundColor" = "b" && ! "$backgroundColor" = "w" ]]; then
      printf "\e[31mOnly b and w (black & white) is supported \n\e[0m"
      readColor
    fi
  }
  
  readColor

  readType () {
    printf "Do you want animation to be paused when your phone is booted or to continue until its finished? \n" 
    printf "Pause: p \n"
    printf "Continue: c \n"
    read -p "> " type
    printf "\n"

    if [[ ! "$type" = "p" && ! "$type" = "c" ]]; then
      printf "Only c or p is supported \n"
      readType
    fi
  }

  readType

  if [ "$backgroundColor" = "black" ]; then
    echo "$type $repeat 0 part0 #000000" >> .bootanimation/desc.txt
  fi

  if [ "$backgroundColor" = "white" ]; then
    echo "$type $repeat 0 part0 #FFFFFF" >> .bootanimation/desc.txt
  fi

  cd .bootanimation && zip -r -0 bootanimation.zip * >> ../log.txt 2>&1
  cd ..

  echo "Boot animation is complete and archived"
}

createDescription 


createModule() {

  cp -r module/* .module/ # copy module template
  
  sed -i "s/REPLACE/$1/g" .module/module.prop # change module name 

  cp .bootanimation/bootanimation.zip .module/system/product/media/ # copy bootanimation to required folder

  cd .module && zip -r -0 ../"$1-Bootanimation.zip" * >> ../log.txt 2>&1 # pack module into a zip archive

}

read -p "Name your animation: (dont use white space): " moduleName

createModule "$moduleName"

printf "Your module has been created. Flash it from Magisk Manager.\n"

echo "########################" >> log.txt
echo "PROCESS ENDS" >> log.txt



