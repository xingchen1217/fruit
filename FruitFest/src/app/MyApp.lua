
require("config")
require("cocos.init")
require("framework.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")

    cc.Director:getInstance():setContentScaleFactor(640/ CONFIG_SCREEN_WIDTH)
    
    self:enterScene("MainScene")
    cc.Director:getInstance():setDisplayStats(false)--去掉fps提示
end

return MyApp
