require 'ruby2d'

class Cherry
	@@points = [
		{x: 16, y: 32},
		{x: 32, y: 16},
		{x: 32, y: 48},
		{x: 48, y: 16}
	]

	def initialize(x, y)
		@start_y = y
		@sprite = Sprite.new(
			"assets/sprites/Cherry.png",
			x: x, y: y,
			clip_width: 32,
			time: 35,
			width: 64.0,
			height: 64.0,
			z: 2,
			animations: {
				idle: 0..16,
				collect: 17..22
			}
		)
		self.reset
	end

	def reset()
		@sprite.add
		@sprite.play animation: :idle, loop: true
		@collected = false
		@sprite.y = @start_y
	end

	def collides?(player)
		if @collected then
			return false
		end

		@@points.each do |point|
			if player.contains? @sprite.x + point[:x], @sprite.y + point[:y] then
				return true
			end
		end

		false
	end

	def collect
		@collected = true
		@sprite.play animation: :collect do
			@sprite.y = -64
		end
	end
end
