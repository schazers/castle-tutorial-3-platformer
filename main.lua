-- Castle Example: Platformer (Part 1)
-- http://www.playcastle.io

local GAME_WIDTH = 768
local GAME_HEIGHT = 512

local GRAVITY = -2000

local ground = {}
local player = {}
local enemies = {}

local ENEMY_LENGTH = 32
local ENEMY_WIDTH = 8
local ENEMY_HORIZONTAL_SPEED = 300
local ENEMY_VERTICAL_SPEED = 400
 
function love.load()
  math.randomseed(os.time())

	ground.width = GAME_WIDTH
	ground.height = 0.1 * GAME_HEIGHT
 
	ground.x = 0
	ground.y = GAME_HEIGHT - 0.1 * GAME_HEIGHT
 
  player.move_speed = 250
  player.width = 32
  player.height = 32
  player.x = GAME_WIDTH / 2 + player.width / 2
	player.y = GAME_HEIGHT / 2
	player.y_velocity = -5
  player.jump_initial_velocity = -600
end
 
function love.update(dt)
	if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
    player.x = player.x + (player.move_speed * dt)
    if player.x > GAME_WIDTH - player.width then
      player.x = GAME_WIDTH - player.width
    end
	elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then		
		player.x = player.x - (player.move_speed * dt)
    if player.x < 0 then
      player.x = 0
    end
  end
 
	if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
		if player.y_velocity == 0 then
			player.y_velocity = player.jump_initial_velocity
		end
  end
  
	if player.y_velocity ~= 0 then
		player.y = player.y + player.y_velocity * dt
		player.y_velocity = player.y_velocity - GRAVITY * dt
	end
 
	if player.y + player.height > ground.y then
		player.y_velocity = 0
    player.y = ground.y - player.height
  end

  -- update existing enemies
  for i = 1, #enemies do
    if enemies[i].x_velocity ~= 0 then
      enemies[i].x = enemies[i].x + enemies[i].x_velocity * dt
      if (enemies[i].x + ENEMY_LENGTH < 0) or (enemies[i].x > GAME_WIDTH) then
        table.remove(enemies, i)
        if i ~= #enemies then
          i = i - 1
        end
      end
    else
      enemies[i].y = enemies[i].y + enemies[i].y_velocity * dt
      if (enemies[i].y > ground.y) then
        table.remove(enemies, i)
        if i ~= #enemies then
          i = i - 1
        end
      end
    end
  end

  -- spawn enemies
  if (math.random() < 1.0 * dt) then
    local randFloat = math.random()
    local enemy_velocity_x = 0
    local enemy_velocity_y = 0
    local enemy_x = 0
    local enemy_y = 0
    if (randFloat < 0.333) then
      enemy_x = 0
      enemy_y = ground.y - ENEMY_LENGTH
      enemy_velocity_x = ENEMY_HORIZONTAL_SPEED
    elseif (randFloat < 0.666) then
      enemy_x = GAME_WIDTH
      enemy_y = ground.y - (player.height / 2) - (ENEMY_LENGTH / 2)
      enemy_velocity_x = -ENEMY_HORIZONTAL_SPEED
    else
      enemy_x = player.x
      enemy_y = 0
      enemy_velocity_y = ENEMY_VERTICAL_SPEED
    end

    enemies[#enemies + 1] = {
      x = enemy_x, 
      y = enemy_y,
      x_velocity = enemy_velocity_x,
      y_velocity = enemy_velocity_y
    }
  end

end
 
function love.draw()
  -- center game within castle window
  love.graphics.push()
  gTranslateScreenToCenterDx = 0.5 * (love.graphics.getWidth() - GAME_WIDTH)
  gTranslateScreenToCenterDy = 0.5 * (love.graphics.getHeight() - GAME_HEIGHT)
  love.graphics.translate(gTranslateScreenToCenterDx, gTranslateScreenToCenterDy)

  -- draw player
  love.graphics.setColor(0.7, 0.25, 0.25, 1.0)
  love.graphics.rectangle('fill', player.x, player.y, player.width, player.height)

  -- draw enemies
  love.graphics.setColor(0.25, 0.7, 0.25, 1.0)
  for i = 1, #enemies do
    local enemy = enemies[i]
    local width = 0
    local height = 0
    if enemy.x_velocity ~= 0 then
      width = ENEMY_LENGTH
      height = ENEMY_WIDTH
    else
      width = ENEMY_WIDTH
      height = ENEMY_LENGTH
    end
    love.graphics.rectangle('fill', enemy.x, enemy.y, width, height)
  end

  -- draw ground
  love.graphics.setColor(0.2, 0.2, 0.3, 1.0)
  love.graphics.rectangle('fill', ground.x, ground.y, ground.width, ground.height)

  -- draw frame
  love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
  love.graphics.rectangle('line', 0, 0, GAME_WIDTH, GAME_HEIGHT)

  -- restore translation to state before window centering
  love.graphics.pop()
end
