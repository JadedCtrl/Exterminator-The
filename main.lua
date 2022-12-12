--
-- Copyright 2022, Jaidyn Levesque <jadedctrl@posteo.at>
--
-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as
-- published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <https://www.gnu.org/licenses/>.
--

-- Style tip: Tabs == 4 spaces or death!
class   = require "lib/middleclass/middleclass"
wind    = require "lib/windfield/windfield"
cam11   = require "lib/cam11/cam11"


CHATLOG = {}
GRAVITY = 100
ARENA_LENGTH = 500


-- GAME STATES
--------------------------------------------------------------------------------
-- LOVE
----------------------------------------
function love.load()
	math.randomseed(os.time())

	bgm = nil
--	newBgm()

	logMsg(nil, "Starting up...")
	love.graphics.setDefaultFilter("nearest", "nearest")
	a_ttf = love.graphics.newFont("art/font/alagard.ttf", nil, "none")
	r_ttf = love.graphics.newFont("art/font/romulus.ttf", nil, "none")

	love.graphics.setBackgroundColor(0, 152/255, 255/255, 1)

	love.resize()

	menu_load(makeMainMenu())
end


function love.update(dt)
--	if (bgm.isPlaying == false) then
--		newBgm()
--	end
	updateFunction(dt)
end


function love.draw()
	camera:attach()
	drawFunction()
	camera:detach()
	drawLogMsgs()
end


function love.resize()
	local width,height = love.window.getMode()
	logMsg("[Window]", width .. "x" .. height)
	newCamera()
end


function love.keypressed(key)
	keypressedFunction(key)
end


function love.keyreleased (key)
	keyreleasedFunction(key)
end


-- MENUS
----------------------------------------
function menu_load(menu)
	menu:install()
end


function makeMainMenu()
	return Menu:new(100, 100, 30, 50, 3, {
		{love.graphics.newText(a_ttf, "Enter"),
			function () game_load(Game:new()) end},
		{love.graphics.newText(a_ttf, "Exit"),
			function () love.event.quit(0) end }})
end



-- IN-GAME
----------------------------------------
function game_load(game)
	game:install()
end


-- CLASSES
--------------------------------------------------------------------------------
-- Exterminator		player class
----------------------------------------
Exterminator = class('Exterminator')

function Exterminator:initialize(game, keymap)
	self.game = game
	self.character = math.random(1, table.maxn(CHARACTERS))
	self.lives = 5
	self.keymap = keymap
	self.θ, self.ω = 0, 0

	self.directionals = {}

	self:initBody(200, 200)
end


function Exterminator:update(dt)
	local dir = self.directionals

	self:movement(dt)

	if (self.body:getX() < 0) then
		self.body:setX(1)
	elseif (self.body:getX() > 500) then
		self.body:setX(499)
	end
	if (self.body:getY() < 0) then
		self.body:setY(1)
	elseif (self.body:getY() > 500) then
		self.body:setY(499)
	end

	if (dir['left'] == 2 and dir['right'] == 0) then dir['left'] = 1; end
	if (dir['right'] == 2 and dir['left'] == 0) then dir['right'] = 1; end
end


function Exterminator:draw()
	local x,y = self.body:getWorldPoints(self.body.shape:getPoints())

	love.graphics.draw(CHARACTERS[self.character], x, y, self.body:getAngle(),
		1, 1)
end


function Exterminator:initBody(x, y)
	self.body = self.game.world:newRectangleCollider(x, y, 16, 16);
	self.body:setCollisionClass('Exterminator')
	self.body:setObject(self)
--	self.body:setAngularDamping(2)
--	self.body:setLinearDamping(.5)
--	self.body:setPreSolve(self.makePreSolve())
end


function Exterminator:makePreSolve()
   return function(col1, col2, contact)
	  if (col1.collision_class == 'Exterminator' and col2.collision_class == 'Arena') then
		 contact:setEnabled(false)
	  end
   end
end


