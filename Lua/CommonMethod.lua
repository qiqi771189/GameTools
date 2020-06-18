-----------------------字典排序---------------------------
-- 目的：将同一份数据即可以排序后顺序遍历，也保持字典按 --
--       Key取值的数据访问方式。                        --
-- 注意：此处是使用了两个方法配合使用。在使用DirParis时,--
--       仍需在外部保持一个顺序增加的局部变量以确保是   --
--       顺序遍历。                                     --
----------------------------------------------------------
---sortTable:需要排序的table
---funCom:排序方法
---return 排序后的table
function table.DirSort(sortTable, funCom)
    if type(sortTable) ~= "table" or type(funCom) ~= "function" then
        return
    end
    local arrTable = {}
    local restTable = {}
    for i, v in pairs(sortTable) do
        v.m__Key = i
        table.insert(arrTable, v)
    end
    table.sort(arrTable, funCom)
    for i = #arrTable, 1, -1 do
        local v = arrTable[i]
        restTable[v.m__Key] = v
        restTable[v.m__Key].m__Pos = i
        v.m__Key = nil
    end
    return restTable
end

-- 对排序后的字典进行迭代
-- tip：需要在使用了table.DirSort方法后才可使用本方法
--- sortedTable：排序后的table
function DirParis(sortedTable)
    if type(sortedTable) ~= "table" or get_table_count(sortedTable) < 1 then
        return pairs(sortedTable)
    end
    local keys = {}
    for i, v in pairs(sortedTable) do
        if v.m__Pos == nil then
            return
        end
        keys[v.m__Pos] = i
    end
    local i = 0
    local iter = function()
        i = i + 1
        if keys[i] == nil then
            return nil
        else
            return keys[i], sortedTable[keys[i]]
        end
    end
    return iter
end

-----------------------取小数点后N位----------------------
-- 目的：直接舍弃小数点N位后内容                        --
----------------------------------------------------------
function GetDecimal(Num,N)
    if N < 0 then
        N = 0
    end
    return Num - Num % (0.1^N)
end

---------------------------限制---------------------------
-- 目的：将Value限制在min和max之间                      --
----------------------------------------------------------
---value 数值
---min 最小值
---max 最大值
function math.Clamp(value, min, max)
    if type(value) ~= "number" or type(min) ~= "number" or type(max) ~= "number" then
        logError("参数类型错误")
        return value
    end
    return value <= min and min or (value >= max and max or value)
end

---------------------------插值---------------------------
-- 目的：获得在form到to之间的插值                       --
----------------------------------------------------------
---from 起始值
---to   目标值
---step 插值比例
function math.lerp(from, to, step)
    if type(from) ~= "number" or type(to) ~= "number" or type(step) ~= "number" then
        return from
    end
    return from + (to - from) * math.Clamp(step, 0, 1)
end
