class_name Score
extends Object

var cheater := false

# Devils catched score.
var devils_total := 0 # Total
var devils_level := 0 # In current level

# Lost pumpkins count.
var pumpkin_lost_total := 0 # Total
var pumpkin_lost_level := 0 # In current level
var pumpkin_score := 0      # Calculated on level end: +1 for each saved pumpkin.

var level_score := 0
var total_score := 0


func update_totals() -> void:
	devils_total += devils_level
	pumpkin_lost_total += pumpkin_lost_level
	pumpkin_score = Game.level_pumpkins - pumpkin_lost_level
	level_score = devils_level + pumpkin_score
	total_score += level_score


func clear_level_totals() -> void:
	devils_level = 0
	pumpkin_lost_level = 0
	pumpkin_score = 0
	level_score = 0
