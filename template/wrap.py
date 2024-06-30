"""
_file_ wrap.py
_brief_ xelatex命令行包装脚本
_detail_ 为解决xmake对\def等LaTeX语句的不正确处理，故将对xelatex的调用包装到Python中
_author_ 24bit-xjkp
_email_ 2283572185@qq.com
"""

import sys
import os

arg_file = sys.argv[1]
with open(arg_file, "r", encoding="utf8") as file:
    word_dir = file.readline()
    os.chdir(word_dir[:-1])
    command = file.readline()
    print(command)
    os.system(command)
