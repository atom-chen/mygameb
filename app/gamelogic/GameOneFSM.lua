local GameConfig = require("app.core.GameConfig")
local protocols = require("app.protocol.init")
local GameOneFSM = class("GameOneFSM")

function GameOneFSM:ctor()
    self._GameController = APP:getObject("GameController")
    self._upTime = 0
    self._state = {
                    down="down",
                    clean="clean",
                    up="up",
                    done="done"
                }  
    self._nowState = self._state.done
end


function GameOneFSM:getstate()  
    return self._nowState
end 


function GameOneFSM:getNextState()
    local _nextState = ""
    if self._nowState == self._state.down then
        _nextState = self._state.clean
    elseif self._nowState == self._state.clean then
        if self._GameController._cleanTimes == 0 then
            if self._upTime == 0 then
                _nextState = self._state.up
            else
                _nextState = self._state.done
            end
        else
            _nextState = self._state.down
        end

    elseif self._nowState == self._state.up then
        _nextState = self._state.down
    elseif self._nowState == self._state.done then
        _nextState = self._state.down
    end
    return _nextState
end


function GameOneFSM:doEvent(var)
    if var == self._state.down then
        if self:canDown() then
            self._nowState = self._state.down
        end

    elseif var == self._state.clean then
        if self:canClean() then
            self._nowState = self._state.clean
        end

    elseif var == self._state.up then
        if self:canUp() then
            self._upTime = 1
            self._nowState = self._state.up
        end

    elseif var == self._state.done then
        if self:canDone() then
            self._upTime = 0
            self._nowState = self._state.done
        end

    end
end


function GameOneFSM:canDown()
    if self._nowState == self._state.done 
    or self._nowState == self._state.up then
        return true
    end
    return false
end


function GameOneFSM:canClean()
    if self._nowState == self._state.down then
        return true
    end
    return false
end


function GameOneFSM:canUp()
    if self._nowState == self._state.clean
    and self._upTime == 0 then
        return true
    end
    return false
end


function GameOneFSM:canDone()
    if self._nowState == self._state.clean then
        return true
    end
    return false
end



return GameOneFSM


