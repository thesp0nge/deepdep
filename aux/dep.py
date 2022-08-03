#!/usr/bin/python

import requests
from bs4 import BeautifulSoup
from lxml import html
import urllib3
import os.path


if __name__ == "__main__":
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    HEADERS = ({'User-Agent':
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 \
                (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36',\
                'Accept-Language': 'en-US, en;q=0.5'})

    for i in range(6, 11):
        filename='api-'+str(i)+'.txt'
        if not os.path.exists(filename):
            url='https://docs.oracle.com/javase/'+str(i)+'/docs/api/deprecated-list.html'
            html_text = requests.get(url, verify=False, timeout=3, headers=HEADERS).text
            with open(filename, 'w') as f:
                if i == 6:
                    tree = html.fromstring(html_text)
                    l=tree.xpath('//tr[@class="TableRowColor"]/td/a/text()')
                    for e in l:
                        f.write(e+"\n")
                if i >=7 and i < 9:
                    tree = html.fromstring(html_text)
                    l=tree.xpath('//td[@class="colOne"]/a/text()')
                    for e in l:
                        f.write(e+"\n")
                if i >= 9:
                    soup = BeautifulSoup(html_text, 'html.parser')
                    for e in soup.find_all('th'):
                        f.write(e.text+"\n")
            print(filename+': created')
        else:
            print(filename+': skipped')
    for i in range(11, 19):
        filename='api-'+str(i)+'.txt'
        if not os.path.exists(filename):
            url='https://docs.oracle.com/en/java/javase/'+str(i)+'/docs/api/deprecated-list.html'
            html_text = requests.get(url, verify=False, timeout=3, headers=HEADERS).text
            with open(filename, 'w') as f:
                tree = html.fromstring(html_text)

                if i >= 11 and i < 15:
                    l=tree.xpath('//th[@class="colDeprecatedItemName"]/a/text()')
                    for e in l:
                        f.write(e+"\n")
                if i == 15:
                    l=tree.xpath('//th[@class="col-deprecated-item-name"]/a/text()')
                    for e in l:
                        f.write(e+"\n")



                if i >= 16:
                    l=tree.xpath('//div/a/text()')
                    for e in l:
                        f.write(e+"\n")
            print(filename+': created')
        else:
            print(filename+': skipped')
