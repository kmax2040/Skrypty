require 'ruby2d'
require './spikes'
require './cherry'
require './flag'

class Terrain
	attr_reader :tiles
	attr_reader :spikes
	attr_reader :cherries
	attr_reader :flag

	@@size = 64

	@@grass = Tileset.new(
		"assets/sprites/Grass.png",
		tile_width: 16,
		tile_height: 16,
		scale: 2,
		z: 0
	)
	
	@@grass.define_tile('top-left', 0, 0)
	@@grass.define_tile('top', 1, 0)
	@@grass.define_tile('top-right', 2, 0)
	@@grass.define_tile('left', 0, 1)
	@@grass.define_tile('middle', 1, 1)
	@@grass.define_tile('right', 2, 1)
	@@grass.define_tile('bottom-left', 0, 2)
	@@grass.define_tile('bottom', 1, 2)
	@@grass.define_tile('bottom-right', 2, 2)

	def grass
		@@grass
	end

	def self.rows
		@@rows
	end

	def self.cols
		@@cols
	end

	def self.size
		@@size
	end

	def initialize(tiles)
		@tiles = tiles
		@@rows = @tiles.length
		@@cols = @tiles[0].length

		@spikes = []
		@cherries = []

		y = 0
		@tiles.each_with_index do |line, row|
			x = 0
			line.each_with_index do |cell, col|
				if cell == 'G' then # grass
					if row == 0 or @tiles[row-1][col] != 'G' then # check top
						if col == 0 or @tiles[row][col-1] != 'G' then # check top-left
							@@grass.set_tile('top-left', [{x: x, y: y}])
						else
							@@grass.set_tile('top', [{x: x, y: y}])
						end

						if col + 1 == @@cols or @tiles[row][col+1] != 'G' then #check top-right
							@@grass.set_tile('top-right', [{x: x+32, y: y}])
						else
							@@grass.set_tile('top', [{x: x+32, y: y}])
						end
					else
						if col == 0 or @tiles[row][col-1] != 'G' then # check left
							@@grass.set_tile('left', [{x: x, y: y}])
						else
							@@grass.set_tile('middle', [{x: x, y: y}])
						end

						if col + 1 == @@cols or @tiles[row][col+1] != 'G' then # check right
							@@grass.set_tile('right', [{x: x+32, y: y}])
						else
							@@grass.set_tile('middle', [{x: x+32, y: y}])
						end
					end
					y += 32
					if row + 1 == @@rows or @tiles[row + 1][col] != 'G' then # check bottom
						if col == 0 or @tiles[row][col-1] != 'G' then # check bottom-left
							@@grass.set_tile('bottom-left', [{x: x, y: y}])
						else
							@@grass.set_tile('bottom', [{x: x, y: y}])
						end

						if col + 1 == @cols or @tiles[row][col+1] != 'G' then # check bottom-right
							@@grass.set_tile('bottom-right', [{x: x+32, y: y}])
						else
							@@grass.set_tile('bottom', [{x: x+32, y: y}])
						end
					else
						if col == 0 or @tiles[row][col-1] != 'G' then # check left
							@@grass.set_tile('left', [{x: x, y: y}])
						else
							@@grass.set_tile('middle', [{x: x, y: y}])
						end

						if col + 1 == @cols or @tiles[row][col+1] != 'G' then # check right
							@@grass.set_tile('right', [{x: x+32, y: y}])
						else
							@@grass.set_tile('middle', [{x: x+32, y: y}])
						end
					end
					y -= 32
				elsif cell == '^' then # spikes
					@spikes.append Spikes.new(x, y, 0)
				elsif cell == '>' then
					@spikes.append Spikes.new(x, y, 90)
				elsif cell == 'V' then
					@spikes.append Spikes.new(x, y, 180)
				elsif cell == '<' then
					@spikes.append Spikes.new(x, y, 270)
				elsif cell == '%' then # cherry
					@cherries.append Cherry.new(x, y)
				elsif cell == 'F' then # flag
					@flag = Flag.new(x, y)
				end
				x += 64
			end
			y += 64
		end
	end

	def reset_fruits()
		@cherries.each do |cherry|
			cherry.reset
		end
	end
end
