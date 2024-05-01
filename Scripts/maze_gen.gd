extends Node2D

const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {
	Vector2(0,-6): N,
	Vector2(6,0): E,
	Vector2(0,6): S,
	Vector2(-6,0): W
}
var cell_size = Vector2(16,16)
var width = 10
var height = 10
var player = preload("res://Characters/player.tscn")
var chest = preload("res://Objects/chest.tscn")
var mob = preload("res://Characters/enemy.tscn")
var boss = preload("res://Characters/boss.tscn")

@onready var Map = $TileMap
@onready var Set = Map.tile_set
@onready var loading_camera = $Camera2D2

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	make_maze()

func find(parent, i):
	if parent[i] != i:
		parent[i] = find(parent, parent[i])
	return parent[i]
	
func erase_square(layer,cell):
	for x in range(6):
		var Tx = cell.x + x
		for y in range(6):
			var Ty = cell.y +y
			Map.erase_cell(layer,Vector2(Tx,Ty))
	
func connect_tree(parent, rank, x, y):
	var xroot = find(parent, x)
	var yroot = find(parent, y)
	
	if rank[xroot] < rank[yroot]:
		parent[xroot] = yroot
	elif rank[xroot] > rank[yroot]:
		parent[yroot] = xroot
	else:
		parent[yroot] = xroot
		rank[xroot] += 1

func set_pattern(layer:int, pos:Vector2, patternNum:int):
	Map.set_pattern(layer, pos, Set.get_pattern(patternNum))
		
func spawn_player(pos:Vector2):
	var playerInst = player.instantiate()
	playerInst.position = pos
	add_child(playerInst)

func spawn_chest(pos:Vector2):
	var chestInst = chest.instantiate()
	chestInst.position = pos
	add_child(chestInst)
	
func spawn_mob(pos:Vector2):
	var mobInst = mob.instantiate()
	mobInst.position = pos
	add_child(mobInst)

func spawn_boss(pos:Vector2):
	var bossInst = boss.instantiate()
	bossInst.position = pos
	add_child(bossInst)
	
