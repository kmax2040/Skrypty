require 'ruby2d'

class Flag
	@@offset = { x: 23, y: 21 }
	def initialize(x, y)
		@sprite = Sprite.new(
			"assets/sprites/Flag.png",
			x: x, y: y,
			clip_width: 64,
			width: 64, height: 64,
			time: 35,
			z: 1,
			animations: {
				hidden: 0..0,
				idle: 1..10,
				out: 11..36
			}
		)

		self.reset
	end

	def reset()
		@finished = false
		@sprite.play animation: :hidden
	end

	def collides?(player)
		player.contains? @sprite.x + @@offset[:x], @sprite.y + @@offset[:y]
	end

	def show_flag
		if not @finnished then
			@finished = true
			@sprite.play animation: :out do
				@sprite.play animation: :idle, loop: true
			end
		end
	end
end
