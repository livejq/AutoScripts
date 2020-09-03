# -*- coding:utf-8 -*-
import requests,datetime,re,os,sys,time
from bs4 import BeautifulSoup


'''
    函数match_bar_name用来获取
    1、当前页
    2、关注贴吧名字和链接，返回列表数据，格式[{'name':'abc','link':'www.asdfaf.asdfasdf'},'name':'abc','link':'www.asdfaf.asdfasdf'}]，
'''
def match_bar_name(soup):
    list=[]
    for i in soup.find_all('a'):
        if i.has_attr('href') and not i.has_attr('class') and i.has_attr('title'):
            if i.string != 'lua':
                list.append({'name':i.string,'link':'http://tieba.baidu.com/'+i.get('href')+'&fr=home'})
    return list


'''
    函数get_bar_link用来获取
    1、所有页
    2、关注贴吧
    3、名字和链接
'''
def get_bar_link():#遍历所有页，直到最后一页
    url=r'http://tieba.baidu.com/f/like/mylike?pn=%d'
    pg=1
    tieba_list = []
    while 1:
        res=s.get(url%pg,headers=headers)
        soup=BeautifulSoup(res.text,'html.parser')
        tieba_list.extend(match_bar_name(soup))
        if '下一页' in str(soup):
            pg+=1
        else:
            return tieba_list

'''
    name: 贴吧名字
    link：贴吧链接
'''
def check(name,link):#获取每个关注贴吧 提交数据tbs，然后签到，并返回签到结果
    try:
        res=s.post(link)
        tbs=re.compile('\'tbs\': "(.*?)"')
        find_tbs=re.findall(tbs,res.text)
        if not find_tbs:   #　没有查找到tbs,跳过这个吧的签到
            return -2
        data={
            'ie':'utf-8',
            'kw':name,
            'tbs':find_tbs[0],
        }
        url='http://tieba.baidu.com/sign/add'
        res=s.post(url,data=data,headers=headers)          ######## 签到 post
        # print(datetime.datetime.now(),'    ',name,'   ',res.json())
        return int(res.json()['no'])   #########返回提交结果
    except:
        return -1

def SignIn(data):
    try:
        res=check(data['name'], data['link'])
        if res==0:
            print( data['name'] +'吧签到成功\n')
            return True
        elif res==1101:
            print(  data['name'] +'吧已经签过\n')
            return True
        elif res==1102:
            print( data['name'] + '吧，签到太快，重新签到本吧\n')
            time.sleep(10)
            return False
        else:
            print(res)
            print('未知返回值，重新签到'+ data['name']+'吧')
            return False
    except :
        print('未知报错 重新签到'+ data['name']+'吧')
        return False

if __name__ == "__main__":
    s=requests.session()
    cookie=''
#自行填充百度贴吧的cookies，浏览器-F12-网络-F5-request-cookies

    headers={
        'Cookie':cookie,
        'Upgrade-Insecure-Requests':'1',
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36',
    }

    for i in get_bar_link():#根据签到的返回值处理结果,利用count做最多三次异常重复签到
        flag = False
        count = 0
        while flag == False:
            flag = SignIn(i)
            time.sleep(10)   #控制签到速度
            count = count + 1
            if count >= 3:
                print(i['name']+'吧异常，无法签到，已经跳过')
                break