function Exterminator:movement(dt)
	local x, y = self.body:getPosition()
	local dir = self.directionals

	if (dir['withershins'] == 1) then
	   self.ω  = -1.5
	elseif (dir['deasil'] == 1) then
	   self.ω = 1.5
	elseif (math.abs(self.ω) > 0) then
	   self.game:rotate(self.θ)
	   self.ω = 0
	end

	if (not (self.ω == 0)) then
	   self.body:setType('static')
	   self:rotate(dt)
	else
	   self.body:setType('dynamic')
	end
end

function Exterminator:rotate(dt)
   local x0, y0 = self.body:getPosition()
   local camX, camY = camera:toScreen(x0, y0)

   self.θ = self.θ + self.ω*dt
   camera:setAngle(self.θ)

   if (self.θ > 2*math.pi) then
	  self.θ = self.θ - 2*math.pi
   elseif (self.θ < 0) then
	  self.θ = self.θ + 2*math.pi
   end

   local x1, y1 = camera:toWorld(camX, camY)
   self.body:setPosition(x1, y1)
end

function Exterminator:keypressed(key)
	local dir = self.directionals

	if (key == self.keymap["gravity"]) then
	   self.game:invertGravity()

	elseif (key == self.keymap["deasil"]) then
	   dir['deasil'] = 1
	   if (dir['withershins'] == 1) then dir['withershins'] = 2; end
	elseif (key == self.keymap["withershins"]) then
	   dir['withershins'] = 1
	   if (dir['deasil'] == 1) then dir['deasil'] = 2; end
	end
end


function Exterminator:keyreleased(key)
   local dir = self.directionals

	if (key == self.keymap["deasil"]) then
	   dir['deasil'] = 0
	   if (dir['withershins'] == 2) then dir['withershins'] = 1; end

	elseif (key == self.keymap["withershins"]) then
	   dir['withershins'] = 0
	   if (dir['deasil'] == 2) then dir['deasil'] = 1; end
	end
end


-- GAME superclass for matches
----------------------------------------
Game = class("Game")

function Game:initialize()
	self.world = wind.newWorld(0, 100, true)
	self.world:addCollisionClass('Exterminator')
	self.world:addCollisionClass('Arena')
	self.arena_borders = {}
	self.gravityMultiplier = -1
	self:initArena()

	self.player = Exterminator:new(self, KEYMAPS[1])
	self.entities = { self.player }
end


function Game:initArena()
	local side_length = ARENA_LENGTH * (2 * math.cos(.25 * math.pi) + 1)^-1
	local corner_length = (ARENA_LENGTH - side_length) / 2

	self.arena_borders[1] = self.world:newLineCollider(corner_length,0,  0,corner_length)
	self.arena_borders[2] = self.world:newLineCollider(0,corner_length,  0,ARENA_LENGTH - corner_length)
	self.arena_borders[3] = self.world:newLineCollider(0,ARENA_LENGTH-corner_length,  corner_length,ARENA_LENGTH)
	self.arena_borders[4] = self.world:newLineCollider(corner_length,ARENA_LENGTH,  ARENA_LENGTH - corner_length,ARENA_LENGTH)
	self.arena_borders[5] = self.world:newLineCollider(ARENA_LENGTH - corner_length,ARENA_LENGTH,  ARENA_LENGTH,ARENA_LENGTH - corner_length)
	self.arena_borders[6] = self.world:newLineCollider(ARENA_LENGTH,ARENA_LENGTH - corner_length,  ARENA_LENGTH,corner_length)
	self.arena_borders[7] = self.world:newLineCollider(ARENA_LENGTH,corner_length,  ARENA_LENGTH - corner_length,0)
	self.arena_borders[8] = self.world:newLineCollider(ARENA_LENGTH - corner_length,0,  corner_length,0)
	for k,border in pairs(self.arena_borders) do
	   border:setCollisionClass('Arena')
	   border:setType('static')
	end
end


function Game:install(update, draw, press, release)
	hookInstall(function (dt) self:update(dt) end,
		function () self:draw() end,
		function (key) self:keypressed(key) end,
		function (key) self:keyreleased(key) end,
		update, draw, press, release)
end


function Game:update(dt)
   -- Update all game objects.
   self.world:update(dt)
   for k,entity in pairs(self.entities) do
	  entity:update(dt)
   end