func make_maze():
	Map.clear()
	loading_camera.loading_screen()
	var edges = []
	var parent = {}
	var rank = {}
	var cell_dict = {}
	
	# init cells, sets, and edges
	for x in range(width):
		for y in range(height):
			var cell = Vector2(x * 6,y * 6)
			cell_dict[cell] = N|E|S|W # using bitwise or for pattern references
			set_pattern(0,cell,cell_dict[cell])
			
			parent[cell] = cell
			rank[cell] = 0
			
			# Add edges (walls)
			if x > 0:
				edges.append([cell,cell+Vector2(-6,0)])
			if y > 0:
				edges.append([cell, cell+Vector2(0,-6)])
	
	#Shuffle edges
	randomize()
	edges.shuffle()
	
	# Kruskal's Algorithm Implementation
	for edge in edges:
		var cell1 = edge[0]
		var cell2 = edge[1]
		if find(parent, cell1) != find(parent, cell2):
			connect_tree(parent, rank, cell1, cell2)
			var dir = cell2 - cell1
			cell_dict[cell1] -= cell_walls[dir]
			cell_dict[cell2] -= cell_walls[-dir]
			erase_square(0,cell1)
			set_pattern(0,cell1,0)
			erase_square(0,cell1)
			set_pattern(0, cell1, cell_dict[cell1])
			set_pattern(1, cell1, 16)
			erase_square(0,cell2)
			set_pattern(0, cell2, cell_dict[cell2])
			set_pattern(1, cell2, 16)
			
		await get_tree().create_timer(0.01).timeout
	
	# 100% chance mob spawns on area with 3 flat tiles, 20% chance mobs spawn on area with 2 flat tiles
	var flat_tiles = [4,5,6,7,12,13]
	var player_spawn = false
	var checked_cells = []
	for cells in cell_dict.keys():
		if cell_dict[cells] in flat_tiles:
			if cells in checked_cells:
				
				continue
			# loop going west and then east to see how many flat tiles are in the list
			var length = 0
			length += 1
			checked_cells.append(cells)
			if cell_dict[cells]&W!=W:
				var temp = cells + Vector2(-6, 0)
				while cell_dict[temp]&W!=W and cell_dict[temp]&S==S:
					if temp in checked_cells:
						break
					checked_cells.append(temp)
					length += 1
					temp += Vector2(-6, 0)
					if temp not in cell_dict.keys():
						break
			if cell_dict[cells]&E!=E:
				
				var temp = cells + Vector2(6, 0)
				while cell_dict[temp]&E!=E and cell_dict[temp]&S==S:
					if temp in checked_cells:
						break
					checked_cells.append(temp)
					length += 1
					temp += Vector2(6, 0)
					if temp not in cell_dict.keys():
						break
			if length >= 3:
				spawn_mob((cells+Vector2(5,4))*cell_size)
				if not player_spawn:
					await get_tree().create_timer(0.1).timeout
			elif length == 2 and randi_range(1,100)>10:
				spawn_mob((cells+Vector2(5,4))*cell_size)
			await get_tree().create_timer(0.1).timeout
			
	# Add enterence and exit
	var pos_enter = []
	var pos_exit = []
	for i in range(height):
		var left_cell = Vector2(0,i * 6)
		if cell_dict[left_cell] & S == S:
			pos_enter.append(left_cell)
		var right_cell = Vector2((width-1) * 6,i * 6)
		if cell_dict[right_cell] & S == S:
			pos_exit.append(right_cell)
	
	pos_enter.shuffle()
	var cell = pos_enter[0]
	cell_dict[cell] = cell_dict[cell]-W
	erase_square(0,cell)
	set_pattern(0,cell,cell_dict[cell])
	pos_exit.shuffle()
	cell = pos_exit[0]
	cell_dict[cell] = cell_dict[cell]-E
	erase_square(0,cell)
	set_pattern(0,cell,cell_dict[cell])
	await get_tree().create_timer(0.01).timeout
	
	# Add top layer
	for i in range(width):
		cell = Vector2(i * 6, -1)
		set_pattern(0,cell,17)
	
	await get_tree().create_timer(0.01).timeout
	# Add right layer
	for i in range(height):
		cell = Vector2(width * 6, i * 6)
		if i * 6 == pos_exit[0].y:
			set_pattern(0,cell+Vector2(0,4),23)
			set_pattern(0,cell+Vector2(6,4),23)
			set_pattern(0,cell+Vector2(0,6),24)
			set_pattern(1,cell,26)
			spawn_boss((cell+Vector2(1,4))*cell_size)
			break
		set_pattern(0,cell,18)
		
	cell = Vector2(width*6, -1)
	set_pattern(0,cell,19)
	await get_tree().create_timer(0.01).timeout
	
	# Add left layer
	for i in range(height):
		cell = Vector2(-6, i * 6)
		if i * 6 == pos_enter[0].y:
			set_pattern(0,cell,22)
			set_pattern(0,cell+Vector2(-30,4),23)
			set_pattern(0,cell+Vector2(-30,6),24)
			set_pattern(1,cell+Vector2(3,0),27)
			spawn_player((cell+Vector2(5,3))*cell_size)
			break
		set_pattern(0,cell,20)
	
	set_pattern(0,Vector2(-6,-1), 21)
	set_pattern(0,Vector2(0,60),25)
	await get_tree().create_timer(0.01).timeout
		
	var enemyList = []
	for enemy in get_tree().root.get_children()[0].get_children():
		if enemy.has_method("player_hit"):
			enemyList.append(enemy)
	
	# Add chests
	var loc = Vector2.ZERO
	var avail_chests = randi_range(9,12)
	var possible_chests = [7,13,14]
	for cells in cell_dict.keys():
		if cell_dict[cells] in possible_chests:
			if randi_range(1,100)>60 and avail_chests>0:
				loc = (cells+Vector2(3,4))*cell_size
				while checkLocation(loc,enemyList):
					await get_tree().create_timer(0.1).timeout
				spawn_chest(loc)
				avail_chests -= 1
				await get_tree().create_timer(0.1).timeout

func checkLocation(loc, enemies):
	for enemy in enemies:
		var diff = loc - enemy.global_position
		if (diff < cell_size and diff > -cell_size) or (diff > cell_size and diff < -cell_size):
			return true
	return false

