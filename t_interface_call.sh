#!/bin/sh
source /etl/.bash_profile
##################################################################
# 程序名称：解析号卡校验和宽带数据日志
# 程序功能：
# 创建信息：2018-08-29  by zhaojl_bds
# 修改信息：2018-09-14  by zhaojl_bds
##################################################################
#参数判断
if [ $# -eq 0 ];then
echo "缺少参数YYYYMMDD"
exit
fi

startTime=`date  +%H:%M:%S`
systime=`date  +%Y%m%d%H%M%S`

#脚本名称
pname="tmrt_t_interface_call"

#常用参数赋值
v_thisyyyymmdd=$1                                                     #当天YYYYMMDD
v_nextyyyymmdd=`date -d "next-day $v_thisyyyymmdd" +%Y%m%d`           #明天YYYYMMDD
v_nextyyyymmdds=`date -d "$v_nextyyyymmdd" +%s`                       #明天时间戳
v_thisyyyymmfirst=`date  -d "$v_thisyyyymmdd" +%Y%m`01                #本月1号YYYYMMDD
v_dealyyyymm=`date -d "1 day ago $v_thisyyyymmfirst" +%Y%m`           #上月YYYYMM
v_thisyyyymm=`date  -d "$v_thisyyyymmdd" +%Y%m`                       #本月YYYYMM
v_thisyyyy=`date -d "$v_thisyyyymmdd" +%Y`                            #本年YYYY
v_thismm=`date -d "$v_thisyyyymmdd" +%m`                              #本月MM
v_thisdd=`date -d "$v_thisyyyymmdd" +%d`                              #当天DD
v_lastyyyymmdd=`date  -d "1 day ago $v_thisyyyymmfirst" +%Y%m%d`      #上月月末YYYYMMDD
v_lastyearyyyymmdd=`date -d "last year $v_thisyyyymmdd" +%s`          #去年同天时间戳
v_lastyearyyyymmddfirst=`date -d "last year $v_thisyyyymmfirst" +%s`  #去年同月1号时间戳
v_thisyyyymmfirsts=`date  -d "$v_thisyyyymmfirst" +%s`                #本月1号时间戳
v_thisyyyymmddss=`date -d "$v_thisyyyymmdd" +%s`                      #当天时间戳
v_dealyyyymmdd=`date  -d "1 day ago $v_thisyyyymmdd" +%Y%m%d`         #前一天YYYYMMDD
v_lastyyyymm=`date -d "1 day ago $v_lastyyyymmdd" +%Y%m`              #前两月YYYYMM
v_deal7yyyymmdd=`date  -d "7 day ago $v_thisyyyymmdd" +%Y%m%d`         #前七天YYYYMMDD
v_lastmonyyyymmdd=`date -d "1 month ago $v_thisyyyymmdd" +%Y%m%d`    #前一个月

#失败异常处理
function exception(){
if [ "$?" -ne 0 ];then
	echo "script failed"
	exit 1
else
	echo "script successful"
fi
}

#定义原路径
source_path="/etl/data/receive/01sale/t_interface_call/$1"
echo ${source_path}
#定义结果路径
result_path="/etl/data/receive/01sale/t_interface_call_analysis/$1"
echo $result_path

#创建目录
mkdir -p ${result_path}
#删除该目录下的文件
rm -f ${result_path}/*

#解析
cat ${source_path}/a010044*.txt | sed 's/,"/;/g' | sed 's/"\|^{\|}$//g' | sed 's/\\/"/g' | awk -F ';' '{
split($1,m,"date:");
split($2,a,"http_code:");
split($3,b,"request_size:");
split($4,c,"http_error_code:");
split($5,d,"server_ip:");
split($6,e,"app_id:");
split($7,f,"interface:");
split($8,g,"request_url:");
split($9,h,"total_time:");
split($10,i,"execute_time:");
split($11,j,"connect_time:");
split($12,k,"input:");
split($13,l,"output:");
print m[2]";"a[2]";"b[2]";"c[2]";"d[2]";"e[2]";"f[2]";"g[2]";"h[2]";"i[2]";"j[2]";"k[2]";"l[2]
}' > ${result_path}/a010044_${v_thisyyyymmdd}0000_01.txt

exception


#删除7天之前的数据文件
rm -rf ${result_path}/a010044_${v_lastmonyyyymmdd}0000_01.txt

#结束

    endTime=`date  +%H:%M:%S`

    sT=`date +%s -d$startTime`
    eT=`date +%s -d$endTime`
    let useTime=`expr $eT - $sT`
    echo "
    Run `basename $0` ok !
        startTime = $startTime
        endTime = $endTime
        useTime = $useTime (s)!"
