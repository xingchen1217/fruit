

FruitItem = import("app.scenes.FruitItem") --加载FruitItem.lua 全局可用

local PlayScene = class("PlayScene", function()
    return display.newScene("PlayScene")
end)



function PlayScene:ctor()
   math.newrandomseed() --初始化随机数
   self.highSorce = 0
   self.stage = 1
   self.target = 200
   self.curSorce = 0
   self.k = 0
   self:initUI()

   self.xCount = 8
   self.yCount = 8
   self.fruitGap = 5

   self.scoreStar = 5
   self.scoreStep = 10
   self.activeScore = 0
  
   --1号方块左下角坐标常量 
   self.matrixLBX = ( display.width - FruitItem.getWidth() * self.xCount - (self.xCount - 1) * self.fruitGap ) / 2

   self.matrixLBY = ( display.height - FruitItem.getWidth() * self.yCount - (self.yCount - 1) * self.fruitGap ) / 2 - 70
  
   --最高分
   self.highSorce  = cc.UserDefault:getInstance():getIntegerForKey("highSorce")--初始化存储
   self.highSorceLable:setString(tostring(self.highSorce))
  
   
   --audio.playMusic("music/background.mp3", true)


   --转场结束 调用initMatrix()，前面有特效两个场景在内存上 b：init--b：onEter--a:exit
   self:addNodeEventListener(cc.NODE_EVENT, function(event) 
     if event.name == "enterTransitionFinish" then 
          self:initMatrix()
        end

   end)

end 

--创建64个水果
function PlayScene:initMatrix()
    self.matrix = {}
    self.actives = {}  --高亮表
    for y =1, self.yCount do
      for x = 1, self.xCount do
        if 2 == x and 1 == y then
          --保证前两个一样类型出现
          self:createAndDropFruit(x, y, self.matrix[1].fruitIndex)
        else 
          self:createAndDropFruit(x, y)
        end
      end
    end
end

    --消除高亮，并且清空高亮actives{}
function PlayScene:inactive()
  if self.actives then
      for _, fruit in pairs(self.actives) do
         
           fruit:setActive(false)
      end
      
          self.actives = {}
  end

end

--高亮附近一样的水果
function PlayScene:activeNeighbor(fruit)
      -- 高亮fruit，并且加到高亮集合actives{}
      if false == self.isActive then
        fruit:setActive(true)
        table.insert(self.actives, fruit)
      end
      --左边
      if (fruit.x - 1) >= 1 then
        local leftNeighbor = self.matrix[(fruit.y - 1) * self.xCount + fruit.x - 1]
        if (leftNeighbor.isActive == false) and (leftNeighbor.fruitIndex == fruit.fruitIndex) then
          leftNeighbor:setActive(true)
          table.insert(self.actives, leftNeighbor)
          self:activeNeighbor(leftNeighbor)
        end
      end
       ---右边
      if (fruit.x + 1)<= self.xCount then
        local righNeighbor = self.matrix[(fruit.y - 1) * self.xCount + fruit.x + 1]
        if (righNeighbor.isActive == false) and (righNeighbor.fruitIndex == fruit.fruitIndex) then
          righNeighbor:setActive(true)
          table.insert(self.actives, righNeighbor)
          self:activeNeighbor(righNeighbor)
        end
      end
       --上边
      if (fruit.y + 1)<= self.yCount then
        local upNeighbor = self.matrix[ fruit.y  * self.xCount + fruit.x ]
        if (upNeighbor.isActive == false) and (upNeighbor.fruitIndex == fruit.fruitIndex) then
          upNeighbor:setActive(true)
          table.insert(self.actives, upNeighbor)
          self:activeNeighbor(upNeighbor)
        end
      end      
      --下边
      if (fruit.y - 1)>= 1 then
        local downNeighbor = self.matrix[ (fruit.y - 2 )  * self.xCount + fruit.x ]
        if (downNeighbor.isActive == false) and (downNeighbor.fruitIndex == fruit.fruitIndex) then
          downNeighbor:setActive(true)
          table.insert(self.actives, downNeighbor)
          self:activeNeighbor(downNeighbor)
        end
      end
end


