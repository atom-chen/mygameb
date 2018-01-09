
local bevtree = {}

-- behaviour status
bevtree.BH_INVALID = 0
bevtree.BH_RUNNING = 1
bevtree.BH_FINISHED = 2
bevtree.BH_FAILURE = 3

---------------------------------------------------------

local Node = class("Node")

function Node:ctor()
end

function Node:createTask()
    assert(0, "not implemented")
end

function Node:destroyTask(task)
end

---------------------------------------------------------

local CompositeNode = class("CompositeNode", Node)

function CompositeNode:ctor()
    CompositeNode.super.ctor(self)
    self._children = {}
end

function CompositeNode:getChildrenCount()
    return #self._children
end

function CompositeNode:getChild(index)
    if index < 1 or index > #self._children then
        return nil
    else
        return self._children[index]
    end
end

function CompositeNode:addChild(node)
    table.insert(self._children, node)
    return self
end

---------------------------------------------------------

local Behavior = class("Behavior")

function Behavior:ctor(node)
    self._task = nil
    self._node = nil
    self._status = bevtree.BH_INVALID
    if node then self:install(node) end
end

function Behavior:hasInstalled()
    return self._task ~= nil
end

function Behavior:install(node)
    self:uninstall()

    -- print("install", node._taskType.__cname)
    self._node = node
    self._task = node:createTask()
    self._status = bevtree.BH_INVALID
end

function Behavior:uninstall()
    if not self._task then
        return
    end

    -- print("uninstall", self._node._taskType.__cname)
    self._node:destroyTask(self._task)
    self._task = nil
end

function Behavior:evaluate(input)
    assert(self._task)
    return self._task:evaluate(input)
end

function Behavior:update(input, output)
    -- print("update", self._node._taskType.__cname)
    if self._status ~= bevtree.BH_RUNNING then
        self._task:onInit(input)
    end

    self._status = self._task:onUpdate(input, output)

    if self._status ~= bevtree.BH_RUNNING then
        self._task:onTerminate(input)
    end

    return self._status
end

---------------------------------------------------------

local Task = class("Task")

function Task:ctor(node)
    self._node = node
end

function Task:evaluate(input)
    assert(0, "not implemented")
end

function Task:onInit(input)
end

function Task:onUpdate(input, output)
    assert(0, "not implemented")
end

function Task:onTerminate(input)
end

---------------------------------------------------------

local PrioritySelectorTask = class("PrioritySelectorTask", Task)

function PrioritySelectorTask:ctor(node)
    PrioritySelectorTask.super.ctor(self, node)
    self._currentIndex = 0
    self._behavior = Behavior.new()
end

function PrioritySelectorTask:evaluate(input)
    return true
end

function PrioritySelectorTask:onInit(input)
    assert(self._currentIndex < 1, self._currentIndex)
    assert(self._node:getChildrenCount() > 0)
    assert(not self._behavior:hasInstalled())
    self._currentIndex = 1
    self._behavior:install(self._node:getChild(1))
end

function PrioritySelectorTask:onUpdate(input, output)
    -- test which child to run, from begin to end
    local tempBehavior = Behavior.new()
    local i = 1
    while i <= self._node:getChildrenCount() do
        tempBehavior:install(self._node:getChild(i))
        if tempBehavior:evaluate(input) then
            break
        end
        i = i + 1
    end

    -- if valid child not change, don't install/uninstall again
    if i > self._node:getChildrenCount() then
        return bevtree.BH_INVALID
    elseif i ~= self._currentIndex then
        self._currentIndex = i
        self._behavior:install(self._node:getChild(i))
    end

    assert(self._behavior:evaluate(input))
    return self._behavior:update(input, output)
end

function PrioritySelectorTask:onTerminate(input)
    self._currentIndex = 0
    self._behavior:uninstall()
end

---------------------------------------------------------

local NonPrioritySelectorTask = class("NonPrioritySelectorTask", Task)

function NonPrioritySelectorTask:ctor(node)
    NonPrioritySelectorTask.super.ctor(self, node)
    self._currentIndex = 0
    self._behavior = Behavior.new()
end

function NonPrioritySelectorTask:evaluate(input)
    return true
end

function NonPrioritySelectorTask:onInit(input)
    assert(self._currentIndex < 1)
    assert(self._node:getChildrenCount() > 0)
    assert(not self._behavior:hasInstalled())
    self._currentIndex = 1
    self._behavior:install(self._node:getChild(1))
end

function NonPrioritySelectorTask:onUpdate(input, output)
    -- run current task
    if self._behavior:hasInstalled() then
        assert(self._currentIndex >= 1)
        if self._behavior:evaluate(input) then
            return self._behavior:update(input, output)
        end
    end

    -- run from begin to end, except 'currentIndex'
    local i = 1
    while i <= self._node:getChildrenCount() do
        if i ~= self._currentIndex then
            self._behavior:install(self._node:getChild(i))
            if self._behavior:evaluate(input) then
                return self._behavior:update(input, output)
            end
        end
        i = i + 1
    end

    return bevtree.BH_INVALID
end

function NonPrioritySelectorTask:onTerminate(input)
    self._currentIndex = 0
    self._behavior:uninstall()
end

---------------------------------------------------------

local SequenceTask = class("SequenceTask", Task)

function SequenceTask:ctor(node)
    SequenceTask.super.ctor(self, node)
    self._currentIndex = 0
    self._behavior = Behavior.new()
end

