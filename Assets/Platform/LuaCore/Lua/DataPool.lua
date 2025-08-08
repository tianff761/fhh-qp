--数据存取相关接口类
DataPool = {};

local this = DataPool;

local pool = {};

-- 将table的数据按照键值对的方式存放，取数据的时候使用table的key值即可，
-- 参数name为表名，可以不传，为了防止字段重复，可以传入name字段，同理取
-- 该table中的数据调用Get接口时也需要传入name字段
function DataPool.Put(src, name)
    if (not src) or type(src) ~= "table" then
    
    end
    
    for k, v in pairs(src) do
        if k ~= "__index" then
            this.Set(k, v, name);
        end
    end
end

-- 设置数据，参数name见Put接口的说明
function DataPool.Set(key, value, name)
    if not key then
        
    end
    
    if name then
        key = name.."_"..key;
    end
    
    pool[key] = value;

end

-- 获取数据，参数name字段见Put接口的说明
function DataPool.Get(key, name)
    if not key then
        
    end
    
    if name then
        key = name.."_"..key;
    end
    
    return pool[key];
end

-- 将table的数据按照键值对的方式持久化存放，参见Put接口的说明
function DataPool.PutLocal(src, name)
    if (not src) or type(src) ~= "table" then
        print(">> DataPool.PutLocal > src = nil or not table")
        return
    end
    
    for k, v in pairs(src) do

        if k ~= "__index" then
            this.SetLocal(k, v, name);
        end
    end
end

-- 设置持久化数据
function DataPool.SetLocal(key, value, name)
    if not key then
        
    end
    
    if name then
        key = name.."_"..key;
    end
    
    key = "local_"..key;
    
    pool[key] = value;
    
    PlayerPrefs.SetString(key, tostring(value));
    PlayerPrefs.Save();
end

-- 获取持久化数据，返回值为string类型，若需要number，可使用tonumber转换，
function DataPool.GetLocal(key, name)
    if not key then
        Log(">> DataPool.GetLocal > key = nil.")
    end
    
    if name then
        key = name.."_"..key;
    end
    
    key = "local_"..key;
    
    local value = pool[key];
    if not value then
        value = PlayerPrefs.GetString(key);
        if tostring(value) == "nil" or tostring(value) == "null" then
            value = nil;
        else
            pool[key] = value;
        end
    end
    if value == "" then
        value = nil;
    end
    return value;
end

-- 打印pool中的所有数据
function DataPool.Print()
    printTable(pool);
end


-- 清空所有数据
function DataPool.Clear()
    pool = {};
end

--文件路径，写入内容
function DataPool.WriteLocal(path, str)
    local file = io.open(path, "w");
    if file == nil then
        return;
    end
    assert(file);
    file:write(str);
    file:close();
    
end

function DataPool.ReadLocal(path)
    --Application.persistentDataPath.."/dongtaitupian/test.txt"
    local file = io.open(path, "r");
    if file == nil then
        return "";
    end
    local str = file:read("*a"); -- 读取所有内容
    file:close();
    return str;
end
