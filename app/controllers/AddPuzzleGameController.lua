--
-- Author: gerry
-- Date: 2015-11-26 15:08:53
--
local GameUtils = require("app.core.GameUtils")
local GameConfig = require("app.core.GameConfig")
local ControllerBase = require("app.controllers.ControllerBase")
local scheduler = require("framework.scheduler")
local AddPuzzleGameController = class("AddPuzzleGameController", ControllerBase)
local GlobalStatus = APP:getObject("GlobalStatus")
local utils = require("app.common.utils")
local GameMapConfig = require("app.core.Game.AddPuzzleGameConfig")


function AddPuzzleGameController:ctor()
	-- print("os time 1: ", os.time())
	-- print("os time 2: ", tostring(os.time()):reverse():sub(1, 6))
	-- print("socket time 1: ", socket.gettime())
	-- print("socket time 2: ", tostring(socket.gettime()):reverse():sub(1, 6))
    AddPuzzleGameController.super.ctor(self)
    self._SCORE = 0
    self._MAP_XY = {}
    self._MAP_MIN_X = 0
    self._MAP_MIN_Y = 0
    self._MAP_MAX_X = 0
    self._MAP_MAX_Y = 0
    self._MAP_CELL_X = {}
    
    self._mapView = APP:createView("AddPuzzleGame.GameMapNode")
        :addTo(self, GameMapConfig._GameMapNode_Zorder)

    self:gameCreateMap()

	
end

function AddPuzzleGameController:onEnter()
	AddPuzzleGameController.super.onEnter(self)
    self._handelA = scheduler.scheduleGlobal(handler(self, self.onCollisionA), 0)
    -- self._handelB = scheduler.scheduleGlobal(handler(self, self.onCollisionB), 0)
end

function AddPuzzleGameController:onExit()
    AddPuzzleGameController.super.onExit(self)
    scheduler.unscheduleGlobal(self._handelA)
end




-------------------------------
-------- onCollision ----------
-------------------------------
function AddPuzzleGameController:onCollisionA(dt)
	
end

function AddPuzzleGameController:onCollisionB(dt)
	-- self._bgView:onCollision(dt)
end
-------------------------------
-------- onCollision end ------
-------------------------------




function AddPuzzleGameController:gameCreateMap()
	

end













return AddPuzzleGameController