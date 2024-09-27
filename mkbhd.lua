-- Uncomment if you want to create a directory
os.execute("mkdir mkbhd")

-- Require the necessary modules
local json = require("lunajson")
local socket = require("socket")
local http = require("ssl.https") -- Use ssl.https for HTTPS requests

local lfs = require("lfs") -- Lua File System for directory manipulation
-- Read remote file from website
local body, code = http.request("https://storage.googleapis.com/panels-api/data/20240916/media-1a-i-p~s?s=09")
if not body then
	error(code)
end

-- Save the body to a file
local file = assert(io.open("file.json", "w"))
file:write(body)
file:close()

-- Parse json with lunajson
local success, data = pcall(json.decode, body)
if not success then
	error("Failed to decode JSON: " .. data) -- 'data' contains the error message
end

-- Function to get specific field values
local function getSpecificField(data, fieldName)
	local values = {} -- Table to store the collected values
	for _, entry in pairs(data.data) do
		if entry[fieldName] then -- Check if the field exists
			table.insert(values, entry[fieldName]) -- Collect the specific field value
		end
	end
	return values -- Return the collected values after the loop
end

local dhd = getSpecificField(data, "dhd") -- Use the correct field name you want to extract

for _, url in ipairs(dhd) do
	local value, code2 = http.request(url) -- Send a request to the URL
	if code2 ~= 200 then -- Check the correct code variable
		error("Failed to download image: HTTP " .. tostring(code2))
	end
	-- Extract the filename from the URL
	local file_name = "mkbhd/" .. tostring(url):match("([^/]+)$") -- Get the last part of the URL as the filename
	local file = assert(io.open(file_name, "wb")) -- Open the file in binary mode
	file:write(value) -- Write the image data to the file
	file:close() -- Close the file
end
