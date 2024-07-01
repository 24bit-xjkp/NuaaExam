-- @file xmake.lua
-- @brief xmake构建脚本
-- @detail 定义latex构建规则
-- @author 24bit-xjkp
-- @email 2283572185@qq.com

set_project("NuaaExam")

option("solution")
    set_values("inline", "backend", "hidden", "mixed")
    set_default("backend")
    -- 控制解答的显示方式
    set_description("Set the solution display mode.\n"..
    -- inline  在题目后显示解答
    "\t- inline  Show the solutions under the questions.\n"..
    -- backend 在试卷最后显示解答
    "\t- backend Show the solutions at the end of the paper.\n"..
    -- hidden  不显示解答
    "\t- hidden  Do not show the solutions.\n"..
    -- mixed   先生成hidden的章节，再生成inline的章节
    "\t- mixed   Generate hidden chapter first, then generate inline chapter.")
option_end()

rule("latex")
    set_extensions(".tex")
    -- 扩展名必须设置成pdf，否则安装时会报目标未构建
    on_load(function (target)
        assert(path.extension(target:targetfile()) == ".pdf" or target:kind() == "phony")
    end)
    on_build_files(function (target, sourcebatch, opt)
        import("core.project.depend")
        import("utils.progress")
        import("lib.detect.find_tool")

        os.mkdir(target:targetdir())
        local target_dir = path.join(vformat("$(buildir)"), ".obj", target:name())
        os.mkdir(target_dir)
        local target_file = path.join(target_dir, target:name()..".pdf")
        local xelatex = assert(find_tool("xelatex"), "xelatex not found")
        local command = {"-8bit", "-file-line-error", "-interaction=nonstopmode", "-halt-on-error",
                         "-jobname="..target:name(), "-output-directory="..path.absolute(target_dir)}

        local find_main_file = false
        local main_file = "" -- 主文件名恒为main.tex
        for _, file in ipairs(sourcebatch.sourcefiles) do
            if path.filename(file) == "main.tex" then
                main_file = string.gsub(file, "\\", "/")
                find_main_file = true
                break
            end
        end
        assert(find_main_file, "main.tex not found")

        local main_dir = path.directory(main_file)
        -- 添加预定义宏
        local defines = [["\def\Solution{%s}\input{%s}"]]
        table.insert(command, format(defines, get_config("solution"), path.filename(main_file)))

        -- 不含bibtex的需要编译两次以生成正确的交叉引用
        depend.on_changed(function ()
            local commands = xelatex.program.." "
            for _, v in ipairs(command) do
                commands = commands..v.." "
            end

            local old_dir = os.cd(main_dir)
            progress.show(opt.progress, "${color.build.object}compiling target %s 1st", target:name())
            os.vrun(commands)
            progress.show(opt.progress, "${color.build.object}compiling target %s 2nd", target:name())
            os.vrun(commands)
            os.cd(old_dir)
        end, {changed = target:is_rebuilt(), files = table.join(sourcebatch.sourcefiles, target_file), values = command})
    end)
    on_link(function (target, opt)
        import("core.project.depend")
        import("utils.progress")
        local src_file = path.join("$(buildir)", ".obj", target:name(), target:name()..".pdf")
        local dst_file = target:targetfile()
        -- 复制输出的pdf到目标目录
        depend.on_changed(function ()
            progress.show(opt.progress, "${color.build.target}copying target %s pdf", target:name())
            os.cp(src_file, dst_file)
        end, {changed = target:is_rebuilt(), files = {src_file, dst_file}})
    end)
    on_clean(function (target)
        local target_dir = path.join("$(buildir)", ".obj", target:name())
        local suffix = {"aux", "log", "out", "toc", "pdf", "solution", "xdv", "fls"}
        for _, v in ipairs(suffix) do
            os.rm(target_dir.."/*."..v)
        end
        os.rm(target:targetfile())
    end)
    on_install(function (target)
        os.cp(target:targetfile(), path.join(target:installdir(), target:filename()))
    end)
    on_uninstall(function (target)
        os.rm(path.join(target:installdir(), target:filename()))
        -- 目录为空时删除目录
        if #os.files(target:installdir()) == 0 then
            os.rmdir(target:installdir())
        end
    end)
rule_end()


add_rules("latex")
set_extension(".pdf")
includes("*/xmake.lua")

includes("@builtin/xpack")
xpack("NuaaExam")
    set_version("0.1")
    set_homepage("https://github.com/24bit-xjkp/NuaaExam")
    set_title("NuaaExam")
    set_description("基于LaTeX重新排版的南京航空航天大学高清试卷。")
    set_author("24bit-xjkp 2283572185@qq.com")
    set_maintainer("24bit-xjkp 2283572185@qq.com")
    set_copyright("Copyright (C) 2024, 24bit-xjkp 2283572185@qq.com")
    set_license("MIT")
    set_licensefile("LICENSE")
    set_bindir("")
    set_formats("zip", "targz", "srczip", "srctargz")
    -- LaTeX源文件
    add_sourcefiles("(**/*.tex)|$(buildir)/.xpack/*.*")
    -- xmake编译脚本
    add_sourcefiles("(**/*.lua)|$(buildir)/.xpack/*.*")
    -- 编译脚本、许可证和readme
    add_sourcefiles("xmake.lua", "LICENSE", "README.md")

    on_load(function (package)
        import("core.project.project")
        for name, target in pairs(project.targets()) do
            package:add("targets", name)
        end
    end)
xpack_end()
