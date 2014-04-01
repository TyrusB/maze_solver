class Score
  MOVE_VALUE = 10

  attr_accessor :associated_tile, :g, :h, :f

  def initialize(tile)
    @associated_tile = tile
  end

  def calculate_manhattan_value
    x_est = (TargetTile.x - self.associated_tile.x).abs
    y_est = (TargetTile.y - self.associated_tile.y).abs

    x_est + y_est
  end

  def set_initial_score(parent_score = Score.new)
    distance = self.associated_tile.distance(parent_score.associated_tile)

    self.g = parent_score.g + distance * MOVE_VALUE
    self.h = calculate_manhattan_value
    self.f = self.g + self.h
  end

  def set_start_score
    self.g = 0
    self.h = self.calculate_manhattan_value
  end

end
