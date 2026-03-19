extends Item

@export var harm: int = 7
@export var scrap_received: int = 0

func localize():
	super.localize()
	desc = desc.format([harm, scrap_received], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	var was_alive = victim.held.is_alive
	Action.deal_damage(sender, victim, harm)
	
	if not CurrentRun.is_in_purged and not sender.team.is_evil and not victim.held.is_alive and was_alive:
		var current = Item.Scrap.Flesh
		for scrap: Item.Scrap in CurrentRun.scraps.keys():
			if CurrentRun.scraps[scrap] < CurrentRun.scraps[current]:
				current = scrap
		
		CurrentRun.scraps[current] += scrap_received
	
func on_level_up():
	super.on_level_up()
	if level == 3 or level == 5: scrap_received += 1
	else: harm += 2

func get_priority(_sender: SlaveNode, _victim: SlaveNode) -> int:
	return 0

func get_harm() -> int:
	return harm

func get_displayed_harm(sender: SlaveNode, victim: SlaveNode) -> int:
	return Action.calculate_damage(sender, victim, harm)

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.DamageSingular)
	intention.effect = func(v):
		use_item(sender, v)
	return intention
