# -*- coding:utf-8 -*-
import base64

bs='iVBORw0KGgoAAAANSUhEUg....'
imgdata=base64.b64decode(bs)
file=open('2.jpg','wb')
file.write(imgdata)
file.close()
