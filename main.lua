screen_width = 98
screen_height = 144
scale_factor = 5
minoSize = 8
cooldown = 20
refresh = 60
speed = refresh
love.graphics.setDefaultFilter('nearest', 'nearest')
math.randomseed(os.time())

board = {}
board.width = 12
board.height = 18
board.grid = {}

minoSprites = {}
minoFactory = {}

tetrominoFactory = {}
tetrominoFactory.templates = {}
tetrominoTypes = {'square', 'j', 'l', 's', 't', 'z', 'long'}

function createMino(sprite, x, y, rotate)
	rotate = rotate or 0  -- optional

	local mino = {}
	mino.x = x
	mino.y = y
	mino.rotate = (rotate / 180) * math.pi
	mino.sprite = sprite

	return mino
end

function createRandomTetromino()
	return createTetromino(tetrominoTypes[math.random(#tetrominoTypes)])
end

function createTetromino(type)
	local tetromino = {}
	tetromino.type = type
	tetromino.x = 6
	tetromino.y = 0

	if type == 'square' then
		tetromino.minos = {
			createMino(minoSprites[1], -1, -1),
		  createMino(minoSprites[1], 0, -1),
			createMino(minoSprites[1], -1, 0),
			createMino(minoSprites[1], 0, 0)
		}

  elseif type == 'j' then
		tetromino.minos = {
			createMino(minoSprites[2], 0, -1),
			createMino(minoSprites[2], 0, 0),
			createMino(minoSprites[2], 0, 1),
			createMino(minoSprites[2], -1, 1)
		}

	elseif type == 'l' then
		tetromino.minos = {
			createMino(minoSprites[3], 0, -1),
			createMino(minoSprites[3], 0, 0),
			createMino(minoSprites[3], 0, 1),
			createMino(minoSprites[3], 1, 1)
		}

	elseif type == 's' then
		tetromino.minos = {
			createMino(minoSprites[4], 1, 0),
			createMino(minoSprites[4], 0, 0),
			createMino(minoSprites[4], 0, 1),
			createMino(minoSprites[4], -1, 1)
		}

	elseif type == 't' then
		tetromino.minos = {
			createMino(minoSprites[5], -1, 0),
			createMino(minoSprites[5], 0, 0),
			createMino(minoSprites[5], 0, -1),
			createMino(minoSprites[5], 1, 0)
		}

	elseif type == 'z' then
		tetromino.minos = {
			createMino(minoSprites[6], -1, 0),
			createMino(minoSprites[6], 0, 0),
			createMino(minoSprites[6], 0, 1),
			createMino(minoSprites[6], 1, 1)
		}

	elseif type == 'long' then
		tetromino.minos = {
			createMino(minoSprites[7], -1, 0, 0),
			createMino(minoSprites[8], 0, 0, 0),
			createMino(minoSprites[8], 1, 0, 0),
			createMino(minoSprites[7], 2, 0, 180),
		}
	end

	return tetromino
end

function drawMino(mino, x, y)
	x = x or 0
	y = y or 0

	love.graphics.draw(sprites, mino.sprite, x + (mino.x * minoSize), y + (mino.y * minoSize), 
		mino.rotate, 1, 1)
end

function drawTetromino(tetromino)
	offsetX = 1 + (minoSize / 2) + (tetromino.x * minoSize) - minoSize
	offsetY = tetromino.y * minoSize + (minoSize / 2)

	for _, mino in pairs(tetromino.minos) do
		drawMino(mino, offsetX, offsetY)
	-- 	love.graphics.draw(sprites, mino.sprite, offsetX + mino.x * minoSize, offsetY + mino.y * minoSize,
	-- 		mino.rotate, 1, 1, minoSize/2, minoSize/2)
	end

end

function isTetrominoInsideGrid(tetromino)
	for _, mino in pairs(tetromino.minos) do
		if (tetromino.x + mino.x) * minoSize - (minoSize / 2) < (1 + minoSize) then
			return false

		elseif (tetromino.x + mino.x) * minoSize + (minoSize / 2) > (1 + minoSize * 12) then
			return false

		elseif (tetromino.y + mino.y) * minoSize + (minoSize / 2) > (board.height * minoSize) then
			print((tetromino.y + mino.y) * minoSize + (minoSize / 2) .. " " .. board.height)
			return false
		end
	end

	return true
end

function updateGrid(tetromino) 
	for _, mino in pairs(tetromino.minos) do
		mino.x = mino.x + tetromino.x
		mino.y = mino.y + tetromino.y
		board.grid[mino.y][mino.x] = mino
	end
end

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end

function love.load()
	love.window.setMode(screen_width * scale_factor, screen_height * scale_factor)
	love.keyboard.setKeyRepeat(0)

	-- initialise game board
	board.grid = {}
	for y = 1, board.height do
		board.grid[y] = {}
		for x = 1, board.width do
			board.grid[y][x] = '0'
		end
	end
	
	print(dump(board.grid))

	sprites = love.graphics.newImage('minos.png')
	minoSprites[1] = love.graphics.newQuad(0, 0, 8, 8, sprites:getDimensions())    -- square mino
	minoSprites[2] = love.graphics.newQuad(8, 0, 8, 8, sprites:getDimensions())    -- j mino
	minoSprites[3] = love.graphics.newQuad(16, 0, 8, 8, sprites:getDimensions())   -- l mino
	minoSprites[4] = love.graphics.newQuad(24, 0, 8, 8, sprites:getDimensions())   -- s mino
	minoSprites[5] = love.graphics.newQuad(0, 8, 8, 8, sprites:getDimensions())    -- t mino
	minoSprites[6] = love.graphics.newQuad(8, 8, 8, 8, sprites:getDimensions())    -- z mino
	minoSprites[7] = love.graphics.newQuad(16, 8, 8, 8, sprites:getDimensions())   -- long mino cap
	minoSprites[8] = love.graphics.newQuad(24, 8, 8, 8, sprites:getDimensions())   -- long mino body
  minoSprites[9] = love.graphics.newQuad(0, 16, 8, 8, sprites:getDimensions())   -- wall 1
	minoSprites[10] = love.graphics.newQuad(8, 16, 8, 8, sprites:getDimensions())  -- wall 2
	minoSprites[11] = love.graphics.newQuad(16, 16, 8, 8, sprites:getDimensions())  -- wall 3


  activeTetromino = createRandomTetromino()

end

function love.keypressed(key, isrepeat)
	isrepeat = isrepeat or false

	if key == 'escape' then
		love.event.quit()
	end

	if key == 'a' then
		activeTetromino.x = activeTetromino.x - 1
		if not isTetrominoInsideGrid(activeTetromino) then
			activeTetromino.x = activeTetromino.x + 1
		end

	elseif key == 'd' then
		activeTetromino.x = activeTetromino.x + 1
		if not isTetrominoInsideGrid(activeTetromino) then
			activeTetromino.x = activeTetromino.x - 1
		end

	elseif key == 's' then
		activeTetromino.y = activeTetromino.y + 1
		if not isTetrominoInsideGrid(activeTetromino) then
			activeTetromino.y = activeTetromino.y - 1
			updateGrid(activeTetromino)
			activeTetromino = createRandomTetromino()
		end
		speed = refresh
	end
end


function love.update(dt)
	speed = speed - 1

	if speed <= 0 then
		activeTetromino.y = activeTetromino.y + 1
		if not isTetrominoInsideGrid(activeTetromino) then
			activeTetromino.y = activeTetromino.y - 1
			updateGrid(activeTetromino)
			activeTetromino = createRandomTetromino()
		end
		speed = refresh
	end		
end

function love.draw()
	love.graphics.scale(scale_factor)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setBackgroundColor(255, 255, 255)
	
	-- draw walls
	for i = 0, 5 do
		love.graphics.draw(sprites, minoSprites[11], 1, i * minoSize*3)
		love.graphics.draw(sprites, minoSprites[11], 89, i * minoSize*3)
		love.graphics.draw(sprites, minoSprites[10], 1, i * minoSize*3 + minoSize)
		love.graphics.draw(sprites, minoSprites[10], 89, i * minoSize*3 + minoSize)
		love.graphics.draw(sprites, minoSprites[9], 1, i * minoSize*3 + minoSize*2)
		love.graphics.draw(sprites, minoSprites[9], 89, i * minoSize*3 + minoSize*2)
	end

	-- draw grid
	for y = 1, #board.grid do
		for x = 1, #board.grid[y] do
			if board.grid[y][x] ~= '0' then
				drawMino(board.grid[y][x], 0, 0)
				print ("drawMino " .. x .. ", " .. y)
			else 
				-- print("board.grid[".. y .."][".. x .."] = " .. board.grid[y][x])
			end
		end
	end

	-- draw active piece
	drawTetromino(activeTetromino)

end
