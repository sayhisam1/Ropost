# Ropost
A Roblox lua implementation of postal.js (https://github.com/postaljs/postal.js)
The goal is to simplify client-server communication into a publish/subscribe model.
No more worrying about individual remote events!

# Usage

See postal.js for reference (https://github.com/postaljs/postal.js)
Or see the source code for documented api

The core API is very simple:
```lua
    -- subscribes to a specific channel and topic
    -- call disconnector() to unsubscribe from the channel and topic
    local disconnector = Ropost.subscribe({
        channel = "foo", 
        topic = "bar", 
        callback = function(data, envelope)
            -- data is a table containing stuff passed by the publisher; 
            -- envelope contains metadata (see below for details)
            print("this is some callback")
        end})

    -- publishes to a channel and topic
    Ropost.publish({
        channel = "foo", 
        topic = "bar",
        data = {
            baz = "something",
            qux = 1337
        }
    })
```
For ease of use, the API also includes a "channel" object that removes the need to specify a channel:
```lua
    local channel = Ropost.channel("foo")
    channel:publish("bar", {
        baz = "something",
        qux = 1337
    })

    local disconnector = channel:subscribe("bar", function(data, envelope)
        print("this is some callback")
    end})

    -- unsubscribes all subscribed callbacks
    channel:destroy()
```
