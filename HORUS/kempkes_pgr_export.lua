-- Loads the classes from the Horison framework
function load_classes()
    classes_loader = {"msg", "filesystem", "horus::xtn::ladybug"}
    for key, value in pairs(classes_loader) do
        if (not horus.sol:load_classes(value, value)) then
            print("load_classes:", value, "could not be loaded.")
            return false
        end
    end
    return true
end

function splitPath(path)
    local parts = {}
    -- Use the appropriate separator based on OS
    local separator = package.config:sub(1, 1) -- Gets OS directory separator
    -- Alternative: manually specify separator
    -- local separator = "/"  -- for Unix/Linux/macOS
    -- local separator = "\\"  -- for Windows

    -- Use gmatch to iterate through each part
    for part in string.gmatch(path, "[^" .. separator .. "]+") do
        table.insert(parts, part)
    end

    return parts
end

function topgr(...)
    local args = {...}
    print("arguments:", #args)
    for k, v in pairs(args) do
        print(k, v)
    end

    if (not load_classes()) then
        print("horus::msg classes could not be loaded.")
        exit(1)
    end

    print(horus.xtn.ladybug.help())
    project_folder = args[1]

    local separator = package.config:sub(1, 1) -- Gets OS directory separator

    os.execute("mkdir " .. project_folder .. separator .. "pgr")

    -- horus.xtn.ladybug.transform_to_pgr(args[1], args[2], args[3])
    -- /horusdata/Public/Data/03_ClientData/Kempkes/opnames_kempkes/Doesburg_20250318_T36/
    local lbg_index_files = horus.filesystem.find_files(project_folder, "ladybug*idx", true, false)
    for id, lbg in pairs(lbg_index_files) do
        local recording_folder = horus.filesystem.get_folder(lbg)
        local stem = splitPath(recording_folder)

        local pgr_name = project_folder .. separator .. "pgr" .. separator .. stem[#stem]
        local lbg_name = lbg:sub(1, -5)
        local cal_name = args[2]

        print("Ladybug:", lbg_name)
        print("Pgr    :", pgr_name)
        print("Cal    :", cal_name)
        horus.xtn.ladybug.transform_to_pgr(lbg_name, pgr_name, cal_name)

    end

end
