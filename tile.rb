class Tile
  
  attr_accessor :x,:y, :score, :parent

  def initialize(x,y)
    @x = x
    @y = y
    @score = Score.new(self)
  end

  def to_s
    "Tile:: Pos: #{[x,y]} Parent: #{[self.parent.x, self.parent.y] if self.parent} "#{}F-score: #{score.f}"  
  end

  def adjacent_to?(other_tile)
    x_distance = (self.x - other_tile.x).abs
    y_distance = (self.y - other_tile.y).abs

    x_distance + y_distance == 1 || (x_distance == 1 && y_distance == 1)
  end

  def distance(other_tile)
    ((self.x - other_tile.x) ** 2 + (self.y - other_tile.y) ** 2) ** 0.5
  end

  def is_new_parent_better?(potential_parent)
    distance = self.distance(potential_parent)
    potential_parent.score.g + distance * Score::MOVE_VALUE < self.score.g
  end

  def <=>(other_tile)
    self.score.f <=> other_tile.score.f
  end

end

#still need to set initial score
class StartTile < Tile
  class << self
    attr_accessor :x, :y, :self
  end

  def initialize(x,y)
    super(x,y)
    StartTile.x, StartTile.y = x, y
    StartTile.self = self
  end

end

class TargetTile < Tile
  class << self
    attr_accessor :x, :y, :self
  end

  def initialize(x,y)
    super(x,y)
    TargetTile.x, TargetTile.y = x, y
    TargetTile.self = self
  end
end


