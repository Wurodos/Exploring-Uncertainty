extends ColorRect

class_name ItemEntry

@onready var item_name : Label = $Name
@onready var item_desc : Label = $Desc

@onready var single_target: Control = $Single
@onready var all_targets: Control = $All
@onready var self_target: Control = $Self
