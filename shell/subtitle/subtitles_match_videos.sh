#!/bin/bash
subtitle="ass"
video="mp4"
dir=./

findsubs=$(find $dir -name "* *.$subtitle" | sort --sort=general-numeric)
findvis=$(find $dir -name "* *.$video" | sort --sort=general-numeric)
sub=$(ls -l $dir*.$subtitle | grep "^-" | wc -l)
vi=$(ls -l $dir*.$video | grep "^-" | wc -l)
sum=$((sub > vi ? vi : sub))

if [[ -n "${findsubs}" && -n "${findvis}" ]]; then
     #将原本的分隔符记录
     old=${IFS}
     #将内部域分隔符设置为换行
     IFS=$'\n'
     count=0
     #zsh与bash的for-in循环有差异
     for findsub in ${findsubs}; do
          subList[count]="${findsub}"
          ((count++))
     done

     count=0
     for findvi in ${findvis}; do
          viList[count]="${findvi}"
          ((count++))
     done
     for ((i = 0; i < $sum; i++)); do
          mv ${subList[i]} ${viList[i]%%$video}$subtitle
     done
     IFS=${old}
     echo -e "已成功将 $sum 个空格命名视频匹配到其对应的空格命名字幕～\n"
elif [ -n "${findvis}" ]; then
     subtitles=($(ls *.$subtitle | sort --sort=general-numeric))
     old=${IFS}
     IFS=$'\n'
     count=0
     for findvi in ${findvis}; do
          viList[count]="${findvi}"
          ((count++))
     done
     for ((i = 0; i < $sum; i++)); do
          mv ${subtitles[i]} ${viList[i]%%$video}$subtitle
     done
     IFS=${old}
     echo -e "已成功将 $sum 个空格命名视频匹配到其对应的字幕～\n"
elif [ -n "${findsubs}" ]; then
     videos=($(ls *.$video | sort --sort=general-numeric))
     old=${IFS}
     IFS=$'\n'
     count=0
     for findsub in ${findsubs}; do
          subList[count]="${findsub}"
          ((count++))
     done
     for ((i = 0; i < $sum; i++)); do
          mv ${subList[i]} ${videos[i]%%$video}$subtitle
     done
     IFS=${old}
     echo -e "已成功将 $sum 个视频匹配到其对应的空格命名字幕～\n"
else
     subtitles=($(ls *.$subtitle | sort --sort=general-numeric))
     videos=($(ls *.$video | sort --sort=general-numeric))
     for ((i = 0; i < $sum; i++)); do
          mv ${subtitles[i]} ${videos[i]%%$video}$subtitle
     done
     echo -e "已成功将 $sum 个视频匹配到其对应的字幕～\n"
fi
