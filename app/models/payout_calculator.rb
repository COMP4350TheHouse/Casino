# Class for paying out winning numbers
class PayoutCalculator
  BET_MULTIPLIERS = {
    straight_up: 35,
    row: 3,
    dozen: 3,
    even_money: 2
  }.freeze

  ROW_BETS = {
    37 => [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36],
    38 => [2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35],
    39 => [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34]
  }.freeze

  DOZEN_BETS = {
    40 => (1..12),
    41 => (13..24),
    42 => (25..36)
  }.freeze

  EVEN_MONEY_BETS = {
    43 => (1..18),
    44 => ->(num) { num.even? && num != 0 },
    45 => [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36],
    46 => [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35],
    47 => ->(num) { num.odd? && num != 0 },
    48 => (19..36)
  }.freeze

  def initialize(bet_id, winning_number)
    @bet_id = bet_id
    @winning_number = winning_number
  end

  def calculate
    return BET_MULTIPLIERS[:straight_up] if straight_up?
    return BET_MULTIPLIERS[:row] if row_bet?
    return BET_MULTIPLIERS[:dozen] if dozen_bet?
    return BET_MULTIPLIERS[:even_money] if even_money_bet?

    0
  end

  private

  def straight_up?
    @bet_id == @winning_number && (0..36).cover?(@bet_id)
  end

  def row_bet?
    ROW_BETS[@bet_id]&.include?(@winning_number)
  end

  def dozen_bet?
    DOZEN_BETS[@bet_id]&.include?(@winning_number)
  end

  def even_money_bet?
    condition = EVEN_MONEY_BETS[@bet_id]
    condition.is_a?(Proc) ? condition.call(@winning_number) : condition&.include?(@winning_number)
  end
end
