
local GameEnv = {}

GameEnv.DEV = 1
GameEnv.PRO = 2
GameEnv.Current = GameEnv.DEV

-- Socket
GameEnv.SocketEnv = {
    --[[DEV]] { host = "127.0.0.1", port = 8000 },
    --[[PRO]] { host = "127.0.0.1", port = 8000 },
}

-- Http Rest
GameEnv.HttpRestEnv = {
    --[[DEV]] { host = "127.0.0.1", port = 7001 },
    --[[PRO]] { host = "127.0.0.1", port = 7001 },
}

-- Http Pay
GameEnv.HttpPayEnv = {
    --[[DEV]] { host = "127.0.0.1", port = 8000 },
    --[[PRO]] { host = "127.0.0.1", port = 8000 },
}

function GameEnv.getSocketEnv()
    return GameEnv.SocketEnv[GameEnv.Current]
end

function GameEnv.getHttpRestEnv()
    return GameEnv.HttpRestEnv[GameEnv.Current]
end

function GameEnv.getHttpPayEnv()
    return GameEnv.HttpPayEnv[GameEnv.Current]
end

return GameEnv