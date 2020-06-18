-----------------------事件管理器-------------------------
-- 目的：事件的监听与分发管理                           --
----------------------------------------------------------

EventController={
    Events = {},
    EventUID = 0,                   -- 事件唯一ID，只增不减
}
EventController.__index = EventController

-- 注册事件
-- eventType 事件类型
-- handler 回调
function EventController.RegisterEvent(eventType,handler)
    if nil == eventType or nil == handler then
        logError("传入了空的事件类型或回调")
        return EventController.EventUID + 1
    end
    if not EventController.Events[eventType] or #EventController.Events <= 0 then
        EventController.Events[eventType] = {}
    end
    EventController.EventUID = EventController.EventUID + 1
    EventController.Events[eventType][EventController.EventUID] = handler
    logError("注册了消息："..eventType)
    return EventController.EventUID
end

-- 反注册消息
-- eventType 事件类型
-- eventID 事件的唯一ID
function EventController.UnRegisterEvent(eventType,eventID)
    if not EventController.Events[eventType] then
        return
    end
    if not EventController.Events[eventType][eventID] then
        logError("没有找到需要注销的消息："..eventType.." ID:"..eventID)
        return
    else
        logError("注销了消息："..eventType)
        EventController.Events[eventType][eventID] = nil
        --table.removeItem(EventController.Events[eventType], EventController.Events[eventType][eventID])
    end
end

---清空 EventType 对应的所有Handler
function EventController.UnRegisterEventByType(eventType)
    if not EventController.Events[eventType] then
        return
    end
    EventController.Events[eventType] = {}
end

-- 消息派发
function EventController.DispatchEvent(eventType,...)
    if not EventController.Events[eventType] then
        return
    end
    for k, v in pairs(EventController.Events[eventType]) do
        if v then
            v(...)
        end
    end
end

function EventController.ClearAllEvents()
    EventController.Events={}
    EventController.EventUID = 0
end