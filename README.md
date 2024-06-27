# NuaaExam：南京航空航天大学高清试卷

- 项目主页：<https://github.com/24bit-xjkp/NuaaExam>
- 作者：24bit-xjkp(<2283572185@qq.com>)

为解决学解提供的试卷清晰度低，排版混乱的问题，本项目提供基于 $\LaTeX$ 重新排版的试卷。试卷来自[NUAA-Store](https://nuaa.store)。

## 开始使用

1. 安装 $\LaTeX$ 发行版

   选择任一 $\LaTeX$ 发行版安装即可。

   | 发行版      | 优缺点                             | 下载链接                                                                 |
   | ----------- | ---------------------------------- | ------------------------------------------------------------------------ |
   | $\TeX$ Live | 宏包完整，安装包较大，安装时间较长 | [南京大学镜像站](<https://mirrors.nju.edu.cn/CTAN/systems/texlive>)      |
   | MiK $\TeX$  | 安装包小，但需要手动安装部分宏包   | [南京大学镜像站](<https://mirrors.nju.edu.cn/CTAN/systems/win32/miktex>) |

2. 安装Xmake构建工具

   下载并安装[Xmake](<https://xmake.io/#/zh-cn/guide/installation>)，这是Xmake工具的[文档](<https://xmake.io/#/zh-cn>)。

3. 编译所有 $\LaTeX$ 文件

    ```shell
    xmake config # 此时会自动下载依赖包exam-zh
    xmake build
    xmake install -o /path/to/install
    ```

## 相关项目

- exam-zh: <https://gitee.com/xkwxdyy/exam-zh>
- xmake: <https://github.com/xmake-io/xmake>
