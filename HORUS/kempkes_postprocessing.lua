-- Loads the classes from the Horison framework
function load_classes()
    classes_loader = {"msg", "signals", "filesystem", "novatel", "math"}
    for key, value in pairs(classes_loader) do
        if (not horus.sol:load_classes(value, value)) then
            print("load_classes:", value, "could not be loaded.")
            return false
        end
    end
    return true
end

function load_libraries()
    library_loader = {
        [1] = {"horus_signals_utils", horus.signals, "utils"},
        [2] = {"horus_signals_peaks", horus.signals, "peaks"},
        [3] = {"horus_signals_correlate", horus.signals, "correlate"},
    }

    for key, value in ipairs(library_loader) do
        if horus.sol:insert_library_from_search_path(value[1], value[2], value[3]) ~= 1 then
            print("load_libraries:", value[1], "could not be loaded.")
            return false
        end
    end
    return true
end

function run(...)
    local args = {...}

    if not load_classes() or not load_libraries() then
        print("Could not load dependencies")
        return
    end

    horus.signals.utils.verbose = 1
    horus.signals.peaks.verbose = 1
    horus.signals.correlate.verbose = 1

    -- Global
    Vi = horus.signals.utils.Vi
    V = horus.signals.utils.V
    apply_function = horus.signals.utils.apply_function
    available = horus.signals.utils.available
    -- Global

    print("arguments:", #args)
    for k, v in pairs(args) do
        print(k, v)
    end

    project_folder = args[1]
    correlation_method = args[2] or "clock_drift"

    -- Horus signals
    local signal_ctx = horus.signals.Signals_context.new()

    -- Final mulitplex signals
    multiplex = horus.signals.new_signal()
    multiplex.id = horus.signals.Multiplex

    signal_ctx:add_signal(multiplex.id, multiplex)

    add_ladybug_signals(project_folder, signal_ctx)

    add_track_signals(project_folder, signal_ctx)

    write_track_signals(project_folder .. "/tracks.csv", signal_ctx)

    if not add_mark_signals(project_folder, signal_ctx) then
        os.exit(1)
    end
    local dtp = horus.signals.Device_time_processor.new()
    for id, signal in pairs(signal_ctx.signals) do
        s0 = signal:find(horus.signals.Relative_time)
        if (s0 == nil) then
            dtp:process(signal);
        end
    end

    apply_function(signal_ctx:signal_by_id("ladybug"):find("s0"), horus.signals.Unary_function.Diff)
    apply_function(signal_ctx:signal_by_id("mark4"):find("s0"), horus.signals.Unary_function.Diff)

    apply_function(signal_ctx:signal_by_id("ladybug"):find("s0"):find("d"), horus.signals.Unary_function.Min_max)
    apply_function(signal_ctx:signal_by_id("mark4"):find("s0"):find("d"), horus.signals.Unary_function.Min_max)

    apply_function(signal_ctx:signal_by_id("ladybug"):find("s0"):find("d"), horus.signals.Unary_function.Mean_std)
    apply_function(signal_ctx:signal_by_id("mark4"):find("s0"):find("d"), horus.signals.Unary_function.Mean_std)

    local max_peak_value = get_max_peak_value(signal_ctx)
    horus.signals.peaks.add(signal_ctx:signal_by_id("ladybug"), max_peak_value, 2)
    horus.signals.peaks.add(signal_ctx:signal_by_id("mark4"), max_peak_value, 2)
    
    horus.signals.peaks.compare(signal_ctx, "mark4", "ladybug")
    
    correlate_signals(signal_ctx, "mark4", "ladybug", 0.03, correlation_method)

    -- print(signal_ctx:info())

    create_mapping_from_multiplex(signal_ctx, project_folder)

    local owriter = horus.signals.Matlab.new()
    owriter.invalid = "NaN"
    owriter:add_context(signal_ctx, 1)

    mysig = signal_ctx:signal_by_id("ladybug"):find("devtime")
    mysig:set_active_field(horus.signals.Count_field)
    owriter:add_view_vector("devtime_count", mysig.signal)

    owriter:write_to_file(project_folder .. "/signals.m")

end

--------------------------------------------------------------------------
---------------------- GPS LOGS ------------------------------------------
function add_mark_signals(project_folder, ctx)
    print("\n******************************************************")
    print("Trying to obtain the mark[1,4] entries from the gps log")

    
    local dir = string.gsub(project_folder, "_rec", ".PegasusProject", 1)
    local gps_logs = horus.filesystem.find_files(dir, "*.gps", true, false)

    if #gps_logs < 1 then
        print("Could not find gps log in:\n", dir)
        return false
    end

    -- global signals
    m1_time = horus.signals.new_vec_double()
    m1_count = horus.signals.new_vec_double()
    m4_time = horus.signals.new_vec_double()
    m4_count = horus.signals.new_vec_double()
    m4_week = horus.signals.new_vec_double()

    local gps_log = gps_logs[1]
    print(gps_log)
    
    local stream = horus.novatel.Novatel_stream.new()
    stream:observe_message_id(horus.novatel.Message_id.Mark1time)
    stream:observe_message_id(horus.novatel.Message_id.Mark4time)

    if not stream:open(gps_log) then
        print("Could not open stream:", args[1])
    end

    stream:observe(on_gps_message)
    stream:parse()

    if m1_count:size() == 0 then
        print("There are 0 Mark1 entries")
        return false
    end

    if m4_count:size() == 0 then
        print("There are 0 Mark4 entries")
        return false
    end

    local mark1_signal = horus.signals.new_signal()
    mark1_signal.id = "mark1"
    local mark4_signal = horus.signals.new_signal()
    mark4_signal.id = "mark4"

    ctx:add_signal(mark1_signal.id, mark1_signal)
    ctx:add_signal(mark4_signal.id, mark4_signal)

    local dtv = horus.signals.Device_time_view.new()
    dtv.generate(mark1_signal, horus.signals.Signal_flags.Time_pts, m1_time)
    dtv.generate(mark1_signal, horus.signals.Signal_flags.Time_count, m1_count)
    dtv.generate(mark4_signal, horus.signals.Signal_flags.Time_pts, m4_time)
    dtv.generate(mark4_signal, horus.signals.Signal_flags.Time_count, m4_count)

    local double_view = horus.signals.Double_view.new()
    double_view.generate("weeknr", mark4_signal, m4_week)

    local hours_start = ctx:signal_by_id("summary"):find("hour_start")
    local hours_stop = ctx:signal_by_id("summary"):find("hour_stop")

    local mk4_hours_start = horus.signals.new_vec_double()
    local mk1_hours_start = horus.signals.new_vec_double()
    local mk4_hours_stop = horus.signals.new_vec_double()
    local mk1_hours_stop = horus.signals.new_vec_double()

    local mk4_devtime = mark4_signal:find(horus.signals.Devicetime_id)
    local mk1_devtime = mark1_signal:find(horus.signals.Devicetime_id)

    mk4_hours_start:add(((V(mk4_devtime.signal:at(1)) / 1000000) % (24 * 60 * 60)) / (60 * 60))
    double_view.generate("mark4", hours_start, mk4_hours_start)

    mk1_hours_start:add(((V(mk1_devtime.signal:at(1)) / 1000000) % (24 * 60 * 60)) / (60 * 60))
    double_view.generate("mark1", hours_start, mk1_hours_start)

    mk4_hours_stop:add(((V(mk4_devtime.signal:at(mk4_devtime.signal:size())) / 1000000) % (24 * 60 * 60)) / (60 * 60))
    double_view.generate("mark4", hours_stop, mk4_hours_stop)

    mk1_hours_stop:add(((V(mk1_devtime.signal:at(mk1_devtime.signal:size())) / 1000000) % (24 * 60 * 60)) / (60 * 60))
    double_view.generate("mark1", hours_stop, mk1_hours_stop)

    print("\n******************************************************")
    return true

end

function on_gps_message(mystream, mymessage)
    local _debug_ = false

    -- MARK 1
    if mymessage:get_message_id() == horus.novatel.Message_id.Mark1time then
        if _debug_ then
            print("Mark1: ", mymessage:get_gnss_week_number(), mymessage:get_gnss_milliseconds())
        end
        m1_count:add(m1_count:size() + 1)
        m1_time:add(mymessage:get_gnss_milliseconds() * 1000)
    end
    -- MARK 4
    if mymessage:get_message_id() == horus.novatel.Message_id.Mark4time then
        if _debug_ then
            print("Mark4: ", mymessage:get_gnss_week_number(), mymessage:get_gnss_milliseconds())
        end
        m4_count:add(m4_count:size() + 1)
        m4_time:add(mymessage:get_gnss_milliseconds() * 1000)
        m4_week:add(mymessage:get_gnss_week_number())
    end
end

--------------------------------------------------------------------------
---------------------- LADYBUG ENTRIES ------------------------------------------
function add_ladybug_signals(project_folder, ctx)
    print("\n******************************************************")
    print("Trying to obtain ladybug entries from the recording folders")

    local lbg_index_files = horus.filesystem.find_files(project_folder, "ladybug*idx", true, false)
    table.sort(lbg_index_files)
    local signals_context_processor = horus.signals.Signals_context_processor.new()

    local lbg_signal = horus.signals.new_signal()
    lbg_signal.id = "ladybug"

    local devtime_signal = horus.signals.new_signal()
    devtime_signal.id = horus.signals.Devicetime_id

    ctx:add_signal("ladybug", lbg_signal) -- root entry

    lbg_signal.signals[horus.signals.Devicetime_id] = devtime_signal -- devtime
    local grabbertime = lbg_signal:add(horus.signals.Grabbertime_id)

    local lbg_sequence_id = -1
    local lbg_recs = {}
    local count = 0
    for id, lbg in pairs(lbg_index_files) do
        local recording_folder = horus.filesystem.get_folder(lbg)
        print(id, recording_folder)
        local temp_ctx = horus.signals.Signals_context.new()
        temp_ctx:add_folder(recording_folder)
        resolve_device_times(temp_ctx)

        -- add grabbertime
        local gtp = horus.signals.Grabber_time_processor.new()
        for id, signal in pairs(temp_ctx.signals) do
            gtp:process(signal);
        end

        -- print(temp_ctx:info())

        signals_context_processor:add_summary(horus.filesystem.get_local_folder(lbg), temp_ctx, ctx)

        local tmp_lbg_signal = temp_ctx:signal_by_id("Ladybug_Grabber")
        local tmp_devtime = tmp_lbg_signal:find(horus.signals.Devicetime_id)
        local gbtime = tmp_devtime:find(horus.signals.Grabbertime_id)

        for _, entry in pairs(gbtime.signal) do
            grabbertime.signal:add(entry)
        end

        lbg_signal.flags = lbg_signal.flags | tmp_lbg_signal.flags
        devtime_signal.flags = devtime_signal.flags | tmp_devtime.flags

        local start = -1
        for _, entry in pairs(tmp_devtime.signal) do
            count = count + 1
            local val = horus.signals.get_view_value_by_id(entry, horus.signals.Count_field)
            if val < lbg_sequence_id then
                print("multiple sequence ids")
                count = 0
            end

            if start == -1 then
                start = val
            end
            lbg_sequence_id = val
            devtime_signal.signal:add(entry)
        end
        lbg_recs[recording_folder] = {count, start, lbg_sequence_id, lbg_sequence_id - start}

        collectgarbage("collect")
    end
    printTableByKey(lbg_recs, printLbgRec)
end

function resolve_device_times(ctx)
    local resolver = horus.signals.Signal_resolver.new()

    local dtv = horus.signals.Device_time_view.new()

    resolver:add(horus.signals.Signal_flags.Device_time_view, horus.signals.Devicetime_id, dtv:create())

    for id, signal in pairs(ctx.signals) do
        resolver:process(signal)
    end
end

----------------------------------------------------------------------------------
----------- Adding stop start recording as track
function add_track_signals(project_folder, ctx)
    local state_index_files = horus.filesystem.find_files(project_folder, "systemstate*idx", true, false)
    table.sort(state_index_files)
    local track_start = horus.signals.new_vec_double()
    local track_stop = horus.signals.new_vec_double()

    for id, state in pairs(state_index_files) do
        local reader = horus.msg.Data_reader.create(state:sub(1, -5))
        local indices = reader:get_index_vector()

        for key, value in pairs(indices) do
            smart_base_type = reader:get_data(value)
            base_type = smart_base_type:get()

            local stamp = 0
            if base_type:data_size() > 0 then -- Loop
                for idx = 1, base_type:data_size() do
                    local data = base_type:data_at(idx)

                    if base_type:coordinates_size() > 0 then
                        for idx = 1, base_type:coordinates_size() do
                            local coordinate = base_type:coordinate_at(idx)
                            if horus.msg.coordinates.Type.Time == coordinate:type() then
                                local t = coordinate:as_time()
                                if t:has_stamp() then
                                    stamp = ((t:stamp() / 1000000) % (24 * 60 * 60)) / (60 * 60)
                                end
                            end
                        end
                    end

                    -- check if we have ascii
                    if data:has_metadata() then
                        md = data:metadata()
                        local codec = md:codec()

                        -- obtain the buffer
                        if codec:majortype() == horus.msg.data.Codec_type.TEXT then
                            if data:has_buffer() then
                                if string.find(data:buffer(), "StartingRecording") then
                                    track_start:add(stamp)
                                elseif string.find(data:buffer(), "StoppingRecording") then
                                    track_stop:add(stamp)
                                end

                            end
                        end
                    end
                end
            end
        end
    end

    horus.signals.vec_double_sort(track_start)
    horus.signals.vec_double_sort(track_stop)

    local hours_start = ctx:signal_by_id("summary"):find("hour_start")
    local hours_stop = ctx:signal_by_id("summary"):find("hour_stop")

    local double_view = horus.signals.Double_view.new()
    double_view.generate("tracks", hours_start, track_start)
    double_view.generate("tracks", hours_stop, track_stop)

end

function write_track_signals(filename, ctx)
    if not available(ctx, "summary", "hour_start", "tracks") then
        print("Tracks start not available")
        return
    end

    if not available(ctx, "summary", "hour_stop", "tracks") then
        print(ctx, "Tracks stop not available")
        return
    end

    if not available(ctx, "ladybug", "grabbertime") then
        print(ctx, "Grabbertime stop not available")
        return
    end

    local tr_start = ctx:signal_by_id("summary"):find("hour_start"):find("tracks")
    local tr_stop = ctx:signal_by_id("summary"):find("hour_stop"):find("tracks")
    local grabbertime = ctx:signal_by_id("ladybug"):find(horus.signals.Grabbertime_id)

    if (tr_start.signal:size() ~= tr_stop.signal:size()) then
        print("Tracks start/stop have different dimensions start:", tr_start.signal:size(), "stop:",
            tr_stop.signal:size())
    end

    local file_handle = io.open(filename, "w")

    file_handle:write("track,start(h),stop(h),duration(h),count\n")

    local grabbertime_index = 1
    for index = 1, tr_stop.signal:size() do

        local count = 0
        local bounds = grabbertime_index <= grabbertime.signal:size()

        -- print("for", index)
        if bounds then
            local mytime = ((Vi(grabbertime, grabbertime_index) / 1000000) % (24 * 60 * 60)) / (60 * 60)

            while mytime <= Vi(tr_stop, index) and bounds do
                if grabbertime_index <= grabbertime.signal:size() then
                    count = count + 1
                    mytime = ((Vi(grabbertime, grabbertime_index) / 1000000) % (24 * 60 * 60)) / (60 * 60)
                    grabbertime_index = grabbertime_index + 1
                    -- print(tr_stop.signal:size() - index, mytime, Vi(tr_stop, index))
                end
                bounds = grabbertime_index <= grabbertime.signal:size()
            end
        end

        local start_val = Vi(tr_stop, index)
        if index <= tr_start.signal:size() then
            start_val = Vi(tr_start, index)
        end

        file_handle:write(index)
        file_handle:write(",")
        file_handle:write(start_val)
        file_handle:write(",")
        file_handle:write(Vi(tr_stop, index))
        file_handle:write(",")
        file_handle:write(Vi(tr_stop, index) - start_val)
        file_handle:write(",")
        file_handle:write(count)
        file_handle:write("\n")
    end

    file_handle:close()
end

----------------------------------------------------------------------------------
----------- Correlates 2 signals assuming 
function correlate_signals(ctx, lead_name, sig_name, epsilon, method)
    print("\n******************************************************")
    print("correlate_signals", lead_name, sig_name)

    local lead = ctx:signal_by_id(lead_name)
    local sig = ctx:signal_by_id(sig_name)

    if lead == nil or sig == nil then
        print(">> Could not [correlate_signals] lead signal", lead, "signal", sg, "invalid")
    end

    -- 1 Correlate by index based on peaks strategy
    if (available(ctx, sig_name, "peaks", lead_name .. "_offset", "sig_offset")) then
        local lead_offset = horus.signals.get_view_value(sig:find(lead_name .. "_offset").signal:at(2))
        local sig_offset = horus.signals.get_view_value(sig:find("sig_offset").signal:at(2))
        if (method == "clock_drift") then
            horus.signals.correlate.by_index_and_diff_drift(ctx, lead_name, lead_offset, sig_name, sig_offset, epsilon)
        elseif (method == "time_diff") then
            horus.signals.correlate.by_index_and_diff(ctx, lead_name, lead_offset, sig_name, sig_offset, epsilon)
        else
            print("unnsupported correlate_signals method")
        end
    end
end

function create_mapping_from_multiplex(ctx, folder)
    print("\n******************************************************")
    print("create_mapping_from_multiplex")

    if (not available(ctx, "multiplex", "index", "mark4")) then
        print("no ladybug mulitplex data available")
        return
    end

    local mplex = ctx:signal_by_id(horus.signals.Multiplex)

    if mplex == nil then
        print(" >> create_mapping_from_multiplex no multiplex signals found")
    end

    local file_handle = io.open(folder .. "/mark4_ladybug_mapping.csv", "w")

    file_handle:write("sec_of_week,week_nr,labybug_idx,sec_ladybug\n")

    -- indexing
    local lbg_idx = mplex:find("ladybug"):find("index")
    local mark_idx = mplex:find("ladybug"):find("mark4")

    -- values
    local mk4 = ctx:signal_by_id("mark4"):find(horus.signals.Devicetime_id)
    local weeknr = ctx:signal_by_id("mark4"):find("weeknr")
    local lbg_data = ctx:signal_by_id("ladybug"):find(horus.signals.Devicetime_id)
    local lbg_time = ctx:signal_by_id("ladybug"):find(horus.signals.Uncycled_id)

    for index = 1, mark_idx.signal:size() do
        local m_index = horus.signals.get_view_value(mark_idx.signal:at(index))
        local l_index = horus.signals.get_view_value(lbg_idx.signal:at(index))

        mk4_val = horus.signals.get_view_value(mk4.signal:at(m_index)) / 1000000.0
        lbg_count = horus.signals.get_view_value_by_id(lbg_data.signal:at(l_index), horus.signals.Count_field)
        lbg_stamp = horus.signals.get_view_value(lbg_time.signal:at(l_index)) / 1000000.0

        file_handle:write(mk4_val)
        file_handle:write(",")
        file_handle:write(horus.signals.get_view_value(weeknr.signal:at(m_index)))
        file_handle:write(",")
        file_handle:write(math.floor(lbg_count))
        file_handle:write(",")
        file_handle:write(lbg_stamp)
        file_handle:write("\n")

    end

end

function get_max_peak_value(ctx)
    local Vi = horus.signals.utils.Vi
    local value = math.huge

    for id, signal in pairs(ctx.signals) do

        local mean_std = signal:find(horus.signals.Mean_std)
        if mean_std ~= nil then
            local std_dev = Vi(mean_std, 2)
            local mean = Vi(mean_std, 1)
            print("    [std/mean]  (" .. id .. "," .. tostring(std_dev) .. "," .. tostring(mean) .. ")")
            local max_value = std_dev * 3

            -- if relative std_dev > 2000%
            if std_dev / mean > 20 then
                max_value = mean * 6
            end

            value = math.min(value, max_value)
        end
    end
    return value
end

function printTableByKey(tbl, f)
    -- Get all keys
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end

    -- Sort the keys
    table.sort(keys)

    -- Print key-value pairs in sorted order
    for _, k in ipairs(keys) do
        f(k, tbl[k])
    end
end

function printLbgRec(k, val)
    print(k, val[1], val[2], val[3], val[4])
end