end


function Game:invertGravity()
   self.gravityMultiplier = -self.gravityMultiplier

   local exgravity_x, exgravity_y = self.world.box2d_world:getGravity()
   self.world:setGravity(-exgravity_x, -exgravity_y)
end


function Game:rotate(θ)
   -- Reduced from -(θ - 2π) - ½π
   -- `(θ - 2π)` to invert y-axis from Love's orientation to the expected (?)
   -- `- ½π` for the downward angle?
   -- Heck idk, I just know I _finally_ got this working >w<
   local θ = -θ + ((3/2)*math.pi)

   local multiplier = self.gravityMultiplier * GRAVITY
   self.world:setGravity(multiplier * math.cos(θ),
						 multiplier * math.sin(θ))
end


function Game:draw()
	self.world:draw()
   for k,entity in pairs(self.entities) do
		entity:draw(dt)
   end
end


function Game:keypressed(key)
	local dir = self.player.directionals

	-- if a player presses the left key, then holds the right key, they should
	-- go right until they let go, then they should go left.
	if (key == "=" and camera:getZoom() < 10) then
	   camera:setZoom(camera:getZoom() + .5)
	elseif (key == "-" and camera:getZoom() > .5) then
	   camera:setZoom(camera:getZoom() - .5)

	elseif (key == "escape") then
		menu_load(makeMainMenu())
	else
		self.player:keypressed(key)
	end
end


function Game:keyreleased (key)
	self.player:keyreleased(key)
end


-- MENU	used for creating menus (lol)
----------------------------------------
Menu = class("Menu")
function Menu:initialize(x, y, offset_x, offset_y, scale, menuItems)
	self.x,self.y = x,y
	self.offset_x,self.offset_y = offset_x,offset_y
	self.options = menuItems
	self.selected = 1
	self.scale = scale

	self.keys = {}
	self.keys['up'] = false
	self.keys['down'] = false
	self.keys['enter'] = false

	self.ttf = r_ttf
end


function Menu:install(update, draw, press, release)
	hookInstall(function (dt) self:update(dt) end,
		function () self:draw() end,
		function (key) self:keypressed(key) end,
		function (key) self:keyreleased(key) end,
		update, draw, press, release)
end


function Menu:update()
end


function Menu:draw()
	for i=1,table.maxn(self.options) do
		local this_y = self.y + (self.offset_y * i)

		love.graphics.draw(self.options[i][1],
				    self.x, this_y, 0, self.scale, self.scale)
		if (i == self.selected) then
			love.graphics.draw(love.graphics.newText(self.ttf, ">>"),
				self.x - self.offset_x, this_y, 0, self.scale, self.scale)
		end
	end
end


function Menu:keypressed(key)
	maxn = table.maxn(self.options)

	if (key == "return" or key == "space") then
		self.keys['enter'] = true
		if(self.options[self.selected][2]) then
			self.options[self.selected][2]()
		end

	elseif (key == "up"  and  self.selected > 1
			and  self.keys['up'] == false) then
		self.keys['up'] = true
		self.selected = self.selected - 1
	elseif (key == "up"  and  self.keys['up'] == false) then
		self.keys['up'] = true
		self.selected = maxn

	elseif (key == "down" and self.selected < maxn
			and  self.keys['down'] == false) then
		self.keys['down'] = true
		self.selected = self.selected + 1
	elseif (key == "down" and  self.keys['down'] == false) then
		self.keys['down'] = true
		self.selected = 1
	end
end


function Menu:keyreleased(key)
	if (key == "return" or key == "space") then
		self.keys['enter'] = false
	elseif (key == "up") then
		self.keys['up'] = false
	elseif (key == "down") then
		self.keys['down'] = false
	end
end


-- CHAT/LOGGING
--------------------------------------------------------------------------------
function logMsg(source, text)
	local string = text
	if not (source == nil) then
	   string = source .. ": " .. text
	end

	print(string)
	table.remove(CHATLOG, 5)
	table.insert(CHATLOG, 1, string)
end


