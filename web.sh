#!/bin/bash

#set -x


red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"

#获取当前脚本目录copy脚本之家
Source="$0"
while [ -h "$Source"  ]; do
    dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"
    Source="$(readlink "$Source")"
    [[ $Source != /*  ]] && Source="$dir_file/$Source"
done
dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"

#简介
	page=$(cat $dir_file/mod.txt | grep "page" | wc -l)
	#教学列表
	book=$(cat $dir_file/mod.txt | grep "book" | wc -l)
	#引论
	folder=$(cat $dir_file/mod.txt | grep "folder" | wc -l)
	#PDF文档,需要下载
	resource=$(cat $dir_file/mod.txt | grep "resource" | wc -l)
	#视频
	kalvidres=$(cat $dir_file/mod.txt | grep "kalvidres" | wc -l)



start() {
		
url="https://course.ougd.cn"
firefox https://course.ougd.cn/login/index.php?authCAS=CAS &
sleep 5
shouhu &
cat >/tmp/mod_name.txt <<EOF
	page
	book
	folder
	resource
	kalvidres
EOF
	for i in `cat /tmp/mod_name.txt`
	do
	{
		echo "-----------------------------------------------------------------------"		
		echo -e "$green >>现在开始执行观看$yellow${i}$green,数量一共有$yellow`cat $dir_file/mod.txt | grep "$i" | wc -l`$green个$white"
		echo "-----------------------------------------------------------------------"	
		case "$i" in
		resource)
			if [[ $(cat $dir_file/tmp/$i) -ge $(cat $dir_file/mod.txt | grep "$i" | wc -l) ]];then
				echo "$i已经下载完成，跳过"
			else
				cat $dir_file/mod.txt | grep "$i" >/tmp/$i

				if [[ -f "$dir_file/tmp/$i" ]];then
					num=$(cat $dir_file/tmp/$i)
				else
					num="1"
				fi
				
				while [ `cat /tmp/$i | wc -l` -ge $num ];do
					echo "开始下载PDF文件,数量一共有`cat /tmp/$i | wc -l`个"
					mod=$(cat /tmp/$i |sed -n ${num}p)
					firefox ${url}${mod} 
					echo -e "${green}下载第${yellow}${num}${green}个${white},还剩${yellow}$(($(cat /tmp/$i | wc -l) - $num))${white}个"
					num=$(( $num +1 ))
					sleep 2
					echo "$num" >$dir_file/tmp/$i
				done
				kill_ps
			fi
			
		;;
		kalvidres)
			if [[ $(cat $dir_file/tmp/$i) -ge $(cat $dir_file/mod.txt | grep "$i" | wc -l) ]];then
				echo "$i已经观看完成，跳过"
			else
				cat $dir_file/mod.txt | grep "$i" >/tmp/$i

				if [[ -f "$dir_file/tmp/$i" ]];then
					num=$(cat $dir_file/tmp/$i)
				else
					num="1"
				fi
				
				while [ `cat /tmp/$i | wc -l` -ge $num ];do
					echo -e "${green}观看第${yellow}${num}${green}个${white},还剩${yellow}$(($(cat /tmp/$i | wc -l) - $num))${white}个"
					mod=$(cat /tmp/$i |sed -n ${num}p)
					firefox ${url}${mod}
					num=$(( $num +1 ))
					sleep 120
					echo "$num" >$dir_file/tmp/$i
				done
				kill_ps
			fi
		;;
		*)
			if [[ $(cat $dir_file/tmp/$i) -ge $(cat $dir_file/mod.txt | grep "$i" | wc -l) ]];then
				echo "$i已经观看完成，跳过"
			else
				cat $dir_file/mod.txt | grep "$i" >/tmp/$i

				if [[ -f "$dir_file/tmp/$i" ]];then
					num=$(cat $dir_file/tmp/$i)
				else
					num="1"
				fi
				
				while [ `cat /tmp/$i | wc -l` -ge $num ];do
					echo -e "${green}下载第${yellow}${num}${green}个${white},还剩${yellow}$(($(cat /tmp/$i | wc -l) - $num))${white}个"
					mod=$(cat /tmp/$i |sed -n ${num}p)
					firefox ${url}${mod}
					num=$(( $num +1 ))
					sleep 2
					echo "$num" >$dir_file/tmp/$i
				done
				kill_ps
			fi
		;;
		esac
	}
	done
	
}

shouhu() {
	while [[ 1 -gt 0 ]]; do
		Mem=$(free -h | awk '{print $3}' |grep "G" | awk -F "." '{print $1}')
		if [[	"$Mem" -ge "6"	]];then
			echo "当前内存过高，开始终止浏览器。。"
			kill_ps
			echo "重新打开浏览器。。"
			firefox https://course.ougd.cn/login/index.php?authCAS=CAS &
			sleep 5
		else
			echo -ne "$green当前内存使用：$yellow`free -h | awk '{print $3}' |grep "G" | awk -F "." '{print $1}'G`$white"
			sleep 3
			echo -ne "\r"
		fi
	done
}

kill_ps() {
	Mem_ps=$(top -b -n 1 | grep firefox | awk '{print $1}')
	kill -9 $Mem_ps
}

start
