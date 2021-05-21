## 功能

为指定电影目录下的电影文件自动生成硬链接。

## 配置

脚本中需要配置一些必要信息（目录都以斜杠结尾），如：



1. 目录或文件中包含的特殊字符：[ ] ( ) 空格等
2. 电影后缀名：mkv、mp4等
3. 电影目录绝对路径（电影根目录）：例如 /mnt/user/media/movie/
4. 电影相对于所给电影目录的深度：默认为4层（包括根目录）
5. 硬链目标目录：例如 /mnt/user/media/kodi/movie/
6. 保存的电影名称信息文件：默认 /mnt/user/media/movie/kodiMovies.info，用来记录已硬链的电影名称，方便新增硬链。

## 用法

将脚本放在服务器上的硬链目标目录下执行

``` bash
chmod 766 ./createHardLinksForMovies.sh
bash ./createHardLinksForMovies.sh
```
