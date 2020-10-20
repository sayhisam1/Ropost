local RunService = game:GetService("RunService")
local DEFAULT_CHANNEL = "DEFAULT_CHANNEL"

local ropost = {}

local function getRemoteEvent(name)
    if RunService:IsServer() then
        if not script:FindFirstChild(name) then
            local event = Instance.new("RemoteEvent")
            event.Name = name
            event.Parent = script
        end
        return script:FindFirstChild(name)
    else
        return script:WaitForChild(name)
    end
end

local function createEnvelope(channel, topic)
    return {
        channel = channel,
        topic = topic,
        timestamp = os.clock()
    }
end

function ropost.subscribe(kwargs)
    local channel = kwargs.channel or DEFAULT_CHANNEL
    local topic,
        callback = kwargs.topic, kwargs.callback
    assert(type(channel) == "string", "Invalid channel!")
    assert(type(topic) == "string", "Invalid topic!")
    assert(type(callback) == "function", "Invalid callback!")
    local event = getRemoteEvent(string.format("%s.%s", channel, topic))
    local conn
    if RunService:IsServer() then
        conn =
            event.OnServerEvent:connect(
            function(plr, envelope)
                envelope.player = plr
                callback(envelope.data, envelope)
            end
        )
    else
        conn =
            event.OnClientEvent:connect(
            function(envelope)
                callback(envelope.data, envelope)
            end
        )
    end
    local unsubscriber = {}
    function unsubscriber.unsubscribe()
        conn:Disconnect()
    end
    function unsubscriber.destroy()
        conn:Disconnect()
    end
    return unsubscriber
end

function ropost.publish(kwargs)
    local channel = kwargs.channel or DEFAULT_CHANNEL
    local topic,
        data = kwargs.topic, kwargs.data or {}
    assert(type(channel) == "string", "Invalid channel!")
    assert(type(topic) == "string", "Invalid topic!")
    assert(type(data) == "table", "Invalid data!")
    local event = getRemoteEvent(string.format("%s.%s", channel, topic))
    local envelope = createEnvelope()
    envelope.data = data
    if RunService:IsServer() then
        local player = kwargs.player
        assert(player, "Invalid player!")
        event:FireClient(player, envelope)
    else
        event:FireServer(envelope)
    end
end

return ropost
