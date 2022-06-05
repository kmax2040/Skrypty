function love.load()
	math.randomseed(os.time())

	gameOver = false

	size = 32
	cols = 10
	rows = 20

	menuWidth = size*6
	gameWidth = cols*size
	width = gameWidth + menuWidth
	height = rows*size
	
	grid = {}

	for i=1, rows, 1 do
		grid[i] = {}
		for j=1, cols, 1 do
			grid[i][j] = nil
		end
	end

	scores = { 40, 100, 300, 1200 }
	score = 0

	initShapes()

	shapes = { shapeT, shapeL, shapeJ, shapeI, shapeO, shapeS, shapeZ }

	nextShape = shapes[math.random(#shapes)]

	getNextShape()

	resetPos()

	love.window.setMode(width, height)

	fontSize = 24
	font = love.graphics.newFont("assets/fonts/DejaVuSansMono.ttf", fontSize)
	love.graphics.setFont(font)

	timeElapsed = 0.0
end

function resetPos()
	local bounds = getBounds(currentShape, currentShape.rotation)
	pos = { math.floor(cols/2), -bounds.y.max-1 }
end

function getNextShape()
	currentShape = nextShape
	currentShape.rotation = 1
	nextShape = shapes[math.random(#shapes)]
end

function displayShape(x, y)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(currentShape.color)

	local shape = currentShape[currentShape.rotation]

	for i = 1, #shape, 1 do
		love.graphics.rectangle("fill", (x+shape[i][1])*size+1, (y+shape[i][2])*size+1, size-2, size-2)
	end

	love.graphics.setColor(r, g, b, a)
end

function displayGrid()
	for row = 1, rows, 1 do
		for col = 1, cols, 1 do
			if (not (grid[row][col] == nil)) then
				local r, g, b, a = love.graphics.getColor()
				love.graphics.setColor(grid[row][col].color)
				love.graphics.rectangle("fill", (col-1)*size+1, (row-1)*size+1, size-2, size-2)
				love.graphics.setColor(r, g, b, a)
			end
		end
	end
end

function displayNextShape()
	local r, g, b, a = love.graphics.getColor()
	
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Next:", gameWidth+5, 5)

	love.graphics.setColor(0, 0, 0)

	local sideLength = 4*size
	local x = gameWidth + (menuWidth)/2
	local y = size+fontSize
	love.graphics.rectangle("fill", gameWidth + size, y, sideLength, sideLength)

	love.graphics.setColor(nextShape.color)
	
	local shape = nextShape[1]
	
	local bounds = getBounds(nextShape)
	x = x - (bounds.x.max + bounds.x.min + 1) * size * 0.5
	y = y + (3 - (bounds.y.max - bounds.y.min)) * size * 0.5

	for i = 1, #shape, 1 do
		love.graphics.rectangle("fill", x+shape[i][1]*size+1, y+shape[i][2]*size+1, size-2, size-2)
	end

	love.graphics.setColor(r, g, b, a)
end

function displayScore()
	local r, g, b, a = love.graphics.getColor()

	local sideLength = menuWidth - 10
	local y = 50 + fontSize + sideLength

	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Score:", gameWidth+5, y)

	y = y + fontSize + 15

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", gameWidth+5, y-5, sideLength, fontSize+10)

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(tostring(score), gameWidth+10, y)

	love.graphics.setColor(r, g, b, a)
end

function rotateShape()
	local prevRotation = currentShape.rotation

	currentShape.rotation = (currentShape.rotation + 1) % (#currentShape)
	if currentShape.rotation == 0 then
		currentShape.rotation = #currentShape
	end

	if (not checkIfFits()) then
		if (moveShape(-1)) then return end
		if (moveShape(1)) then return end
		currentShape.rotation = prevRotation
	end
end

function getBounds(shape, rotation)
	rotation = rotation or 1
	shape = shape[rotation]

	local minX = shape[1][1]
	local minY = shape[1][2]
	local maxX = shape[1][1]
	local maxY = shape[1][2]

	for i = 2, #shape, 1 do
		if shape[i][1] < minX then minX = shape[i][1] end
		if shape[i][2] < minY then minY = shape[i][2] end
		if shape[i][1] > maxX then maxX = shape[i][1] end
		if shape[i][2] > maxY then maxY = shape[i][2] end
	end

	return {
		x = {min = minX, max = maxX},
		y = {min = minY, max = maxY}
	}
end

function moveShape(dx)
	pos[1] = pos[1] + dx

	if (not checkIfFits()) then
		pos[1] = pos[1] - dx
		return false
	end
	return true
end

function moveDown()
	pos[2] = pos[2] + 1

	if (not checkIfFits()) then
		pos[2] = pos[2] - 1
		placeShape()
	end
end

function checkIfFits()
	local bounds = getBounds(currentShape, currentShape.rotation)

	return not (
		pos[2] + bounds.y.max >= rows or
		pos[1] + bounds.x.min < 0 or pos[1] + bounds.x.max >= cols or
		checkGrid()
	)
end

function checkGrid()
	local shape = currentShape[currentShape.rotation]

	for i = 1, #shape, 1 do
		local row = pos[2] + shape[i][2] + 1
		local col = pos[1] + shape[i][1] + 1
		if (col > 0 and col <= cols and row > 0 and row <= rows) then
			if (not (grid[row][col] == nil)) then
				return true
			end
		end
	end

	return false
end

function placeShape()
	local bounds = getBounds(currentShape, currentShape.rotation)
	if (pos[2] + bounds.y.min < 0) then
		gameOver = true
		return
	end

	local shape = currentShape[currentShape.rotation]

	for i = 1, #shape, 1 do
		grid[pos[2] + shape[i][2]+1][pos[1] + shape[i][1]+1] = currentShape
	end

	checkRows()

	getNextShape()
	resetPos()
end

function checkRows()
	local rowsCleared = 0
	for row = 1, rows, 1 do
		local filled = true
		for col = 1, cols, 1 do
			if (grid[row][col] == nil) then
				filled = false
				break
			end
		end

		if filled then
			rowsCleared = rowsCleared + 1
			clearRow(row)
		end
	end

	if rowsCleared > 0 then
		score = score + scores[rowsCleared]
	end
end

function clearRow(row)
	for r = row, 2, -1 do
		for c = 1, cols, 1 do
			grid[r][c] = grid[r-1][c]
		end
	end

	for c = 1, cols, 1 do
		grid[1][c] = nil
	end
end

function love.keypressed(key, scancode, isrepeat)
	if (key == 'escape') then
		love.event.quit()
	elseif (key == 'left') then
		moveShape(-1)
	elseif (key == 'right') then
		moveShape(1)
	elseif (key == 'up') then
		rotateShape()
	end
end

function love.update(dt)
	if (not gameOver) then
		local delay = 0.50
		timeElapsed = timeElapsed + dt
		if timeElapsed >= delay then
			moveDown()
			timeElapsed = timeElapsed - delay
		end
	end
end

function love.draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0.25, 0.25, 0.25)
	love.graphics.rectangle("fill", gameWidth, 0, menuWidth, height)

	displayShape(pos[1], pos[2])
	displayNextShape()
	displayScore()
	displayGrid()

	if (gameOver) then
		local y = (height-fontSize)/2
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", 0, y - 5, gameWidth, fontSize + 15)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("Game Over!", 90, y)
	end
	love.graphics.setColor(r, g, b, a)
end

function initShapes()
	shapeT = {
		{
			{0, 0},
			{-1, 1},
			{0, 1},
			{1, 1}
		}, {
			{0, 0},
			{0, 1},
			{0, 2},
			{1, 1}
		}, {
			{-1, 1},
			{0, 1},
			{1, 1},
			{0, 2}
		}, {
			{0, 0},
			{0, 1},
			{0, 2},
			{-1, 1}
		}
	}

	shapeT.rotation = 1
	shapeT.color = {1, 0, 1}

	shapeL = {
		{
			{0, 0},
			{0, 1},
			{0, 2},
			{1, 2},
		}, {
			{-1, 1},
			{0, 1},
			{1, 1},
			{-1, 2},
		}, {
			{-1, 0},
			{0, 0},
			{0, 1},
			{0, 2},
		}, {
			{-1, 1},
			{0, 1},
			{1, 1},
			{1, 0}
		},
	}

	shapeL.rotation = 1
	shapeL.color = {0, 0, 1}

	shapeJ = {
		{
			{0, 0},
			{0, 1},
			{0, 2},
			{-1, 2}
		}, {
			{-1, 0},
			{-1, 1},
			{0, 1},
			{1, 1}
		}, {
			{0, 0},
			{0, 1},
			{0, 2},
			{1, 0}
		}, {
			{-1, 1},
			{0, 1},
			{1, 1},
			{1, 2}
		}
	}

	shapeJ.rotation = 1
	shapeJ.color = {1, 0.5, 0}

	shapeI = {
		{
			{0, 0},
			{0, 1},
			{0, 2},
			{0, 3},
		}, {
			{-1, 1},
			{0, 1},
			{1, 1},
			{2, 1}
		-- }, {
		-- 	{1, 0},
		-- 	{1, 1},
		-- 	{1, 2},
		-- 	{1, 3}
		-- }, {
		-- 	{-1, 2},
		-- 	{0, 2},
		-- 	{1, 2},
		-- 	{2, 2}
		}
	}

	shapeI.rotation = 1
	shapeI.color = {0.5, 0.75, 1}

	shapeO = {
		{
			{0, 0},
			{1, 0},
			{0, 1},
			{1, 1}
		}
	}

	shapeO.rotation = 1
	shapeO.color = {1, 1, 0}

	shapeS = {
		{
			{0, 0},
			{1, 0},
			{-1, 1},
			{0, 1}
		}, {
			{0, 0},
			{0, 1},
			{1, 1},
			{1, 2}
		-- }, {
		-- 	{0, 1},
		-- 	{1, 1},
		-- 	{-1, 2},
		-- 	{0, 2}
		-- }, {
		-- 	{-1, 0},
		-- 	{-1, 1},
		-- 	{0, 1},
		-- 	{0, 2}
		}
	}

	shapeS.color = {0, 1, 0}
	shapeS.rotation = 1

	shapeZ = {
		{
			{0, 0},
			{-1, 0},
			{1, 1},
			{0, 1}
		}, {
			{1, 0},
			{0, 1},
			{1, 1},
			{0, 2}
		-- }, {
		-- 	{0, 1},
		-- 	{-1, 1},
		-- 	{1, 2},
		-- 	{0, 2}
		-- }, {
		-- 	{0, 0},
		-- 	{-1, 1},
		-- 	{0, 1},
		-- 	{-1, 2}
		}
	}

	shapeZ.color = {1, 0, 0}
	shapeZ.rotation = 1
end
