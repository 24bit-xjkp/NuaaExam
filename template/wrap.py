"""
_file_ wrap.py
_brief_ xelatex命令行包装脚本
_detail_ 为解决xmake对\def等LaTeX语句的不正确处理，故将对xelatex的调用包装到Python中
_author_ 24bit-xjkp
_email_ 2283572185@qq.com
"""

import sys
import os

"""*.wrap文件结构(utf8编码)
work_dir
command
"""

# 获取包装文件路径
wrap_file = sys.argv[1]
with open(wrap_file, encoding="utf8") as file:
    # 加载工作目录
    work_dir = file.readline()
    os.chdir(work_dir[:-1])
    # 运行包装文件中的命令
    command = file.readline()
    # 回显编译命令
    print(command)
    exit_code = os.system(command)
    # 将错误码返回给父进程
    sys.exit(exit_code)
