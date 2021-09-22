local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RopostMethods = {}

local ROPOST_EVENT_NAME = "RopostEvent"
local remoteEvent = ReplicatedStorage:FindFirstChild(ROPOST_EVENT_NAME)
if not remoteEvent then
	if RunService:IsServer() then
		remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = ROPOST_EVENT_NAME
		remoteEvent.Parent = ReplicatedStorage
	else
		remoteEvent = ReplicatedStorage:WaitForChild(ROPOST_EVENT_NAME)
	end
end

local function createEnvelope(channel, topic, data)
	return {
		channel = channel,
		topic = topic,
		timestamp = os.clock(),
		data = data,
	}
end

function RopostMethods.subscribe(kwargs)
	local channel, topic, callback = kwargs.channel, kwargs.topic, kwargs.callback
	assert(type(channel) == "string", "Invalid channel!")
	assert(type(topic) == "string", "Invalid topic!")
	assert(type(callback) == "function", "Invalid callback!")

	local conn
	if RunService:IsServer() then
		conn = remoteEvent.OnServerEvent:connect(function(plr, envelope)
			if envelope.channel == channel and envelope.topic == topic then
				envelope.player = plr
				callback(envelope.data, envelope)
			end
		end)
	else
		conn = remoteEvent.OnClientEvent:connect(function(envelope)
			if envelope.channel == channel and envelope.topic == topic then
				callback(envelope.data, envelope)
			end
		end)
	end

	return function()
		conn:disconnect()
	end
end

function RopostMethods.publish(kwargs)
	local channel, topic, data = kwargs.channel, kwargs.topic, kwargs.data
	assert(type(channel) == "string", "Invalid channel!")
	assert(type(topic) == "string", "Invalid topic!")
	assert(type(data) == "table", "Invalid data!")

	local envelope = createEnvelope(channel, topic, data)
	if RunService:IsServer() then
		local player = kwargs.player
		if player then
			remoteEvent:FireClient(player, envelope)
		else
			remoteEvent:FireAllClients(envelope)
		end
	else
		remoteEvent:FireServer(envelope)
	end
end

return RopostMethods
