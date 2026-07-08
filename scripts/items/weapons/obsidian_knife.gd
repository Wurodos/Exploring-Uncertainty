extends Item

@export var harm: int = 7

func localize():
	super.localize()
	desc = desc.format([harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, harm)

func on_end_battle(_owner: Slave):
	var obsidian: Item = ItemPool.fetch("obsidian")
	for i in range(level-1):
		obsidian.level_up()
	CurrentRun.put_item_in_inventory(obsidian)

func on_level_up():
	super.on_level_up()
	extra_hp += 1
	extra_speed += 1
	harm += 4
