# NuaaExam：南京航空航天大学高清试卷

- 项目主页：[GitHub](https://github.com/24bit-xjkp/NuaaExam) [Gitee](https://gitee.com/xjkp-24bit/NuaaExam)
- 作者：24bit-xjkp(<2283572185@qq.com>)

为解决学解提供的试卷清晰度低，排版混乱的问题，本项目提供基于 $\LaTeX$ 重新排版的试卷。试卷来自[NUAA-Store](https://nuaa.store/)。

## 开始使用

1. 安装 $\LaTeX$ 发行版

   选择任一 $\LaTeX$ 发行版安装即可。

   | 发行版      | 优缺点                             | 下载链接                                                                |
   | ----------- | ---------------------------------- | ----------------------------------------------------------------------- |
   | $\TeX$ Live | 宏包完整，安装包较大，安装时间较长 | [南京大学镜像站](https://mirrors.nju.edu.cn/CTAN/systems/texlive/)      |
   | MiK $\TeX$  | 安装包小，但需要手动安装部分宏包   | [南京大学镜像站](https://mirrors.nju.edu.cn/CTAN/systems/win32/miktex/) |

   源代码仅能通过`xelatex`工具编译，因而需要验证`xelatex`是否可用：

   ```shell
   xelatex -v
   ```

2. 安装Xmake构建工具

   下载并安装[Xmake](https://xmake.io/#/zh-cn/guide/installation)，这是Xmake工具的[文档](https://xmake.io/#/zh-cn/)。

3. 编译所有 $\LaTeX$ 文件

   ```shell
   xmake config --option=value       # 设置构建选项
   xmake build                       # 构建项目
   xmake install -o /path/to/install # 安装输出的pdf文件
   ```

## 构建选项

- solution 控制解答的显示方式(默认 backend)
   | 选项    | 描述                                         |
   | ------- | -------------------------------------------- |
   | inline  | 内联，在题目后显示解答                       |
   | backend | 后置，在试卷最后显示解答                     |
   | hidden  | 隐藏，不显示解答                             |
   | mixed   | 混合，先生成hidden的章节，再生成inline的章节 |

- suffix 是否添加文件名后缀(默认 none)
   | 选项   | 描述                                                    |
   | ------ | ------------------------------------------------------- |
   | none   | 不添加文件名后缀                                        |
   | mode   | 根据解答显示方式自动添加后缀                            |
   | string | 添加自定义后缀(string 为除上述两个选项之外的任意字符串) |

## 相关项目

- exam-zh: <https://gitee.com/xkwxdyy/exam-zh>
- xmake: <https://github.com/xmake-io/xmake/>
- Nuaa-Store: <https://nuaa.store/>
