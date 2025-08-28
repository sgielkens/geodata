function load_classes()
    classes_loader = {"msg", "cmp", "nmea", "signals","frames"}
    for key,value in pairs(classes_loader) do
      if (not horus.sol:load_classes(value,value)) then
        print("load_classes:",value,"could not be loaded.")
        exit(1)
      end
    end 
end

function write_frames(gps,mapping,lbg, ofolder, filename)
    print("Writing frames:",ofolder)
	size = tablelength(lbg)
    print("Images:",size)
	
	if size == 0 then
		return
	end

    local frames_writer = horus.signals.Frames_writer.new()
    frames_writer:create(size)
    dataset = frames_writer.frames

	local mykeys = sorted_keys(lbg)

    index = 1
    for key, value in pairs(mykeys) do
		local myentry = lbg[value]
        count = myentry["count"]
        relation = mapping[count]
        cl_key,V = findClosest(gps,relation["mk4time"])

        location = dataset:at(index)
       
        local timestamp = gps_to_utc_timestamp(V["weeknr"],V["time"])   
		local nmea = "$DBG," .. myentry["count"] .. "," .. relation["mk4time"] .. "," .. V["time"] .."*"
		nmea = nmea .. calculate_nmea_checksum(nmea)		

        location:update(V["lat"],V["lon"],V["alt"], timestamp, V["roll"], V["pitch"], V["heading"], nmea)
		
		dataset:set_image(location, "/", filename, myentry["offset"])

        index = index + 1
    end

    frames_writer:write_to_file(ofolder .. "/frames.xml")
end

function mark4ladybugmapping(csvfile)
    local mycsv = {}

    header = true
    for line in io.lines(csvfile) do        
        if header then
            header = false            
        else
            local items = {}
            for item in string.gmatch(line .. ",", "([^,]*),") do
                table.insert(items, item)
            end
                
            items["mk4time"] = tonumber(items[1])
            items["count"] = tonumber(items[3])  
            mycsv[items["count"]] = items          
        end
    end
    return mycsv    
end


-- extract csv information