---单个水果创建
function PlayScene:createAndDropFruit(x, y, fruitIndex)
    local newFruit = FruitItem.new(x, y, fruitIndex)
    local endPosition = self:positionOfFruit(x, y)
    local startPosition = cc.p(endPosition.x, endPosition.y + display.height/2)
    newFruit:setPosition(startPosition)
    local speed = startPosition.y/(2* display.height)
    newFruit:runAction(cc.MoveTo:create(speed, endPosition))
    self.matrix[(y-1) * self.xCount + x] = newFruit  
    self:addChild(newFruit)   
    
    newFruit:setTouchEnabled(true)
    newFruit:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
      -- body
      if event.name == "ended" then 
         if newFruit.isActive then
              --音效
              if #self.actives > 3 then 
                audio.playSound("music/button.wav") 
              else 
                audio.playSound("music/heart.mp3") 
              end

              --TODO:消除高亮水果加分，并掉落补全
              self:removeActivedFruits()
              self:dropFruits()
              self:checkNextStage()
         else
             self:inactive()  --清除已高亮水果
             self:activeNeighbor(newFruit)  --已选中水果为中心，高亮周围相同水果
             self:showActivesScore()  --计算高亮区域水果分数
            
         end
      end
      
      if event.name == "began" then
        return true 
      end
    end)

end

function PlayScene:checkNextStage()
  
  if self.curSorce < self.target then return end

  --resultLayer半透明展示信息层
  local resultLayer = display.newColorLayer(cc.c4b(0,0,0,150)):addTo(self)

  --吞噬事件 吃点击操作 不做反应
  resultLayer:setTouchEnabled(true)
  resultLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    if event.name == "began" then return true end
  end)

  --更新数据
  
  self.k = self.curSorce + self.k
  if self.k >= self.highSorce then self.highSorce = self.k end
  self.stage =   self.stage + 1
  self.target =  self.stage * 200
  
  

  self.targetLable:setString(tostring(self.target))
  self.stageLable:setString(tostring(self.stage))
  self.highSorceLable:setString(tostring(self.highSorce))

  --存数据
  cc.UserDefault:getInstance():setIntegerForKey("highSorce", self.highSorce)
 
  
  --通关信息显示
  display.newTTFLabel({text = string.format("恭喜通关！\n当前得分为: %d", self.k), size = 60})
  :pos(display.cx, display.cy + 140):addTo(resultLayer)

  
  --继续、结束按钮
  local starBtnImages = {normal = "timg1.png", pressed = "timg2.png"}
  cc.ui.UIPushButton.new(starBtnImages, {scale9 = false})
  :onButtonClicked(function ( event )
     self:removeChild(resultLayer)

     self.curSorce = 0
     self.curSorceLabel:setString(tostring(self.curSorce))
     self.sliderBar:setSliderValue(0)
     end)
  :align(display.CENTER, display.cx, display.cy -80)
  :addTo(resultLayer)

  local starBtnImages1 = {normal = "timg3.png", pressed = "timg4.png"}
  cc.ui.UIPushButton.new(starBtnImages1, {scale9 = false})
  :onButtonClicked(function ( event )

     local mainScene = import("app.scenes.MainScene"):new()
     display.replaceScene(mainScene)
     end)
  :align(display.CENTER, display.cx, display.cy -230)
  :addTo(resultLayer)

end
    
function PlayScene:removeActivedFruits()

  for _, fruit in pairs(self.actives) do
    if (fruit) then
      
      --在矩阵上移除该水果
      self.matrix[(fruit.y - 1) * self.xCount + fruit.x] = nil

      --分数特效
      local label = cc.ui.UILabel.new({UILabelType = 2, size = 25, text = tostring("+ "..self.activeScore),
          align = cc.TEXT_ALIGNMENT_CENTER, color = cc.c3b(255,24,23)})

      label:center():addTo(self, 1)
      label:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(1, cc.p(0, display.height*0.15)),
        cc.ScaleTo:create(1, 2.5)),  
          cc.CallFunc:create(function()
            label:removeFromParent()
          end)
        ))

      --移除粒子特效
      local emitter = cc.ParticleSystemQuad:create("particle/stars.plist")
      emitter:pos(fruit:getPosition()):addTo(self)

    
      self:removeChild(fruit)
      
    
    end
  end
     
    --
    self.actives = {}
    --
    self.curSorce = self.curSorce + self.activeScore
    self.curSorceLabel:setString(tostring(self.curSorce))
    --
    self.activeScoreLabel:setString("")
    self.activeScore = 0
    ------------------进度条满值100
    local sliderValue = self.curSorce / self.target * 100
    if sliderValue > 100 then  sliderValue = 100 end
    self.sliderBar:setSliderValue(sliderValue)
  
end

