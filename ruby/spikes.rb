require 'ruby2d'

class Spikes
	@@offsets = [
		{x: 4, y: 60},
		{x: 4, y: 48},
		{x: 12, y: 36},
		{x: 28, y: 36},
		{x: 44, y: 36},
		{x: 52, y: 48},
		{x: 52, y: 60}
	]

	def initialize(x, y, rotation)
		@sprite = Image.new(
			"assets/sprites/Spikes.png",
			x: x,
			y: y,
			rotate: rotation,
			width: 64,
			height: 64,
			z: 1
		)

		bottom_y = y + 64.0		

		if rotation == 0 then
			@points = [
				{x: x + @@offsets[0][:x], y: y + @@offsets[0][:y]},
				{x: x + @@offsets[1][:x], y: y + @@offsets[1][:y]},
				{x: x + @@offsets[2][:x], y: y + @@offsets[2][:y]},
				{x: x + @@offsets[3][:x], y: y + @@offsets[3][:y]},
				{x: x + @@offsets[4][:x], y: y + @@offsets[4][:y]},
				{x: x + @@offsets[5][:x], y: y + @@offsets[5][:y]},
				{x: x + @@offsets[6][:x], y: y + @@offsets[6][:y]}
			]
		elsif rotation == 90 then
			@points = [
				{x: x + 60 - @@offsets[0][:y], y: y + 56 - @@offsets[0][:x]},
				{x: x + 60 - @@offsets[1][:y], y: y + 56 - @@offsets[1][:x]},
				{x: x + 60 - @@offsets[2][:y], y: y + 56 - @@offsets[2][:x]},
				{x: x + 60 - @@offsets[3][:y], y: y + 56 - @@offsets[3][:x]},
				{x: x + 60 - @@offsets[4][:y], y: y + 56 - @@offsets[4][:x]},
				{x: x + 60 - @@offsets[5][:y], y: y + 56 - @@offsets[5][:x]},
				{x: x + 60 - @@offsets[6][:y], y: y + 56 - @@offsets[6][:x]}
			]
		elsif rotation == 180 then
			@points = [
				{x: x + 60 - @@offsets[0][:x], y: y + 60 - @@offsets[0][:y]},
				{x: x + 60 - @@offsets[1][:x], y: y + 60 - @@offsets[1][:y]},
				{x: x + 60 - @@offsets[2][:x], y: y + 60 - @@offsets[2][:y]},
				{x: x + 60 - @@offsets[3][:x], y: y + 60 - @@offsets[3][:y]},
				{x: x + 60 - @@offsets[4][:x], y: y + 60 - @@offsets[4][:y]},
				{x: x + 60 - @@offsets[5][:x], y: y + 60 - @@offsets[5][:y]},
				{x: x + 60 - @@offsets[6][:x], y: y + 60 - @@offsets[6][:y]}
			]
		elsif rotation == 270 then
			@points = [
				{x: x + @@offsets[0][:y], y: y + 4 + @@offsets[0][:x]},
				{x: x + @@offsets[1][:y], y: y + 4 + @@offsets[1][:x]},
				{x: x + @@offsets[2][:y], y: y + 4 + @@offsets[2][:x]},
				{x: x + @@offsets[3][:y], y: y + 4 + @@offsets[3][:x]},
				{x: x + @@offsets[4][:y], y: y + 4 + @@offsets[4][:x]},
				{x: x + @@offsets[5][:y], y: y + 4 + @@offsets[5][:x]},
				{x: x + @@offsets[6][:y], y: y + 4 + @@offsets[6][:x]}
			]
		end

		# @points.each do |point|
		# 	Square.new(
		# 		x: point[:x],
		# 		y: point[:y],
		# 		size: 4,
		# 		color: 'red',
		# 		z: 15
		# 	)
		# end
	end

	def collides?(player)
		@points.each do |point|
			if player.contains? point[:x], point[:y] then
				return true
			end
		end

		false
	end
end
