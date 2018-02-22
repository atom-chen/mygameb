--
-- Author: gerry
-- Date: 2015-11-26 15:08:53
--
local GameUtils = require("app.core.GameUtils")
local GameConfig = require("app.core.GameConfig")
local ControllerBase = require("app.controllers.ControllerBase")
local scheduler = require("framework.scheduler")
local PokerPuzzleGameController = class("PokerPuzzleGameController", ControllerBase)
local GlobalStatus = APP:getObject("GlobalStatus")
local utils = require("app.common.utils")
local GameMapConfig = require("app.core.Game.PokerPuzzleGameConfig")
local GamePokerPuzzleLogic = require("app.gamelogic.GamePokerPuzzleLogic")

function PokerPuzzleGameController:ctor()
	-- print("os time 1: ", os.time())
	-- print("os time 2: ", tostring(os.time()):reverse():sub(1, 6))
	-- print("socket time 1: ", socket.gettime())
	-- print("socket time 2: ", tostring(socket.gettime()):reverse():sub(1, 6))
    PokerPuzzleGameController.super.ctor(self)
    display.addSpriteFrames("image/plist_list/pokers_g.plist", "image/plist_list/pokers_g.png")
    self._SCORE = 0
    self._MAP_XY = {}
    self._MAP_MIN_X = 0
    self._MAP_MIN_Y = 0
    self._MAP_MAX_X = 0
    self._MAP_MAX_Y = 0
    self._MAP_CELL_X = {}

    self._NUM_VO_LIST = {}
    self._ROCK_LIST = {}
    self._NUM_OBJ_LIST = {}

    self._touchStep = 1
    self._changeA = nil
    self._changeB = nil
    
    self._mapView = APP:createView("PokerPuzzleGame.GameMapNode")
        :addTo(self, GameMapConfig._GameMapNode_Zorder)

    self._uiView = APP:createView("PokerPuzzleGame.GameUINode")
    	:addTo(self, GameMapConfig._GameUINode_Zorder)

    self._rockLayer = display.newNode()
    	:addTo(self, GameMapConfig._GameRockNode_Zorder)
    self._pokerLayer = display.newNode()
    	:addTo(self, GameMapConfig._GameNumNode_Zorder)
    
    self:startGame()
    -- test

	
end

function PokerPuzzleGameController:onEnter()
	PokerPuzzleGameController.super.onEnter(self)
    self._handelA = scheduler.scheduleGlobal(handler(self, self.onCollisionA), 0)
    -- self._handelB = scheduler.scheduleGlobal(handler(self, self.onCollisionB), 0)
    --
    
end

function PokerPuzzleGameController:onExit()
    PokerPuzzleGameController.super.onExit(self)
    scheduler.unscheduleGlobal(self._handelA)

    display.removeSpriteFramesWithFile("image/plist_list/pokers_g.plist")
end




-------------------------------
-------- onCollision ----------
-------------------------------
function PokerPuzzleGameController:onCollisionA(dt)
	
end

function PokerPuzzleGameController:onCollisionB(dt)
	-- self._bgView:onCollision(dt)
end
-------------------------------
-------- onCollision end ------
-------------------------------

function PokerPuzzleGameController:startGame()
	self:gameCreateMap()
end

function PokerPuzzleGameController:restartGame()
	

end


function PokerPuzzleGameController:gameCreateMap()
    -- APP:createView("PokerPuzzleGame.GameRockNode", 4, 1, 1, 6, GameMapConfig.DIR_TORIGHT)
    --    :addTo(self, GameMapConfig._GameRockNode_Zorder)

    -- APP:createView("PokerPuzzleGame.GameRockNode", 4, 2, 5, 1, GameMapConfig.DIR_TOLEFT)
    --    :addTo(self, GameMapConfig._GameRockNode_Zorder)

    -- APP:createView("PokerPuzzleGame.GameRockNode", 4, 3, 2, 2, GameMapConfig.DIR_TOUP)
    --    :addTo(self, GameMapConfig._GameRockNode_Zorder)

    -- APP:createView("PokerPuzzleGame.GameRockNode", 4, 4, 4, 5, GameMapConfig.DIR_TODOWN)
    --    :addTo(self, GameMapConfig._GameRockNode_Zorder)


    local _index = 1
    GamePokerPuzzleLogic.autoCreateTypeA(function(res)
            for _,v in ipairs(res) do
                local _Rock = APP:createView("PokerPuzzleGame.GameRockNode", v.len, v.color, v.xid, v.yid, v.dir, _index)
                    :addTo(self._rockLayer, _index)
                _index = _index+1

                table.insert(self._ROCK_LIST, _Rock)
                

            end

            --
            self:runAction(cca.seq({
                cca.delay(0.5),
                cca.cb(function()
                        GamePokerPuzzleLogic.autoCreatePoker(self._ROCK_LIST, function(_res)
                            for _,_resObj in ipairs(_res) do
                                local _poker = APP:createView("PokerPuzzleGame.GamePokerNode", _resObj.id, _resObj.poker)
                                    :addTo(self._pokerLayer)
                            end

                        end)
                end),
            }))
            

        end)



end





return PokerPuzzleGameController