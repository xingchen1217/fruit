--
-- Author: new
-- Date: 2019-02-01 02:50:07
--
local FruitItem   = class("FruitItem", function(x, y, fruitIndex)
    fruitIndex = fruitIndex or math.round(math.random() * 1000 ) % 8 + 1
    local sprite = display.newSprite("#fruit"..fruitIndex..'_1.jpg')
    sprite.fruitIndex = fruitIndex
    sprite.x = x
    sprite.y = y
    sprite.isActive = false
    return sprite
end)


function FruitItem:ctor()

end

---FruitItem:setActive(ture) 高亮 动画变化大小
function FruitItem:setActive(active)
	-- body
	self.isActive = active

    local frame 
    if (active) then 
    	frame = display.newSpriteFrame("fruit"..self.fruitIndex..'_2.jpg')
    else
    	frame = display.newSpriteFrame("fruit"..self.fruitIndex..'_1.jpg')
    end

    self:setSpriteFrame(frame)

    if(active) then
    	self:stopAllActions()
    	local scale1 = cc.ScaleTo:create(0.1, 1.5)
    	local scale2 = cc.ScaleTo:create(0.05, 1.0)
    	self:runAction(cc.Sequence:create(scale1, scale2))
    end

end

function FruitItem:getWidth(  )
    local fruitWidth = 0
    if (0 == fruitWidth) then
    	local sprite = display.newSprite("#fruit1_1.jpg")
    	fruitWidth = sprite:getContentSize().width
    end
    
    return fruitWidth

end




return FruitItem
