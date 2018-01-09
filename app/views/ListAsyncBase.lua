local GlobalStatus = APP:getObject("GlobalStatus")
local protocols = require("app.protocol.init")

local ListAsyncBase = class("ListAsyncBase", function()
    return display.newNode()
end)

function ListAsyncBase:ctor(contents, itemName, clickFunc, width, height, startPos, endPos,scrollFunc)
    self._contents = contents
    self._items = {}
    self._itemName = itemName
    self._clickFunc = clickFunc
    self._scrollFunc = scrollFunc
    self._isFinish = false
    
    startPos = startPos or 0
    endPos = endPos or 0
    width = width or display.width
    height = height or display.height - 80

    -- local node = APP:createView(self._itemName, self._contents[1])
    -- self._itemHeight = node._itemHeight
    local item = require("app.views." .. itemName)
    self._itemHeight = item._itemHeight
    
    self._listView = cc.ui.UIListView.new({
        viewRect = cc.rect(startPos, endPos, width, height),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        touchOnContent = false,
        async = true
        })
        :addTo(self)
    self._listView:setCascadeOpacityEnabled(true)
    self._listView.container:setCascadeOpacityEnabled(true) 
    self._listView:setDelegate(handler(self, self.listDelegate))
    self._listView:setCascadeOpacityEnabled(true)
    self._listView.container:setCascadeOpacityEnabled(true)
    self._listView:onTouch(handler(self, self.handleTouch))
    self._listView:reload()
    
    -- if self._listView.addHideItem_ then
    --     for i = 1, self:listDelegate(self._listView, cc.ui.UIListView.COUNT_TAG) do
    --         if not self._items[i] then
    --             local item, findExist = self:listDelegate(self._listView, cc.ui.UIListView.CELL_TAG, i)
    --             assert(not findExist, "xxxxxxx")
    --             item.idx_ = i
    --             self._listView.container:addChild(item)
    --             item:hide()

    --             self._listView:addHideItem_(item)
    --         end
    --     end
    -- end

    --self:runAction(cca.seq({cca.delay(4.0),cca.cb(function() self._listView:scrollToBottom(100) end)}))
    
    --self:runAction(cca.seq({cca.delay(5.0),cca.callFunc(function() self:addContents(clone(self._contents),true) end)}))
    -- self:runAction(cca.seq({cca.delay(5.0),cca.callFunc(function() 
    --     local x = clone(self._contents[3])
    --     x.create_time = os.time()
    --     local m = {message_type = SqliteLogic._messageTypeTime, content = os.time()}
    --     self:addContents({m,x}) 
    -- end)}))
end

function ListAsyncBase:setContentsAndRefresh(contents)
    self._items = {}
    self._listView.itemsHide_ = {}
    self._contents = contents
    self._listView:reload()
end

