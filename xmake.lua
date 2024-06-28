-- @file xmake.lua
-- @brief xmake构建脚本
-- @detail 定义latex构建规则
-- @author 24bit-xjkp
-- @email 2283572185@qq.com

set_project("NuaaExam")

rule("latex")
    set_extensions(".tex")
    -- 扩展名必须设置成pdf，否则安装时会报目标未构建
    on_load(function (target)
        assert(path.extension(target:targetfile()) == ".pdf")
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
        local command = {"-8bit", "-interaction=nonstopmode", "-halt-on-error",
                         "-output-directory="..target_dir, "-jobname="..path.basename(target:filename())}

        local find_main_file = false
        for _, file in ipairs(sourcebatch.sourcefiles) do
            if path.basename(file) == target:name() then
                file = string.gsub(file, "\\", "/")
                table.insert(command, file)
                find_main_file = true
                break
            end
        end
        assert(find_main_file)

        -- 不含bibtex的需要编译两次以生成正确的交叉引用
        depend.on_changed(function ()
            progress.show(opt.progress, "${color.build.object}compiling target %s 1st", target:name())
            os.vrunv(xelatex.program, command)
            progress.show(opt.progress, "${color.build.object}compiling target %s 2nd", target:name())
            os.vrunv(xelatex.program, command)
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
        end, {changed = target:is_rebuilt(), files = {src_file, dst_file}, values = {}})
    end)
    on_clean(function (target)
        local target_dir = path.join("$(buildir)", ".obj", target:name())
        local suffix = {"aux", "log", "out", "toc", "pdf", "solution"}
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
