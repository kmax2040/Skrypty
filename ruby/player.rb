require 'ruby2d'
require './terrain'

class Player
	attr_accessor :up
	attr_accessor :left
	attr_accessor :right

	def initialize(row, col)
		@start_x = col * Terrain.size
		@start_y = row * Terrain.size
		@sprite = Sprite.new(
			'assets/sprites/Player.png',
			width: 64,
			height: 64,
			clip_width: 32,
			time: 35,
			x: @start_x,
			y: @start_y,
			z: 2,
			animations: {
				idle: 0..10,
				jump: 11..11,
				fall: 12..12,
				run: 13..24,
				doubleJump: 25..30,
				hit: 31..37,
				wallJump: 38..42
			}
		)

		Rectangle.new(
			x: 88, y: 24,
			height: 24, width: 3 * 64 + 16,
			color: '#008000',
			z: 19
		)
		@hp_bar = Rectangle.new(
			x: 96, y: 28,
			height: 16, width: 3 * 64,
			color: 'green',
			z: 20
		)

		@scoreText = Text.new(
			'00',
			x: (Terrain.cols-2) * Terrain.size, y: 24,
			font: "assets/fonts/VT323.ttf",
			size: 48,
			color: 'white',
			z: 20
		)

		@hitbox = { x1: 10.0, y1: 12.0,  x2: 54.0, y2: 64.0}
		@sprite.play animation: :idle, loop: true

		@vel = {x: 0.0, y: 0.0}
		@gravity = 640.0
		@jump_force = 320.0
		@max_fall_speed = 320.0
		@move_speed = 160.0
		self.reset
	end

	def take_damage()
		if @hit_cooldown == 0.0 then
			@vel[:y] = -160.0
			@sprite.play animation: :hit, flip: @flip do
				@sprite.play animation: :fall, loop: true, flip: @flip
			end
			@hit_cooldown = 1.25
			@hp -= 1
			@hp_bar.width = @hp * 64
		end
	end

	def get_point()
		@fruits += 1
		@scoreText.text = ("%02d" % @fruits)
	end

	def dead?()
		@hp == 0
	end

	def reset()
		@sprite.x = @start_x
		@sprite.y = @start_y
		@vel[:x] = 0.0
		@vel[:y] = 0.0
		@up = false
		@right = false
		@left = false
		@on_ground = true
		@can_double_jump = true
		@flip = nil
		@hit_cooldown = 0.0
		@hp = 3
		@fruits = 0
		@scoreText.text = '00'

		@hp_bar.width = @hp * 64
	end

	def update(dt, tiles, entities = nil)
		@hit_cooldown -= dt
		if @hit_cooldown < 0.0 then
			@hit_cooldown = 0.0
		end

		row = @sprite.y / Terrain.size
		col = (@sprite.x / Terrain.size).floor

		dx = 0
		if @left then
			dx -= 1
		end
		if @right then
			dx += 1
		end

		if dx == 0 then
			@vel[:x] = 0
			if @on_ground then
				@sprite.play animation: :idle, loop: true, flip: @flip
			end
		else
			@vel[:x] = @move_speed * dx
			if dx > 0 then
				@flip = nil
			elsif dx < 0 then
				@flip = :horizontal
			end
			if @on_ground then
				@sprite.play animation: :run, loop: true, flip: @flip
			end
		end

		if @hit_cooldown == 0.0 then
			if @vel[:y] > 0 then
				@sprite.play animation: :fall, loop: true, flip: @flip
			elsif @vel[:y] < 0 and @can_double_jump then
				@sprite.play animation: :jump, loop: true, flip: @flip
			end
		end

		# jump
		if @up then
			@up = false
			if @on_ground then
				@on_ground = false
				@vel[:y] = -@jump_force
			elsif @can_double_jump then
				@can_double_jump = false
				@vel[:y] = -@jump_force
				@sprite.play animation: :doubleJump, flip: @flip do
				 	@sprite.play animation: :jump, loop: true, flip: @flip
				end
			end
		end

		prev_bounding_box = self.bounding_box

		# player movement
		@sprite.x += @vel[:x] * dt
		@vel[:y] += @gravity*dt
		if @vel[:y] > @max_fall_speed then
			@vel[:y] = @max_fall_speed
		end
		@sprite.y += @vel[:y] * dt

		curr_bounding_box = self.bounding_box

		# collision detections
		if row >= 0 and row < Terrain.rows then
			col1 = (curr_bounding_box[:x1].floor+5) / Terrain.size
			col2 = (curr_bounding_box[:x2].floor-5) / Terrain.size

			# floor
			row += 1

			if row >= Terrain.rows then
				@hp = 0
			else
				if (col1 >= 0 and tiles[row][col1] == 'G') or (col2 < Terrain.cols and tiles[row][col2] == 'G') then
					ground_y = row * Terrain.size

					if prev_bounding_box[:y2] <= ground_y and curr_bounding_box[:y2] > ground_y then
						@vel[:y] = 0
						@sprite.y += ground_y - curr_bounding_box[:y2]
						@on_ground = true
						@can_double_jump = true
					end
				else
					@on_ground = false
				end
			end

			# roof
			row = (prev_bounding_box[:y1] / Terrain.size).floor - 1

			if row >= 0 then
				if (col1 >= 0 and tiles[row][col1] == 'G') or (col2 < Terrain.cols and tiles[row][col2] == 'G') then
					roof_y = (row+1) * Terrain.size

					if prev_bounding_box[:y1] >= roof_y and curr_bounding_box[:y1] < roof_y then
						@vel[:y] = 0
						@sprite.y += roof_y - curr_bounding_box[:y1]
					end
				end
			end
		end

		if col >= 0 and col < Terrain.cols then
			row1 = (curr_bounding_box[:y1].floor+5) / Terrain.size
			row2 = (curr_bounding_box[:y2].floor-5) / Terrain.size

			# right wall
			col += 1
			if col < Terrain.cols then
				if (row1 >= 0 and row1 < Terrain.rows and tiles[row1][col] == 'G') or (row2 >= 0 and row2 < Terrain.rows and tiles[row2][col] == 'G') then
					right_wall_x = col.floor * Terrain.size
					
					if prev_bounding_box[:x2] <= right_wall_x and curr_bounding_box[:x2] > right_wall_x then
						@vel[:x] = 0
						@sprite.x -= curr_bounding_box[:x2] - right_wall_x
					end
				end
			end

			#left wall
			col = (prev_bounding_box[:x1] / Terrain.size).floor - 1
			if col >= 0 then
				if (row1 >= 0 and row1 < Terrain.rows and tiles[row1][col] == 'G') or (row2 >= 0 and row2 < Terrain.rows and tiles[row2][col] == 'G') then
					left_wall_x = (col+1) * Terrain.size
					
					if prev_bounding_box[:x1] >= left_wall_x and curr_bounding_box[:x1] < left_wall_x then
						@vel[:x] = 0
						@sprite.x += left_wall_x - curr_bounding_box[:x1]
					end
				end
			end
		end
	end

	def bounding_box
		{ x1: @sprite.x + @hitbox[:x1], y1: @sprite.y + @hitbox[:y1], x2: @sprite.x + @hitbox[:x2], y2: @sprite.y + @hitbox[:y2] }
	end

	def contains?(x, y)
		x > @sprite.x + @hitbox[:x1] and x < @sprite.x + @hitbox[:x2] and y > @sprite.y + @hitbox[:y1] and y < @sprite.y + @hitbox[:y2]
	end

	def sprite
		@sprite
	end
end
