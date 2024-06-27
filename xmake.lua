set_project("NuaaExam")

rule("latex")
    set_extensions(".tex")
    on_build_files(function (target, sourcebatch, opt)
        import("core.project.depend")
        import("utils.progress")
        import("lib.detect.find_tool")

        os.mkdir(target:targetdir())
        local target_dir = path.join(vformat("$(buildir)"), ".obj", target:name())
        os.mkdir(target_dir)
        target_file = path.join(target_dir, target:basename())
        local xelatex = assert(find_tool("xelatex"), "xelatex not found")
        local command = {"-8bit", "-interaction=nonstopmode", "-halt-on-error", "-jobname="..target_file}

        local find_main_file = false
        for _, file in ipairs(sourcebatch.sourcefiles) do
            if file == target:name()..".tex" then
                table.insert(command, file)
                find_main_file = true
                break
            end
        end
        assert(find_main_file)

        depend.on_changed(function ()
            progress.show(opt.progress, "${color.build.object}compiling target %s 1st", target:name())
            os.vrunv(xelatex.program, command)
            progress.show(opt.progress, "${color.build.object}compiling target %s 2nd", target:name())
            os.vrunv(xelatex.program, command)
        end, {changed = target:is_rebuilt() or not os.isfile(target_file..".pdf"), files = table.join(sourcebatch.sourcefiles), values = command})
    end)
    on_link(function (target)
        local file_name = target:basename()..".pdf"
        local src_file = path.join(vformat("$(buildir)"), ".obj", target:name(), file_name)
        local dst_file = path.join(target:targetdir(), file_name)
        os.cp(src_file, dst_file)
    end)
    on_clean(function (target)
        local target_dir = path.join(vformat("$(buildir)"), ".obj", target:name())
        local suffix = {"aux", "log", "out", "toc", "pdf"}
        for _, v in ipairs(suffix) do
            os.rm(target_dir.."/*."..v)
        end
        os.rm(path.join(target:targetdir(), target:basename()..".pdf"))
    end)
    on_install(function (target)
        local file_name = target:basename()..".pdf"
        local src_file = path.join(target:targetdir(), file_name)
        local dst_file = path.join("$(installdir)", file_name)
        os.cp(src_file, dst_file)
    end)
rule_end()


add_rules("latex")
includes("*/*.xmake")
