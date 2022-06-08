require 'ruby2d'
require './player'
require './terrain'

terrain = Terrain.new(
	[
		['G', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '%', '%', '%', '%', '%', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'G'],
		['G', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '%', ' ', ' ', ' ', 'G'],
		['G', ' ', ' ', ' ', ' ', ' ', 'G', 'G', 'G', '^', '^', '^', '^', '^', 'G', ' ', ' ', 'G', ' ', ' ', ' ', 'F', ' ', 'G'],
		['G', 'G', 'G', 'G', 'G', ' ', ' ', ' ', 'G', 'G', 'G', 'G', 'G', 'G', 'G', ' ', ' ', ' ', ' ', ' ', 'G', 'G', 'G', 'G'],
		['G', ' ', ' ', '%', 'G', ' ', ' ', ' ', 'V', 'V', 'V', '%', '%', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'G', 'G', 'G'],
		['G', ' ', '<', 'G', 'G', 'G', 'G', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '%', '%', '%', ' ', 'G', 'G', 'G'],
		['G', '%', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'G', 'G', 'G', ' ', 'V', 'V', 'G'],
		['G', 'G', ' ', ' ', ' ', ' ', ' ', ' ', 'G', 'G', 'G', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '%', '%', 'G'],
		['G', '%', '%', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'G', ' ', ' ', ' ', ' ', ' ', 'G', 'G', 'G'],
		['G', 'G', 'G', '>', ' ', ' ', ' ', ' ', ' ', ' ', '<', 'G', 'G', 'G', ' ', ' ', ' ', '%', '%', ' ', ' ', ' ', ' ', 'G'],
		['G', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '<', 'G', '%', '%', ' ', ' ', ' ', 'G', 'G', ' ', ' ', ' ', ' ', 'G'],
		['G', 'G', 'G', 'G', 'G', ' ', ' ', ' ', 'G', 'G', 'G', 'G', 'G', 'G', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'G']
	]
)

set title: "Platformer", width: Terrain.cols*Terrain.size, height: Terrain.rows*Terrain.size, background: 'blue'

player = Player.new Terrain.rows-2, 2

finished = Text.new(
	'Level Finished!',
	x: 532, y: 256,
	size: 64,
	font: 'assets/fonts/VT323.ttf',
	color: 'white',
	z: 20
)

finished.remove

on :key_down do |event|
	if event.key == 'a' or event.key == 'left' then
		player.left = true
	elsif event.key == 'd' or event.key == 'right' then
		player.right = true
	elsif event.key == 'w' or event.key == 'up' then
		player.up = true
	elsif event.key == 'escape' then
		close
	end
end

on :key_up do |event|
	if event.key == 'a' or event.key == 'left' then
		player.left = false
	elsif event.key == 'd' or event.key == 'right' then
		player.right = false
	end
end

dt = 0
prev_time = Time.now

update do
	time_now = Time.now
	dt = (time_now - prev_time).to_f
	prev_time = time_now

	player.update dt, terrain.tiles

	terrain.spikes.each do |spike|
		if spike.collides? player then
			player.take_damage
		end
	end

	terrain.cherries.each do |cherry|
		if cherry.collides? player then
			cherry.collect
			player.get_point
		end
	end

	if player.dead? then
		player.reset
		terrain.reset_fruits
	end

	if terrain.flag.collides? player then
		terrain.flag.show_flag
		finished.add
	end
end

show
