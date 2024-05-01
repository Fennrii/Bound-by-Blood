extends Node2D

@export var width : int = 10
@export var height : int = 10
# defining directions
var N = 1
var S = 2
var E = 4
var W = 8
# Deltas for X and Y on directions
var DX = {N: 0, S: 0, E: 1, W: -1}
var DY = {N: -1, S: 1, E: 0, W: 0}
# Opposite direction
var OPPOSITE = {N: S, S: N, E: W, W: E} 


func _ready():
	print("maze_gen_og Started")
	#print(N)
	randomize()
	var grid = []
	for _i in range(height):
		var row = []
		for _j in range(width):
			row.append(0)
		grid.append(row)
	var sets = []
	for _i in range(height):
		var row = []
		for _j in range(width):
			row.append(TempTree.new())
		sets.append(row)
	var edges = []
	for y in range(height):
		for x in range(width):
			if y > 0:
				edges.append([x, y, N])
			if x > 0:
				edges.append([x, y, W])
	edges.shuffle()
	# Implementation of Kruskal’s algorithm
	while edges:
		var popped = edges.pop_back()
		var x = popped[0]
		var y = popped[1]
		var direction = popped[2]
		var nx = x+DX[direction]
		var ny = y+DY[direction]
		var set1 = sets[y][x]
		var set2 = sets[ny][nx]
		if not set1.is_tree_connected(set2):
			#printraw(" ")
			#display_maze(grid)
			await(get_tree().create_timer(0.02))
			
			set1.connect_tree(set2)
			grid[y][x] |= direction
			grid[ny][nx] |= OPPOSITE[direction]
	display_maze(grid)
	#print(" ")
	
# Function to see if the maze is being made properly
#func display_maze(grid):
	#print(" " + "_".repeat(len(grid[0]) * 2 - 1))
	#for y in range(len(grid)):
		#var row = grid[y]
		#var maze_row = "|"
		#for x in range(len(row)):
			#var cell = row[x]
			#maze_row += "_" if cell & S == 0 else " "
			#if cell & E != 0:
				#maze_row += "_" if (cell | row[x + 1]) & S == 0 else " "
			#else:
				#maze_row += "|"
		#print(maze_row)
	#print()
	
func display_maze(grid):
	var tilemap = get_node_or_null("/root/TestLevel/MainTileMap")
	if tilemap:
		tilemap.clear()
		print("og")
		# Go through the grid and set the tiles in the TileMap
		for y in range(len(grid)):
			var row = grid[y]
			for x in range(len(row)):
				var cell = row[x]
				var tile_id = grid[y][x]  # Your logic to determine the tile ID
				var atlas_coords = Vector2i(1, 6)  # Replace with your tile's atlas coordinates
				# Set the cell with atlas coordinates
				tilemap.set_cell(0, Vector2i(x, y), tile_id, atlas_coords)
	else:
		print("MainTileMap node not found. Check the node path and make sure it's available in the scene.")







	#print(" ".repeat(grid[0].size() * 2 - 1))
	#for y in range(len(grid)):
		#var row = grid[y]
		#print("|")
		#for x in range(len(row)):
			#var cell = row[x]
			#print("_" if cell & S == 0 else " ")
			#if cell & E != 0:
				#print("_" if (cell | (row[x + 1] if x + 1 < len(row) else 0)) & S == 0 else " ") 
			#else:
				#print("|")
		#print()    var maze_str := ""


# Class to connect two trees together 
class TempTree:
	var parent = null
		
	func root():
		var current = self
		while current.parent:
			current = current.parent
		return current
	
	func is_tree_connected(tree : TempTree):
		return root() == tree.root()
	
	func connect_tree(tree : TempTree):
		var root1 = self.root()
		var root2 = tree.root()
		if root1!=root2:
			root2.parent = root1
		
	

	