function ListAsyncBase:addContents(contents,top,isScroll,noMove)
    if top then
        local count = #self._contents
        for i=1,#contents do
            table.insert(self._contents, 1, contents[i])
        end
        self._listView:AddItemByIndex(#self._contents - count,top,noMove)
    else
        for i=1,#contents do
            table.insert(self._contents, contents[i])
        end
        if isScroll then
            self._listView:scrollToBottom(80)
        end
    end
end

function ListAsyncBase:listDelegate(listView, tag, idx)
    -- printInfo("ListAsyncBase:listDelegate tag:%s, idx:%s", tostring(tag), tostring(idx))
    
    if cc.ui.UIListView.COUNT_TAG == tag then
        return #self._contents

    elseif cc.ui.UIListView.CELL_SIZE_TAG == tag then
        -- local node = APP:createView(self._itemName, self._contents[idx])
        -- return display.width, node._itemHeight
        return display.width, self._itemHeight

    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content
        local findExist = false

        if self._listView.itemsHide_ then
            item = self._listView.itemsHide_[idx]
        end
        
        if item then
            findExist = true
            -- printInfo("findExist: " .. idx)
        else
            -- printInfo("not findExist: " .. idx)
            item = self._listView:dequeueItem()
            if not item then
                item = self._listView:newItem()
                item:setCascadeOpacityEnabled(true)

                content = display.newNode()
                content:setCascadeOpacityEnabled(true)
                item:addContent(content)
            else
                item:setCascadeOpacityEnabled(true)
                content = item:getContent()
                content:setCascadeOpacityEnabled(true)
            end

            content:removeAllChildren()
            local node = APP:createView(self._itemName, 
                    self._contents[idx],self._clickFunc)
            node:addTo(content)

            self._items[idx] = node       

            item:setItemSize(display.width, self._itemHeight)
        end

        return item, findExist
    else
    end	
end

function ListAsyncBase:removeItemByIdx(idx,amin)
    if idx then
        table.remove(self._contents, idx)
        table.remove(self._items,idx)
        self._listView:removeItemAsync(#self._contents,idx,nil,amin)
    end
end

function ListAsyncBase:scrollToBottom(minHeight, cb)
    self._listView:scrollToBottom(minHeight,cb)
end

function ListAsyncBase:removeItem(checkFunc,amin,args)
    for i,v in ipairs(self._contents) do
        local check,ucheck = checkFunc(self._contents,i,args)
        if check then
            table.remove(self._contents, i)
            table.remove(self._items,i)
            if ucheck then
                table.remove(self._contents, i-1)
                table.remove(self._items,i - 1)
            end
            self._listView:removeItemAsync(#self._contents,i,ucheck,amin)
            break
        end
    end
end

function ListAsyncBase:updateItem(params)
    -- dump(self._items)
    for _,v in pairs(self._listView.items_) do
        if self._items[v.idx_] then
            self._items[v.idx_]:updateItem(params,self._contents)
        end
    end
    if self._listView.itemsHide_ then
        for _,v in pairs(self._listView.itemsHide_) do
            -- printInfo("---------" .. v.idx_)
            if self._items[v.idx_] then
                self._items[v.idx_]:updateItem(params,self._contents)
            end
        end
    end
end

function ListAsyncBase:handleTouch(event)
    if self._scrollFunc then
        if self._isFinish == false then
            local overflow, top = self._listView:getOverflow()
            if top == false and event.name == "moved" and overflow >= 85 and self._tipSprite == nil and self._loadingSprite == nil then
                local width,height = self._listView.items_[1]:getItemSize()
                local y = self._listView.items_[#self._listView.items_]:getPositionY()
                self._tipSprite = display.newSprite("image/tearoom/tearoom_tips_5.png")
                                    :align(display.CENTER, display.cx- 250, y - 20)
                                    :addTo(self._listView.container)
                -- self._tipSprite = cc.ui.UILabel.new({
                --     color=cc.c3b(120, 20, 125),
                --     UILabelType = 2, text = "放开开始刷新", size = 44})
                -- :align(display.CENTER, display.cx- 250, y - 20)
                -- :addTo(self._listView.container)
            end
            if event.name == "ended" then
                if self._tipSprite then
                    self._tipSprite:removeFromParent()
                    self._tipSprite = nil
                end

                if top == false and overflow >= 85 and self._loadingSprite == nil then
                    local width,height = self._listView.items_[1]:getItemSize()
                    local y = self._listView.items_[#self._listView.items_]:getPositionY()
                    self._loadingSprite = display.newSprite("image/tearoom/tearoom_tips_3.png")
                                            :align(display.CENTER, display.cx - 250, y - 20)
                                            :addTo(self._listView.container) 
                    -- self._loadingSprite = cc.ui.UILabel.new({
                    --     color=cc.c3b(120, 20, 125),
                    --     UILabelType = 2, text = "正在获取中", size = 44})
                    -- :align(display.CENTER, display.cx - 250, y - 20)
                    -- :addTo(self._listView.container) 
                    self:runAction(cca.seq({cca.delay(0.5),cca.callFunc(function()  
                        self._loadingSprite:removeFromParent()
                        self._loadingSprite = nil
                        self._listView:elasticScroll()
                        dump("run _scrollFunc")
                        self._scrollFunc()
                    end)})) 
                end
            end 
        elseif #self._contents >= 20 then
            --todo
            local overflow, top = self._listView:getOverflow()
            if top == false and event.name == "moved" and overflow >= 85 and self._tipSprite == nil and self._loadingSprite == nil then
                local width,height = self._listView.items_[1]:getItemSize()
                local y = self._listView.items_[#self._listView.items_]:getPositionY()
                self._tipSprite = display.newSprite("image/tearoom/tearoom_tips_4.png")
                                    :align(display.CENTER, display.cx- 250, y - 20)
                                    :addTo(self._listView.container)
            end
            if event.name == "ended" then
                if self._tipSprite then
                    self._tipSprite:removeFromParent()
                    self._tipSprite = nil
                end
            end 
        end
    end
end

return ListAsyncBase