function drawLogMsgs()
   local x,y = 10,600
   local offset_y = 30
   local scale = 1.7
   local chatCount = table.maxn(CHATLOG)
   for i=1,chatCount do
	  local this_y = y + (offset_y * (chatCount - i))
	  love.graphics.draw(love.graphics.newText(a_ttf, CHATLOG[i]),
						 -                       x, this_y, 0, scale, scale)
   end
   table.remove(CHATLOG, 5)
   table.insert(CHATLOG, 1, string)
end


-- UTIL
--------------------------------------------------------------------------------
-- Install the important 'hook' functions (draw, update, keypressed/released)
-- If any of the 'old' functions passed are not nil, then both the new and
-- old will be added into the new corresponding hook function
-- This function is too god damn long and it makes me want to cry
-- Could be pretty easily shortened, now that I think about it
function hookInstall(newUpdate, newDraw, newPress, newRelease,
		oldUpdate, oldDraw, oldPress, oldRelease)
	local ignored = 1

	if (oldUpdate == false) then
	elseif (oldUpdate == nil and not (newUpdate == nil)) then
		updateFunction = function (dt) newUpdate(dt) end
	elseif not (newUpdate == nil) then
		updateFunction = function (dt) oldUpdate(dt) newUpdate(dt) end
	end

	if (oldDraw == false) then
	elseif (oldDraw == nil and not (newDraw == nil)) then
		drawFunction = function () newDraw() end
	elseif not (newDraw == nil) then
		drawFunction = function () oldDraw() newDraw() end
	end

	if (oldPress == false) then
	elseif (oldPress == nil and not (newPress == nil)) then
		keypressedFunction = function (key) newPress(key) end
	elseif not (newPress == nil) then
		keypressedFunction = function (key) oldPress(key) newPress(key) end
	end

	if (oldRelease == false) then
	elseif (oldRelease == nil and not (newRelease == nil)) then
		keyreleasedFunction = function (key) newRelease(key) end
	elseif not (newPress == nil) then
		keyreleasedFunction = function (key) oldRelease(key) newRelease(key) end
	end
end


function newCamera()
	local width,height = love.window.getMode()
	local scale =  height / 800
	logMsg("[Camera]", "Scale: " .. scale)

	camera = cam11.new(250, 250)
	camera:setZoom(scale)
end


function newBgm()
	bgm = love.audio.newSource(MUSIC[math.random(1,table.maxn(MUSIC))], "stream")
	bgm:play()
end


-- MISC DATA
--------------------------------------------------------------------------------
-- CHARACTERS
------------------------------------------
CHARACTERS = {}
-- Lion Jellyfish by rapidpunches, CC-BY-SA 4.0
CHARACTERS[1] = love.graphics.newImage("art/sprites/jellyfish-lion.png")
-- N Jellyfish by rapidpunches, CC-BY-SA 4.0
CHARACTERS[2] = love.graphics.newImage("art/sprites/jellyfish-n.png")
-- Octopus by rapidpunches, CC-BY-SA 4.0
CHARACTERS[3] = love.graphics.newImage("art/sprites/octopus.png")
-- Something Indecipherable by my little brother (<3<3), CC-BY-SA 4.0
--CHARACTERS[4] = love.graphics.newImage("art/sprites/shark-unicorn.png")

-- MUSIC
------------------------------------------
MUSIC = {}
MUSIC[1] = "art/music/Cephalopod.ogg"
MUSIC[2] = "art/music/Go Cart.ogg"
MUSIC[3] = "art/music/Latin Industries.ogg"
MUSIC[4] = "art/music/Ouroboros.ogg"
MUSIC[5] = "art/music/Pamgaea.ogg"

-- LOCAL KEYMAPS
------------------------------------------
KEYMAPS = {}
KEYMAPS[1] = {["gravity"] = "down", ["withershins"] = "left", ["deasil"] = "right"}
KEYMAPS[2] = {["graviy"] = "w", ["withershins"] = "q", ["deasil"] = "e"}
KEYMAPS[3] = {["gravity"] = "z", ["withershins"] = "a", ["deasil"] = "e"}

