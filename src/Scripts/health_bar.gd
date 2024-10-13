extends ProgressBar

var parent
var max_health_amount
var min_health_amount

func _ready():
	parent = get_parent()
	max_health_amount = parent.max_health
	min_health_amount = parent.min_health
	
func _process(delta):
	self.value = parent.health
	if parent.health != max_health_amount:
		self.visible = true
		if parent.health == min_health_amount:
			self.visible = false
	else:
		self.visible = true
