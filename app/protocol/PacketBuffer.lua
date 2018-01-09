--[[
PacketBuffer receive the byte stream and analyze them, then pack them into a message packet.
The method name, message metedata and message body will be splited, and return to invoker.
@see https://github.com/zrong/as3/blob/master/src/org/zengrong/net/PacketBuffer.as
@author zrong(zengrong.net)
Creation: 2013-11-14
]]
cc.utils = require("framework.cc.utils.init")
cc.net = require("framework.cc.net.init")
local PacketBuffer = class("PacketBuffer")
local packet_pb = require("packet_pb")

PacketBuffer.ENDIAN = cc.utils.ByteArray.ENDIAN_BIG

--[[
packet bit structure
BODY_LEN int|BODY bytes|
]]
PacketBuffer.BODY_LEN = 4	-- length of message body, int

function PacketBuffer.getBaseBA()
	return cc.utils.ByteArray.new(PacketBuffer.ENDIAN)
end

function PacketBuffer._createHeader(payloadPB)
	local buffer = PacketBuffer.getBaseBA()
	buffer:writeInt(payloadPB:ByteSize())
	return buffer 
end

function PacketBuffer._parseHeader(buffer)
	return buffer:readInt()
end

function PacketBuffer._createBody(packet)
	local buffer = PacketBuffer.getBaseBA()
	buffer:writeString(packet:SerializeToString())
	return buffer
end

function PacketBuffer._parseBody(buffer, length)
	local packet = packet_pb.Packet()
	packet:ParseFromString(buffer:readString(length))
	return packet
end

--- Create a formated packet that to send server
-- @param __msgDef the define of message, a table
-- @param __msgBodyTable the message body with key&value, a table
function PacketBuffer.createPacket(type, payloadPB)
	local buffer = PacketBuffer.getBaseBA()
	local packet = packet_pb.Packet()
	packet.type = type
	packet.payload = payloadPB:SerializeToString()
	local headerBuffer = PacketBuffer._createHeader(packet)
	local bodyBuffer = PacketBuffer._createBody(packet)
	-- printInfo("headerBuffer:", headerBuffer:getLen())
	-- printInfo("bodyBuffer:", bodyBuffer:getLen())
	buffer:writeBytes(headerBuffer)
	buffer:writeBytes(bodyBuffer)
	return buffer
end

function PacketBuffer:ctor()
	self:init()
end

function PacketBuffer:init()
	self._buffer = PacketBuffer.getBaseBA()
end

--- Get a byte stream and analyze it, return a splited table
-- Generally, the table include a message, but if it receive 2 packets meanwhile, then it includs 2 messages.
function PacketBuffer:parsePackets(__byteString)
	local __msgs = {}
	local __pos = 0
	self._buffer:setPos(self._buffer:getLen() + 1)
	self._buffer:writeBuf(__byteString)
	self._buffer:setPos(1)
	local __flag1 = nil
	local __flag2 = nil
	local __preLen = PacketBuffer.BODY_LEN
	-- printInfo("start analyzing... buffer len: %u, available: %u", self._buffer:getLen(), self._buffer:getAvailable())
	while self._buffer:getAvailable() >= __preLen do
		local __bodyLen = self._buffer:readInt()
		local __pos = self._buffer:getPos()
		-- printInfo("\t\tbody lenth:%u", __bodyLen)
		-- buffer is not enougth, waiting...
		if self._buffer:getAvailable() < __bodyLen then 
			-- restore the position to the head of data, behind while loop, 
			-- we will save this incomplete buffer in a new buffer,
			-- and wait next parsePackets performation.
			-- printInfo("\t\treceived data is not enough, waiting... need %u, get %u", __bodyLen, self._buffer:getAvailable())
			-- printInfo("\t\tbuffer: ", self._buffer:toString())
			self._buffer:setPos(self._buffer:getPos() - __preLen)
			break 
		end

		local packet = PacketBuffer._parseBody(self._buffer, __bodyLen)
		assert(packet ~= nil)
		__msgs[#__msgs+1] = packet
		-- printInfo("\t\tafter get body position:%u", self._buffer:getPos())
	end
	-- clear buffer on exhausted
	if self._buffer:getAvailable() <= 0 then
		self:init()
	else
		-- some datas in buffer yet, write them to a new blank buffer.
		-- printInfo("cache incomplete buff, len: %u, available: %u", self._buffer:getLen(), self._buffer:getAvailable())
		local __tmp = PacketBuffer.getBaseBA()
		self._buffer:readBytes(__tmp, 1, self._buffer:getAvailable())
		self._buffer = __tmp
		-- printInfo("tmp len: %u, available: %u", __tmp:getLen(), __tmp:getAvailable())
		-- printInfo("buffer:", __tmp:toString())
	end
	return __msgs
end

return PacketBuffer
