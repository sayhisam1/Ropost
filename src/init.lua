local RopostMethods = require(script.RopostMethods)
local ChannelDefinition = require(script.ChannelDefinition)

local ropost = {}

ropost.subscribe = RopostMethods.subscribe
ropost.publish = RopostMethods.publish

ropost.channel = function(channel)
	return ChannelDefinition.new(channel)
end

return ropost