-- GPS weeknr,GPSTime,Latitude,Latitude,Latitude,Latitude,Longitude,Longitude,Longitude,Longitude,H-Ell,Pitch,Roll,Heading,Q,PDOP,SDEast,E-Sep,SDNorth,N-Sep,SDHeight,H-Sep
-- (nr),(sec),(D),(M),(S),(Degrees Decimal),(D,(M),(S),(Degrees Decimal),(m),(deg),(deg),(deg),,(dop),(m),(m),(m),(m),(m),(m)
-- 2352,397230.596,53,10,49.728559,53.18048016,6,32,46.804883,6.54633469,44.062,0.392731,1.396751,50.624131,2,0.74,0.004,-0.005,0.005,-0.007,0.009,0.006

function parsecsv(csvfile)
    local headersize  = 2
    local line_idx = 0
    local mycsv = {}

    local insert_idx = 1
    for line in io.lines(csvfile) do
        if line_idx >= headersize then            
            local items = {}

            for item in string.gmatch(line .. ";", "([^;]*);") do
                table.insert(items, item)
            end
            
            items["weeknr"] = tonumber(items[1])
            items["time"] = tonumber(items[2])
            items["lat"] = tonumber(items[6])
            items["lon"] = tonumber(items[10])
            items["alt"] = tonumber(items[11])
			items["pitch"] = tonumber(items[12])
			items["roll"] = tonumber(items[13])
			items["heading"] = tonumber(items[14])			
            mycsv[items["time"]] = items    
        end        
        line_idx = line_idx + 1
    end
    return mycsv    
end

function frames(...)

    load_classes()

    init_enum_tbls()

    local args = {...}
    for k,v in pairs(args) do
        print(k,v)
    end

    folder = args[1]    -- root
    container = args[2] -- Ladybug Grabber
    mark4lbgmap_file = folder .. "/mark4_ladybug_mapping.csv" 
	gps_export_file = find_files_by_pattern("Project_*.csv", folder)[1]
    
    gps_export = parsecsv(gps_export_file)
    mark4lbgmap = mark4ladybugmapping(mark4lbgmap_file)

    --for key, value in pairs(gps_export) do
    --     print(key, value["lon"],value["lat"])
    --end

    
    folders = get_folders(folder)
    for key, value in pairs(folders) do
        
        -- print(key .. " = " .. value)
		
		local o_data = {}
        local filename = value .. "/" .. container        
        
        if file_exists(filename .. ".idx") then
		
            local reader = horus.msg.Data_reader.create(filename)
            local indices = reader:get_index_vector()    
            for key,value in pairs(indices) do
                local entry = {}
                entry["offset"] = value:offset()                
                if value:data_size() > 0 then 
                                      
                    local data = value:data_at(1)
                    if data:coordinates_size() > 0 then
                        for idx=1,data:coordinates_size() do
                            local coordinate = data:coordinate_at(idx)
                            if horus.msg.coordinates.Type.Time == coordinate:type() then                                    
                                local t = coordinate:as_time()        
                                if t:format() == 3 then
                                    if t:has_stamp() then
                                        entry["count"] = t:stamp()
                                    end
                                end                                            
                            end
                        end
                    end

                    if data:has_metadata() then
                        md = data:metadata()                        
                        local codec = md:codec()                                       
                
                        if codec:has_properties() then 
                            local cdc_prop = codec:properties()
                
                            if cdc_prop:has_ladybug_properties() then
                                local lbg_prop = cdc_prop:ladybug_properties()
                                local lbg_img_info = lbg_prop:image_info()
                                if lbg_img_info:has_sync_gps() then
                                    --file_handle:write(lbg_img_info:time_seconds(),",")
                                    --file_handle:write(lbg_img_info:time_microseconds(),"\n")                                                        
                                    entry["sec"] = lbg_img_info:time_seconds()
                                    entry["usec"] = lbg_img_info:time_microseconds()
                                end
                            end
                        end
                    end
                    o_data[entry["count"]] = entry
                end                
            end
            write_frames(gps_export,mark4lbgmap,o_data,value,container)
        end
    end
end

function get_folders(path)
    local folders = {}
    path = path or "."
    local command
    
    -- Adjust command based on OS
    if package.config:sub(1,1) == '\\' then
        -- Windows
        command = 'dir /b /ad "'..path..'"'
    else
        -- Unix-like
        command = 'ls -la "'..path..'" | grep "^d" | awk \'{print $NF}\''
    end
    
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    
    local index = 1
    for dir in result:gmatch("([^\r\n]+)") do
        if dir ~= "." and dir ~= ".." then
            --print("Directory found: " .. path .. "/" .. dir)
            folders[index] = (path .. "/" .. dir)
            index = index + 1
        end
    end
    return folders
end

function find_files_by_pattern(pattern, start_dir)
    start_dir = start_dir or "."
    local results = {}
    local is_windows = os.getenv("OS") == "Windows_NT"
    local cmd_format = is_windows and 'dir "%s\\%s" /s /b /a-d' or "find '%s' -name '%s' -type f"
    local command = string.format(cmd_format, start_dir, pattern)
    local handle = io.popen(command, 'r')

    for line in handle:lines() do
        line = line:match("^%s*(.-)%s*$")
        if line and #line > 0 then
            table.insert(results, line)
        end
    end

    handle:close()
    return results
end

function file_exists(filePath)
    local file = io.open(filePath, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

function init_enum_tbls()

    units_unit_type_tbl = {}
    for key, value in pairs(horus.msg.units.Unit_type) do        
        units_unit_type_tbl[value] = key
    end

    sensors_structure_type_tbl = {}
    for key, value in pairs(horus.msg.sensors.Structure_type) do     
        sensors_structure_type_tbl[value] = key
    end

    sensors_data_type_tbl = {}
    for key, value in pairs(horus.msg.sensors.Data_type) do     
        sensors_data_type_tbl[value] = key
    end

    data_codec_type_enum = {}
    for key, value in pairs(horus.msg.data.Codec_type) do     
        data_codec_type_enum[value] = key
    end

    mediacodec_type_tbl = {}
    for key, value in pairs(horus.msg.data.Mediacodec_type) do     
        mediacodec_type_tbl[value] = key
    end

    time_source_tbl = {}
    for key, value in pairs(horus.msg.coordinates.Time_source) do     
        time_source_tbl[value] = key
    end
end

function sorted_keys(tbl)
    -- Create a temporary array to hold all keys
    local keys = {}
    
    -- Collect all keys from the table
    for k in pairs(tbl) do
      table.insert(keys, k)
    end
    
    -- Sort the keys
    table.sort(keys)
    
    return keys
  end
  

  -- Functions GPS / TIME 
function gps_to_utc_timestamp(week_number, seconds_of_week)
    -- GPS epoch started at January 6, 1980 00:00:00
    local gps_epoch = 315964800  -- Unix timestamp for GPS epoch
    local seconds_in_week = 604800
    local leap_seconds = 18  -- As of 2024
    
    -- Calculate total seconds since GPS epoch
    local total_seconds = (week_number * seconds_in_week) + seconds_of_week
    
    -- Convert to UTC by subtracting leap seconds
    local utc_seconds = total_seconds - leap_seconds
    
    -- Add GPS epoch to get Unix timestamp
    local unix_timestamp = gps_epoch + utc_seconds
    
    -- Break down into components
    local days = math.floor(unix_timestamp / 86400)
    local remainder = unix_timestamp % 86400
    local hours = math.floor(remainder / 3600)
    remainder = remainder % 3600
    local minutes = math.floor(remainder / 60)
    local seconds = remainder % 60
    local fractional = seconds % 1
    seconds = math.floor(seconds)
    
    -- Calculate year, month, day
    local epoch_days = days
    local year = 1970
    while true do
        local days_in_year = 365
        if year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then
            days_in_year = 366
        end
        if epoch_days < days_in_year then
            break
        end
        epoch_days = epoch_days - days_in_year
        year = year + 1
    end
    
    local month = 1
    local days_in_month = {31,28,31,30,31,30,31,31,30,31,30,31}
    if year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then
        days_in_month[2] = 29
    end
    
    while epoch_days >= days_in_month[month] do
        epoch_days = epoch_days - days_in_month[month]
        month = month + 1
    end
    
    local day = epoch_days + 1
    
    -- Format the timestamp
    return string.format("%04d-%02d-%02dT%02d:%02d:%02d.%03dZ",
        year, month, day,
        hours, minutes, seconds,
        math.floor(fractional * 1000))
end

function calculate_nmea_checksum(str)
    -- Remove leading '$' if present
    if str:sub(1,1) == '$' then
        str = str:sub(2)
    end
    
    -- Find the checksum separator '*' if present and only use data before it
    local asterisk_pos = str:find('*')
    if asterisk_pos then
        str = str:sub(1, asterisk_pos - 1)
    end
    
    -- Calculate checksum
    local checksum = 0
    for i = 1, #str do
        checksum = checksum ~ str:byte(i)
    end
    
    -- Return as two-digit hex
    return string.format("%02X", checksum)
end

function findClosest(tbl, targetValue)
    local closestKey = nil
    local closestValue = nil
    local minDifference = math.huge
    
    -- Iterate through the table
    for key, value in pairs(tbl) do
        -- Check if the key is a number
        if type(key) == "number" then
            local difference = math.abs(key - targetValue)
            
            -- Update if this is the closest value so far
            if difference < minDifference then
                minDifference = difference
                closestKey = key
                closestValue = value
            end
        end
    end
    
    -- Return the closest key and its value
    return closestKey, closestValue
end
  
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end