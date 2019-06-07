class ClueController < ApplicationController
  def random
    sql = Arel.sql('RANDOM()')
    random_clue = Clue.order(sql).first

    render json: random_clue.to_json
  end
end
