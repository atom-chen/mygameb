
local protocols = {}

require("protobuf")

protocols.packet_pb = require("packet_pb")
protocols.command_pb = require("command_pb")
protocols.base_pb = require("base_pb")
protocols.message_pb = require("message_pb")
protocols.game_pb = require("game_pb")

protocols.PacketBuffer = require("app.protocol.PacketBuffer")
protocols.Protocol = require("app.protocol.Protocol")

return protocols