--
-- Author: gerry
-- Date: 2015-11-26 15:08:53
--
local GameUtils = require("app.core.GameUtils")
local GameConfig = require("app.core.GameConfig")
local ControllerBase = require("app.controllers.ControllerBase")
local scheduler = require("framework.scheduler")
local HomeController = class("HomeController", ControllerBase)
local GlobalStatus = APP:getObject("GlobalStatus")
local utils = require("app.common.utils")
local GameMapConfig = require("app.core.GameMapConfig")
local protocols = require("app.protocol.init")

function HomeController:ctor()
    self._lock = false

    HomeController.super.ctor(self)

    self:test()

end

function HomeController:onEnter()
	HomeController.super.onEnter(self)
end

function HomeController:onExit()
    HomeController.super.onExit(self)
end

function HomeController:test()

    APP:createView("TableMessageNode",{x =display.width-130, y=146})
        :addTo(self,15)

    local request = protocols.base_pb.EnterRoomRequest()
    SOCKET_MANAGER.send(protocols.command_pb.CMD_ENTER_ROOM_REQ, request)  

end





return HomeController