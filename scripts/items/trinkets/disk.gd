extends Item

var sender: SlaveNode = null

var saved_power: int = 0
var saved_luck: int = 0
var saved_speed: int = 0
var saved_static: int = 0
var saved_buffs: Dictionary[String, int] = {}
var is_loaded: bool = false

func localize():
	super.localize()
	if is_loaded:
		texture = Gallery.img_loaded_disk
		name = tr("disk_loaded_name")
		desc = tr("disk_loaded_desc").format([saved_power, saved_speed, saved_luck, saved_static], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	sender = owner
	if is_loaded:
		sender.set_power(+saved_power)
		sender.set_luck(+saved_luck)
		sender.set_speed(+saved_speed)
		sender.set_static(+saved_static)
		for buff in saved_buffs.keys():
			sender.add_buff(buff, saved_buffs[buff])
		consume(owner)

func on_equip_battle(owner: SlaveNode):
	sender = owner

func on_end_battle(owner: Slave):
	super.on_end_battle(owner)
	if not is_loaded:
		saved_power = sender.power
		saved_luck = sender.luck
		saved_speed = sender.held.speed
		saved_static = sender.static_stat
		saved_buffs = sender.buffs.duplicate()
		is_loaded = true
		localize()
