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
        target_dir = string.gsub(target_dir, "\\", "/")
        os.mkdir(target_dir)
        local target_file = path.join(target_dir, target:filename())
        local xelatex = assert(find_tool("xelatex"), "xelatex not found")
        local python = assert(find_tool("python3") or find_tool("python"), "python not found")
        local command = {"-8bit", "-file-line-error", "-interaction=nonstopmode", "-halt-on-error",
                         "-jobname="..path.basename(target:filename())}

        local find_main_file = false
        local main_file = ""
        for _, file in ipairs(sourcebatch.sourcefiles) do
            if path.basename(file) == target:name() then
                main_file = string.gsub(file, "\\", "/")
                find_main_file = true
                break
            end
        end
        assert(find_main_file)

        local main_dir = path.directory(main_file)
        local out_dir = string.gsub(path.relative(target_dir, main_dir), "\\", "/")
        table.insert(command, "-output-directory="..out_dir)
        -- 添加预定义宏
        local defines = [["\def\Solution{%s}\input{%s}"]]
        table.insert(command, format(defines, get_config("solution"), path.filename(main_file)))

        -- 不含bibtex的需要编译两次以生成正确的交叉引用
        depend.on_changed(function ()
            -- 生成命令包装文件
            local wrap_file_path = path.join(target_dir, target:name()..".wrap")
            local commands = xelatex.program.." "
            for _, v in ipairs(command) do
                commands = commands..v.." "
            end
            io.writefile(wrap_file_path, main_dir.."\n"..commands)
            -- 设置包装脚本路径
            local wrap_script = path.join(os.scriptdir(), "template", "wrap.py")

            -- 调用包装脚本实现构建
            progress.show(opt.progress, "${color.build.object}compiling target %s 1st", target:name())
            os.vrunv(python.program, {wrap_script, wrap_file_path})
            progress.show(opt.progress, "${color.build.object}compiling target %s 2nd", target:name())
            os.vrunv(python.program, {wrap_script, wrap_file_path})
        end, {changed = target:is_rebuilt(), files = table.join(sourcebatch.sourcefiles, target_file), values = command})
    end)
    on_link(function (target, opt)
        import("core.project.depend")
        import("utils.progress")
        local src_file = path.join("$(buildir)", ".obj", target:name(), target:filename())
        local dst_file = target:targetfile()
        -- 复制输出的pdf到目标目录
        depend.on_changed(function ()
            progress.show(opt.progress, "${color.build.target}copying target %s pdf", target:name())
            os.cp(src_file, dst_file)
        end, {changed = target:is_rebuilt(), files = {src_file, dst_file}})
    end)
    on_clean(function (target)
        local target_dir = path.join("$(buildir)", ".obj", target:name())
        local suffix = {"aux", "log", "out", "toc", "pdf", "solution", "wrap", "xdv", "fls"}
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
