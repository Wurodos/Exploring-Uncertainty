extends Enemy

func _init() -> void:
	super._init()

# attacks randomly

func decide_intention() -> void:
	super.decide_intention()
	intention = Intention.new(Intention.Type.DamageSingular, randi_range(2, 5))
	
	var r = randi_range(0, Battle.instance.good_team.boys.size() - 1)
	intention.target = r
