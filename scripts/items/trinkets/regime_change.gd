extends Item

static var used := false

func localize():
	super.localize()

func on_start_battle(_owner: SlaveNode):
	used = false

func on_end_battle(_owner: Slave):
	if not used and Battle.instance.wave_count > 1:
		SignalBus.regime_change.emit()
		used = true

func on_level_up():
	super.on_level_up()
	extra_speed -= 2
