
local PokerPuzzleGameConfig = {}

PokerPuzzleGameConfig.ROCK_X = 5
PokerPuzzleGameConfig.ROCK_Y = 7
PokerPuzzleGameConfig.ROCK_WIDTH = 160
PokerPuzzleGameConfig.ROCK_HEIGHT = 160
PokerPuzzleGameConfig.ROCK_D = 40

PokerPuzzleGameConfig.MOVE_SPEED = 0.1
PokerPuzzleGameConfig.CLEAN_DELAY = 0.5

PokerPuzzleGameConfig.DIR_TORIGHT = "DIR_TORIGHT"
PokerPuzzleGameConfig.DIR_TOLEFT = "DIR_TOLEFT"
PokerPuzzleGameConfig.DIR_TOUP = "DIR_TOUP"
PokerPuzzleGameConfig.DIR_TODOWN = "DIR_TODOWN"

PokerPuzzleGameConfig.ROCK_LEN_MIN = 2
PokerPuzzleGameConfig.ROCK_LEN_MAX = 3
PokerPuzzleGameConfig.ROCK_COLOR_MIN = 1
PokerPuzzleGameConfig.ROCK_COLOR_MAX = 5

PokerPuzzleGameConfig.ROCK_COLOR_BORDER = cc.c4f(1,1,1,1)
PokerPuzzleGameConfig.ROCK_COLOR = {}
PokerPuzzleGameConfig.ROCK_COLOR[1] = cc.c4f(1,0,0,1)
PokerPuzzleGameConfig.ROCK_COLOR[2] = cc.c4f(1,1,0,1)
PokerPuzzleGameConfig.ROCK_COLOR[3] = cc.c4f(0.5,0,1,0)
PokerPuzzleGameConfig.ROCK_COLOR[4] = cc.c4f(1,0,0.5,0.5)
PokerPuzzleGameConfig.ROCK_COLOR[5] = cc.c4f(0,0.5,0.5,0.5)

PokerPuzzleGameConfig.ROCK_SHADOW_UNIT_PATH = "image/white_unit.png"


--zorder
PokerPuzzleGameConfig._GameBgNode_Zorder = 1
PokerPuzzleGameConfig._GameMapNode_Zorder = 2
PokerPuzzleGameConfig._GameNextNode_Zorder = 2
PokerPuzzleGameConfig._GameUINode_Zorder = 20

PokerPuzzleGameConfig._GameRockNode_Zorder = 10
PokerPuzzleGameConfig._GameRockNode_Zorder_Min = 3
PokerPuzzleGameConfig._GameNumNode_Zorder = 15




return PokerPuzzleGameConfig