local curl = require "lcurl.safe"
local json = require "cjson.safe"


script_info = {
	["title"] = "PCS加速通道",
	["version"] = "0.0.3",
	["description"] = "默认并行1",
	["color"] = "FF1493",
}

function onInitTask(task, user, file)
    if task:getType() ~= TASK_TYPE_BAIDU then
        return false
    end
    if user == nil then
        task:setError(-1, "用户未登录")
		return true
	end
	--local appid = 778750
	local appid = 778750
	
	if user:isSVIP() then
		pd.messagebox("超级会员判断成功","提示")
		appid = 250528
	end
	
	--250528（官方）、265486、309847；266719、778750自行选择测试速度即可。我用的是778750。

	local BDUSS = user:getBDUSS()
	local BDS = user:getBDStoken()
	local Cookie = user:getCookie()
	--pd.messagebox(Cookie,"Cookie:")
	
	--local header =  "User-Agent: netdisk;6.9.5.1;PC;PC-Windows;6.3.9600;WindowsBaiduYunGuanJia Cookie: BDUSS="..BDUSS 
	
	local header = { "User-Agent: netdisk;6.9.5.1;PC;PC-Windows;6.3.9600;WindowsBaiduYunGuanJia" }
	--table.insert(header, "Cookie: "..Cookie)
	table.insert(header, "Cookie: BDUSS="..BDUSS)

	local url = "https://pcs.baidu.com/rest/2.0/pcs/file?method=locatedownload&ver=4.0&path="..pd.urlEncode(file.path).."&app_id="..appid
	
    local data = ""
	local c = curl.easy{
		url = url,
		followlocation = 1,
		httpheader = header,
		timeout = 15,
		proxy = pd.getProxy(),
		writefunction = function(buffer)
			data = data .. buffer
			return #buffer
		end,
	}
	
	--c:perform()
	--c:close()
	--pd.messagebox(data)
	local _, e = c:perform()
    c:close()
    if e then
        return false
    end
	
	--pd.messagebox(data)
	
	local j = json.decode(data)
	if j == nil then
        return false
    end

	--[[
	local temp = data
	local downloadURL = ""
	local message1 = {}
	local tt = 0
	for i in pairs(j.server) do
		tt=tt+1
	    --pd.messagebox(j.server[tt],"第几个")
		table.insert(message1, j.server[tt])
	end
	
	
	
	
	downloadURL = "http://"..j.server[1]..j.path.."&filename="..pd.urlEncode(file.path)
	pd.messagebox(downloadURL,"DownloadUrl")
	
	--]]
	
	local message = {}
    local downloadURL = ""
    for i, w in ipairs(j.urls) do
	    downloadURL = w.url
		local d_start = string.find(downloadURL, "//") + 2
        local d_end = string.find(downloadURL, "%.") - 1
		downloadURL = string.sub(downloadURL, d_start, d_end)
        table.insert(message, downloadURL)
    end
	local num = pd.choice(message, 1, "选择下载接口")
    downloadURL = j.urls[num].url
    
	
	--local d_start = string.find(temp, "server") + 2
	--for i,w in inpirs(j) do
	--pd.messagebox(j.server[1],"接口")
	--[[for i, w in ipairs(j.urls) do
        downloadURL = w.url
        local d_start = string.find(downloadURL, "//") + 2
        local d_end = string.find(downloadURL, "%.") - 1
        downloadURL = string.sub(downloadURL, d_start, d_end)
        local length = string.len(downloadURL)
        if length <= 3
        then
            table.insert(message, downloadURL .. "(超推荐)")
        elseif a == 7
        then
            table.insert(message, downloadURL .. "(一般推荐)")
        elseif string.find(downloadURL, "cache") ~= nil
        then
            table.insert(message, downloadURL .. "(超推荐)")
        else
            table.insert(message, downloadURL .. "(普通)")
        end
    end
    local num = pd.choice(message, 1, "选择下载接口")
    downloadURL = j.urls[num].url--]]
	
	
	

	--task:setOptions("host", "d6.baidupcs.com")
	task:setUris(downloadURL)
	--task:setUris(downloadURL)
    task:setOptions("user-agent", "netdisk;6.9.5.1;PC;PC-Windows;6.3.9600;WindowsBaiduYunGuanJia")
	--task:setOptions("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36")
    task:setOptions("header", "Cookie: "..user:getCookie())
	
	
	task:setOptions("piece-length", "5M")
	task:setOptions("max-connection-per-server", "16")
    task:setOptions("allow-piece-length-change", "true")
    task:setOptions("enable-https-pipelining", "true")
	task:setIcon("icon/accelerate.png", "禁止分享该脚本！")

	if user:isSVIP() then
		task:setIcon("icon/accelerate.png", "SVIP加速中")
	end
	
    return true
 


end
