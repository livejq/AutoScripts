#!/bin/zsh
album_dir=/old/blog/themes/liveJQ/source/img/albums/
pics=($(ls $album_dir  |  sort --sort=general-numeric))
printf '['
#zsh数组从1开始
for ((i=1;i<=${#pics[@]};i++))
do
        printf '{\n'
        printf "\t\t\t\"links\":\"${album_dir##*source}${pics[$i]}\",\n"
        if [ $i -lt 29 ]
        then
            printf "\t\t\t\"title\":\"逝水年华\",\n"
        elif [ $i -lt 50 ]
        then
        printf "\t\t\t\"title\":\"我们的时光\",\n"
        else
            printf "\t\t\t\"title\":\"新的开始\",\n"
        fi
        pic=$album_dir$pics[$i]
        eWidth=$(identify -format %w $pic)
        eHeight=$(identify -format %h $pic)
        tWidth=$((eWidth-10))
        tHeight=$((eHeight-10))
        printf "\t\t\t\"tWidth\":$tWidth,\n"
        printf "\t\t\t\"tHeight\":$tHeight,\n"
        printf "\t\t\t\"eWidth\":$eWidth,\n"
        if [ $i -eq ${#pics[@]} ]
        then
            printf "\t\t\t\"eHeight\":$eHeight\n\t}"
        else
            printf "\t\t\t\"eHeight\":$eHeight\n\t},\n"
        fi
done
printf "]\n"