function SequenceTask:evaluate(input)

    if self._node:getChildrenCount() == 0 then
        return false
    end

    local behavior = Behavior.new()
    if self._currentIndex == 0 then
        behavior:install(self._node:getChild(1))
        return behavior:evaluate(input)
    else
        behavior:install(self._node:getChild(self._currentIndex))
        return behavior:evaluate(input)
    end
    return true
end

function SequenceTask:onInit(input)
    assert(self._currentIndex < 1)
    assert(self._node:getChildrenCount() > 0)
    assert(not self._behavior:hasInstalled())
    self._currentIndex = 1
    self._behavior:install(self._node:getChild(1))
end

function SequenceTask:onUpdate(input, output)
    assert(self._currentIndex >= 1)
    assert(self._behavior:hasInstalled())

    if self._behavior:evaluate(input) then
        local status = self._behavior:update(input, output)
        if status ~= bevtree.BH_RUNNING then
            if self._currentIndex == self._node:getChildrenCount() then
                return bevtree.BH_FINISHED
            else
                self._currentIndex = self._currentIndex + 1
                self._behavior:install(self._node:getChild(self._currentIndex))
                return bevtree.BH_RUNNING
            end
        else
            return bevtree.BH_RUNNING
        end
    else
        if self._currentIndex == self._node:getChildrenCount() then
            return bevtree.BH_FINISHED
        else
            self._currentIndex = self._currentIndex + 1
            self._behavior:install(self._node:getChild(self._currentIndex))
            return bevtree.BH_RUNNING
        end
    end
end

function SequenceTask:onTerminate(input)
    self._currentIndex = 0
    self._behavior:uninstall()
end

---------------------------------------------------------

local ParallelANDTask = class("ParallelANDTask", Task)

function ParallelANDTask:ctor(node)
    ParallelANDTask.super.ctor(self, node)
    self._behaviors = {}
    for _ in pairs(self._node._children) do
        table.insert(self._behaviors, Behavior.new())
    end
end

function ParallelANDTask:evaluate(input)
    local behavior = Behavior.new()
    for i, child in pairs(self._node._children) do
        behavior:install(child)
        if behavior:evaluate(input) then
            return true
        end
    end
    return false
end

function ParallelANDTask:onInit(input)
    assert(#self._behaviors == self._node:getChildrenCount())

    for i, child in pairs(self._node._children) do
        self._behaviors[i]:install(child)
    end
end

function ParallelANDTask:onUpdate(input, output)
    local allFinished = true
    for _, behavior in pairs(self._behaviors) do
        if behavior:evaluate(input) then
            local status = behavior:update(input, output)
            if status == bevtree.BH_INVALID or status == bevtree.BH_FAILURE then
                return status
            elseif status ~= bevtree.BH_FINISHED then
                allFinished = false
            end
        end
    end
    if allFinished then
        return bevtree.BH_FINISHED
    else
        return bevtree.BH_RUNNING
    end
end

function ParallelANDTask:onTerminate(input)
    for _, behavior in pairs(self._behaviors) do
        behavior:uninstall()
    end
    self._behaviors = {}
end

---------------------------------------------------------

local ParallelORTask = class("ParallelORTask", Task)

function ParallelORTask:ctor(node)
    ParallelORTask.super.ctor(self, node)
    self._behaviors = {}
    for _ in pairs(self._node._children) do
        table.insert(self._behaviors, Behavior.new())
    end
end

function ParallelORTask:evaluate(input)
    local behavior = Behavior.new()
    for i, child in pairs(self._node._children) do
        behavior:install(child)
        if behavior:evaluate(input) then
            return true
        end
    end
    return false
end

function ParallelORTask:onInit(input)
    assert(#self._behaviors == self._node:getChildrenCount())

    for i, child in pairs(self._node._children) do
        self._behaviors[i]:install(child)
    end
end

function ParallelORTask:onUpdate(input, output)
    for _, behavior in pairs(self._behaviors) do
        if behavior:evaluate(input) then
            local status = behavior:update(input, output)
            if status == bevtree.BH_INVALID or status == bevtree.BH_FAILURE then
                return status
            elseif status == bevtree.BH_FINISHED then
                return bevtree.BH_FINISHED
            end
        end
    end
    return bevtree.BH_RUNNING
end

function ParallelORTask:onTerminate(input)
    for _, behavior in pairs(self._behaviors) do
        behavior:uninstall()
    end
    self._behaviors = {}
end

---------------------------------------------------------

local ActionNode = class("ActionNode", Node)

function ActionNode:ctor(taskType)
    ActionNode.super.ctor(self)
    self._taskType = taskType
end

function ActionNode:createTask()
    return self._taskType.new()
end

---------------------------------------------------------

local CompositeControlNode = class("CompositeControlNode", CompositeNode)

function CompositeControlNode:ctor(taskType)
    CompositeControlNode.super.ctor(self)
    self._taskType = taskType
end

function CompositeControlNode:createTask()
    return self._taskType.new(self)
end

---------------------------------------------------------

bevtree.CompositeNode = CompositeNode
bevtree.Behavior = Behavior
bevtree.Task = Task
bevtree.PrioritySelectorTask = PrioritySelectorTask
bevtree.NonPrioritySelectorTask = NonPrioritySelectorTask
bevtree.SequenceTask = SequenceTask
bevtree.ParallelANDTask = ParallelANDTask
bevtree.ParallelORTask = ParallelORTask
bevtree.ActionNode = ActionNode
bevtree.CompositeControlNode = CompositeControlNode

return bevtree