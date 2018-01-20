
local GameMapConfig = {}

GameMapConfig.ROCK_X = 8
GameMapConfig.ROCK_Y = 10
GameMapConfig.ROCK_WIDTH = 110
GameMapConfig.ROCK_HEIGHT = 110
GameMapConfig.ROCK_D = 10

GameMapConfig.MOVE_SPEED = 0.1
GameMapConfig.CLEAN_DELAY = 0.5

GameMapConfig.ROCK_LEN_MIN = 1
GameMapConfig.ROCK_LEN_MAX = 3
GameMapConfig.ROCK_COLOR_MIN = 1
GameMapConfig.ROCK_COLOR_MAX = 5

GameMapConfig.ROCK_COLOR_BORDER = cc.c4f(1,1,1,1)
GameMapConfig.ROCK_COLOR = {}
GameMapConfig.ROCK_COLOR[1] = cc.c4f(1,0,0,1)
GameMapConfig.ROCK_COLOR[2] = cc.c4f(1,1,0,1)
GameMapConfig.ROCK_COLOR[3] = cc.c4f(0.5,0,1,0)
GameMapConfig.ROCK_COLOR[4] = cc.c4f(1,0,0.5,0.5)
GameMapConfig.ROCK_COLOR[5] = cc.c4f(0,0.5,0.5,0.5)

GameMapConfig.ROCK_SHADOW_UNIT_PATH = "image/white_unit.png"


--zorder
GameMapConfig._GameBgNode_Zorder = 1
GameMapConfig._GameMapNode_Zorder = 2
GameMapConfig._GameNextNode_Zorder = 2
GameMapConfig._GameUINode_Zorder = 20

GameMapConfig._GameRockNode_Zorder = 10
GameMapConfig._GameRockNode_Zorder_Min = 3





return GameMapConfig