function PlayScene:dropFruits()
  local emptyInfo ={}

  for x =1, self.xCount do
    local removedFruits = 0
    local newY = 0
  
    for y = 1, self.yCount do
      local temp = self.matrix[(y - 1) * self.xCount + x]
      if nil == temp then
        removedFruits = removedFruits + 1
      else 
        if (removedFruits > 0) then 
        newY = y - removedFruits
        self.matrix[(newY - 1) * self.xCount + x] = temp
        temp.y = newY
        self.matrix[(y - 1) * self.xCount + x] = nil

        local endPosition = self:positionOfFruit(x, newY)
        local speed = (temp:getPositionY() - endPosition.y)/display.height
        temp:stopAllActions()
        temp:runAction(cc.MoveTo:create(speed, endPosition))
        end
      end
    end

    emptyInfo[x] =  removedFruits

  end

 
  for x=1, self.xCount do
    for y = (self.yCount - emptyInfo[x] + 1), self.yCount do
      self:createAndDropFruit(x, y)
    end
  end

end


function PlayScene:positionOfFruit(x, y)
  
  local px = self.matrixLBX + (FruitItem.getWidth() + self.fruitGap) * (x - 1) + FruitItem.getWidth()/2
  local py = self.matrixLBY + (FruitItem.getWidth() + self.fruitGap) * (y - 1) + FruitItem.getWidth()/2

  return cc.p(px, py)

end



--设置分数模块和位置
function  PlayScene:initUI()
  
  self.playbg = display.newSprite("playbg.jpg"):pos(display.cx, display.cy):addTo(self)--背景

 --创建最高分ui和显示分数及区域
  display.newSprite("#highScore.png")
  :align(display.LEFT_CENTER, display.left + 15, display.top - 30)
  :addTo(self)

   display.newSprite("#highScore_part.png")
  :align(display.LEFT_CENTER, display.cx + 60, display.top - 30)
  :addTo(self)

  self.highSorceLable = cc.ui.UILabel.new({UILabelType = 2, text = tostring(self.highSorce),
  font = "font/earth38.fnt"}):align(display.CENTER, display.cx + 120, display.top - 32):addTo(self)
  --------
  display.newSprite("#stage.png")
  :align(display.LEFT_CENTER, display.left + 15, display.top - 100)
  :addTo(self)

  display.newSprite("#stage_part.png")
  :align(display.LEFT_CENTER, display.left + 220, display.top - 100)
  :addTo(self)

  self.stageLable = cc.ui.UILabel.new({UILabelType = 2, text = tostring(self.stage),
  font = "font/earth32.fnt"}):align(display.CENTER, display.left + 250, display.top - 100):addTo(self)

  -------
  display.newSprite("#target.png")
  :align(display.LEFT_CENTER, display.left + 330, display.top - 100)
  :addTo(self)

  display.newSprite("#target_part.png")
  :align(display.LEFT_CENTER, display.left + 510, display.top - 100)
  :addTo(self)

  self.targetLable = cc.ui.UILabel.new({UILabelType = 2, text = tostring(self.target),
  font = "font/earth32.fnt"}):align(display.CENTER, display.left + 550, display.top - 100):addTo(self)

  ------------
  display.newSprite("#Sorce.png")
  :align(display.CENTER, display.cx -100, display.top - 170)
  :addTo(self)

  self.curSorceLabel =  cc.ui.UILabel.new({UILabelType = 2, text = tostring(self.curSorce),
  font = "font/earth48.fnt"}):align(display.CENTER, display.cx -100, display.top - 170):addTo(self)

  ---
  display.newSprite("ee.png")
  :align(display.CENTER, display.cx +160, display.top - 170)
  :addTo(self)

  self.activeScoreLabel = display.newTTFLabel({text = "", size = 20})
  :pos(display.cx +160, display.top - 170):addTo(self)

  -----------进度条ui
  local SliderImage = {bar = "SliderBar.png", button = "SliderButton.png"}

  self.sliderBar = cc.ui.UISlider.new(display.LEFT_TO_RIGHT, SliderImage, {scale9 = false})
  :setTouchEnabled(false):setSliderValue(0):align(display.CENTER, display.cx, 60):addTo(self)
  

end

function PlayScene:showActivesScore()
      -- 只有一个高亮，取消高亮并且返回
      if 1 == #self.actives then
        self.inactive()
        self.activeScoreLabel:setString("")
        self.activeScore = 0
        return
      end  

      self.activeScore = (self.scoreStar * 2 + self.scoreStep * (#self.actives - 1))* #self.actives/2
      self.activeScoreLabel:setString(string.format(" %d 连消，得分 %d", #self.actives, self.activeScore))
end

              

function PlayScene:onEnter()
end

function PlayScene:onExit()
end

return PlayScene
