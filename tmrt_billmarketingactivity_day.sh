#!/bin/bash
source /e3base/.bash_profile
#说明：看账单领领流量营销活动附件二开发

#参数判断
if [ $# -eq 0 ];then
    v_thisyyyymmdd=`date -d "1 day ago" +%Y%m%d`                          #当天YYYYMMDD
else
    v_thisyyyymmdd=$1
fi

startTime=`date  +%H:%M:%S`
systime=`date  +%Y%m%d%H%M%S`

# 常用参数赋值
#v_thisyyyymmdd=$1                                                    #当天YYYYMMDD
v_nextyyyymmdd_=`date -d "$v_thisyyyymmdd" +%Y-%m-%d`                 #当天YYYY-MM-DD
v_thisyyyymmdds=`date -d "$v_thisyyyymmdd" +%s`                       #当天时间戳
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
v_dealyyyymmdd=`date  -d "1 day ago $v_thisyyyymmdd" +%Y%m%d`         #前一天YYYYMMDD
v_lastyyyymm=`date -d "1 day ago $v_lastyyyymmdd" +%Y%m`              #前两月YYYYMM
echo $v_thisyyyymmdd
echo $v_thisyyyy
echo $v_thismm
echo $v_thisdd

year=${v_thisyyyymmdd:0:4}
echo $year
month=${v_thisyyyymmdd:4:2}
echo $month
aday=${v_thisyyyymmdd:6:2}
echo $aday


############################################################################################################################################

#所有脚本开始

#首先，将文件清空。
> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt

echo "#######################${v_thisyyyymmdd}看账单领流量营销活动#######################" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "开始时间：startTime = "$startTime >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "系统时间：systime = "$systime >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt

echo "参数年月日：v_thisyyyymmdd = "${v_thisyyyymmdd} >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "参数年月：v_thisyyyymm = "${v_thisyyyymm} >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "参数年  ：v_thisyyyy = "${v_thisyyyy} >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "参数月  ：v_thismm = "${v_thismm} >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "参数日  ：v_thisdd = "${v_thisdd} >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt


#*********************************************************************************************************************************
#1.优惠券使用情况

sql="
select
'${v_thisyyyymmdd}'
,case when t.batch_id='1036535292015804416' then '12元话费加赠券'
     when t.batch_id='1036539413569601536' then '老用户500MB流量兑换券(9m)' end as catagory
,count(distinct case when regexp_replace(substr(t.BIND_TIME,1,10),'-','')='${v_thisyyyymmdd}' and t.lifecycle_st!='5' then t.PCARD_SN end) as bind_num  --发放量
,count(distinct case when regexp_replace(substr(t.USE_TIME,1,10),'-','')='${v_thisyyyymmdd}' and t.LIFECYCLE_ST='10' then t.PCARD_SN end) as use_num  --使用量
from pods.Coupons_V2_TD_PCARD_INFO t
where t.yearstr=${v_thisyyyy} and t.monthstr=${v_thismm} and t.daystr=${v_thisdd}
and t.batch_id in ('1036535292015804416','1036539413569601536')
group by
case when t.batch_id='1036535292015804416' then '12元话费加赠券'
     when t.batch_id='1036539413569601536' then '老用户500MB流量兑换券(9m)' end 
"


#执行
echo "${sql}"
echo "***********************************************" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "1.优惠券使用情况" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
hive -e "${sql};" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt


#*********************************************************************************************************************************
#2.参与活动的客户情况--新用户数和老用户数以及用券客户数

sql="
select
'${v_thisyyyymmdd}'
,case when t.batch_id='1036535292015804416' then '12元话费加赠券'
     when t.batch_id='1036539413569601536' then '老用户500MB流量兑换券(9m)' end as catagory
,count(distinct case when regexp_replace(substr(t.bind_time,1,10),'-','')='${v_thisyyyymmdd}' and t.LIFECYCLE_ST!='5' then bind_no end) as new_old_user_num
,count(distinct case when regexp_replace(substr(t.use_time,1,10),'-','')='${v_thisyyyymmdd}' and t.LIFECYCLE_ST='10' then bind_no end) as couple_user_num
from pods.Coupons_V2_TD_PCARD_INFO t
where t.yearstr=${v_thisyyyy} and t.monthstr=${v_thismm} and t.daystr=${v_thisdd}
and t.batch_id in ('1036535292015804416','1036539413569601536')
group by
case when t.batch_id='1036535292015804416' then '12元话费加赠券'
     when t.batch_id='1036539413569601536' then '老用户500MB流量兑换券(9m)' end 
    "


#执行
echo "${sql}"
echo "***********************************************" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "1.参与活动的客户情况--新用户数和老用户数以及用券客户数" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
hive -e "${sql};" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt



#*********************************************************************************************************************************
#4.APP拉新促活情况-APP新增激活
sql="
 select '${v_thisyyyymmdd}',add_activityuser_num from pmrt.tmrt_day_app_activeuser_data where deal_date=${v_thisyyyymmdd} and prov_code='9999' and city_code='0000';
    "


#执行
echo "${sql}"
echo "***********************************************" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "4.APP拉新促活情况-APP新增激活" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
hive -e "${sql};" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt

#*********************************************************************************************************************************
#5.APP拉新促活情况-目标新用户激活
sql="
select '${v_thisyyyymmdd}'
,count(case when m.serial_number is null then d.serial_number end) as newer
from (select serial_number
      from pods.BOS_LOGIN_DTL_NEW    --登录业务明细记录表
      where year=${v_thisyyyy} and month=${v_thismm} and day<=${v_thisdd}
      and serial_number not like '%@%'
      and length(serial_number)=11
      and serial_number rlike '^\\\d+$'
      group by serial_number ) d
      left join (select serial_number
                 from pmrt.app_logins
                 where deal_date='20180901') m  --2017年1月1日到统计周期上一月底（8月31日）登录过手厅的用户
                 on d.serial_number=m.serial_number
					left join ( select section
							   ,prov_code
							   ,city_code
							   from pods.MNG_AREANUM_INFO
							   where substring(regexp_replace(expiry_date, '-', ''),1,8)>${v_thisyyyymmfirst} ) a2
							   on substring(d.serial_number,1,7)=a2.section
					           where a2.prov_code is not null
					           and a2.city_code is not null
    "


#执行
echo "${sql}"
echo "***********************************************" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "5.APP拉新促活情况-目标新用户激活" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
hive -e "${sql};" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt

#*********************************************************************************************************************************
#6.APP拉新促活情况-APP日活用户数
sql="
select stat_day,actnum from pmrt.tmrt_day_app_chan_activeuser_data where deal_date='${v_thisyyyymmdd}' and chancode='1004' and orgcode='000' and citycode='0000';
    "


#执行
echo "${sql}"
echo "***********************************************" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "6.APP拉新促活情况-APP日活用户数" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
hive -e "${sql};" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt


#*********************************************************************************************************************************
echo "***********************************************" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "script successful!" >> /e3base/zjl/shell/active/BillMarketingActivity/result/tmrt_billmarketingactivity_day_${v_thisyyyymmdd}.txt
echo "script successful"

