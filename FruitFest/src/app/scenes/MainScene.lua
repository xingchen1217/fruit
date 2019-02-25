
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
   --加载精灵帧
   display.addSpriteFrames("fruit.plist", "fruit.pvr.ccz")

   --背景图片
   display.newSprite("mainBG.png"):pos(display.cx, display.cy):addTo(self)

   

    --开始按钮
   local starBtnImages = {
   normal = "#startBtn1.png",  --按钮初始图片，normal 
   pressed = "#startBtn2.png"}  --按钮按下图片，pressed
   
   cc.ui.UIPushButton.new(starBtnImages, {scale9 = false}) --false不改变图片大小 
   :onButtonClicked(function(event)
   	-- 按下转场
   local rr = import("app.scenes.PlayScene").new() --获得PlayScene.lua的实例
   display.replaceScene(rr, "turnOffTiles", 0.5)

   end)
   :align(display.CENTER, display.cx + 10, display.cy + 35)
   :addTo(self)



end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
