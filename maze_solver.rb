# Questions - start/target in map or solver
# => get_adjacent_tiles in map or tile

load './score.rb'
load './tile.rb'
require 'colorize'

class Map
  attr_accessor :bag, :map, :map_data

  def initialize(file_loc)
    @bag = []
    
    @map_data = File.readlines("./#{file_loc}")
    add_valid_tiles(self.map_data)
  end

  def add_valid_tiles(map_data)
    map_data.each_with_index do |entry, y_coor|
      row = entry.split(//)
      row.each_with_index do |char, x_coor|
        #p "Char:#{char}|, x_coor:#{x_coor}|, y_coor:#{y_coor}|"
        case char
        when " "
          @bag << Tile.new(x_coor, y_coor)
        when "S"
          @bag << StartTile.new(x_coor, y_coor)
        when "E"
          @bag << TargetTile.new(x_coor, y_coor)
        end
      end
    end
    @bag
  end

  def get_adjacent_tiles(center_tile)
    [].tap do |adjacent_tiles|
      @bag.each do |comparison_tile|
        adjacent_tiles << comparison_tile if center_tile.adjacent_to?(comparison_tile)
      end
    end
  end

  def get_parent_chain(current_tile)
    return [current_tile] if current_tile.parent.nil?

    get_parent_chain(current_tile.parent) << current_tile
  end

  def place_path_markers(parent_chain)
    parent_chain.reverse.each do |path_tile|
      x_coor, y_coor = path_tile.x, path_tile.y
      unless ["S", "E"].include?(map_data[y_coor][x_coor])
        self.map_data[y_coor][x_coor] = "X"
      end
    end
  end

  def display
    system("clear")
    self.map_data.each do |row|
      row.each_char do |char|
        print "#{char} "
      end
    end
  end
end

class Solver
  require 'Set'
  attr_accessor :open_list, :closed_list, :map

  def initialize(file_loc)
    @map = Map.new(file_loc)
  end

  def solve_map
    StartTile.self.score.set_start_score
    self.open_list = [StartTile.self]
    self.closed_list = []

    
    until self.closed_list.include?(TargetTile.self)
      return nil if self.open_list.empty?
      cycle_once
    end
 
    pathway = @map.get_parent_chain(TargetTile.self)
    @map.place_path_markers(pathway)
    @map.display; nil
  end

  def cycle_once
    #First select the tile with the lowest F-score from the open-list and shift it
    active_tile = self.open_list.sort!.shift
    # Second set the active tile to the closed list
    self.closed_list << active_tile
    # Third get the adjacent tiles and do your processing
    process_adjacent_tiles(active_tile)
  end
  #require 'debugger'
  def process_adjacent_tiles(active_tile)
    nearby_tiles = @map.get_adjacent_tiles(active_tile)
    
    nearby_tiles.each do |nearby_tile|
      #first, skip if the tile is already on the closed list
      next if self.closed_list.include?(nearby_tile)

      #if not in the open list (and not in closed list because of above check), open it up.
      if !self.open_list.include?(nearby_tile)
        @open_list << nearby_tile
        nearby_tile.parent = active_tile
        nearby_tile.score.set_initial_score(active_tile.score) #this sets an initial score with self as parent
      # if not, need to test if we replace g-scores.
      elsif nearby_tile.is_new_parent_better?(active_tile)
        nearby_tile.parent = active_tile
        # still need to implement score replacement
      end
    end
  end

end

map = Solver.new('maze.txt')
map.solve_map