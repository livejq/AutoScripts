import os


def removeBom(file):
    '''移除UTF-8文件的BOM字节'''
    BOM = b'\xef\xbb\xbf'
    existBom = lambda s: True if s == BOM else False

    f = open(file, 'rb')
    if existBom(f.read(3)):
        fbody = f.read()
        # f.close()
        with open(file, 'wb') as f:
            f.write(fbody)


if __name__ == '__main__':
    for root, dirs, files in os.walk("./"):
        count = 0
        for file in files:
            #if file.find(".txt") != -1:
            removeBom(os.path.join(root, file))
            count += 1
        print(count)
