local RopostMethods = require(script.Parent.RopostMethods)

local ChannelDefinition = {}
ChannelDefinition.__index = ChannelDefinition

function ChannelDefinition.new(channel)
	local self = setmetatable({
		channel = channel,
		unsubscribers = {},
	}, ChannelDefinition)
	return self
end

function ChannelDefinition:publish(topic, data, players)
	return RopostMethods.publish({
		channel = self.channel,
		topic = topic,
		data = data,
		players = players,
	})
end

function ChannelDefinition:destroy()
	for _, unsubscriber in pairs(self.unsubscribers) do
		unsubscriber()
	end
end

function ChannelDefinition:subscribe(topic, callback)
	local unsubscribe = RopostMethods.subscribe({
		channel = self.channel,
		topic = topic,
		callback = callback,
	})
	table.insert(self.unsubscribers, unsubscribe)
	return function()
		table.remove(self.unsubscribers, table.find(self.unsubscribers, unsubscribe))
		unsubscribe()
	end
end

return ChannelDefinition
