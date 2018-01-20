
local AddPuzzleGameConfig = {}

AddPuzzleGameConfig.ROCK_X = 5
AddPuzzleGameConfig.ROCK_Y = 6
AddPuzzleGameConfig.ROCK_WIDTH = 170
AddPuzzleGameConfig.ROCK_HEIGHT = 170
AddPuzzleGameConfig.ROCK_D = 10

AddPuzzleGameConfig.MOVE_SPEED = 0.1
AddPuzzleGameConfig.CLEAN_DELAY = 0.5

AddPuzzleGameConfig.ROCK_LEN_MIN = 1
AddPuzzleGameConfig.ROCK_LEN_MAX = 3
AddPuzzleGameConfig.ROCK_COLOR_MIN = 1
AddPuzzleGameConfig.ROCK_COLOR_MAX = 5

AddPuzzleGameConfig.ROCK_COLOR_BORDER = cc.c4f(1,1,1,1)
AddPuzzleGameConfig.ROCK_COLOR = {}
AddPuzzleGameConfig.ROCK_COLOR[1] = cc.c4f(1,0,0,1)
AddPuzzleGameConfig.ROCK_COLOR[2] = cc.c4f(1,1,0,1)
AddPuzzleGameConfig.ROCK_COLOR[3] = cc.c4f(0.5,0,1,0)
AddPuzzleGameConfig.ROCK_COLOR[4] = cc.c4f(1,0,0.5,0.5)
AddPuzzleGameConfig.ROCK_COLOR[5] = cc.c4f(0,0.5,0.5,0.5)

AddPuzzleGameConfig.ROCK_SHADOW_UNIT_PATH = "image/white_unit.png"


--zorder
AddPuzzleGameConfig._GameBgNode_Zorder = 1
AddPuzzleGameConfig._GameMapNode_Zorder = 2
AddPuzzleGameConfig._GameNextNode_Zorder = 2
AddPuzzleGameConfig._GameUINode_Zorder = 20

AddPuzzleGameConfig._GameRockNode_Zorder = 10
AddPuzzleGameConfig._GameRockNode_Zorder_Min = 3





return AddPuzzleGameConfig