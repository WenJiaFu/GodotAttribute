class_name PlayerCharacter extends CharacterBody2D

@export var character_name: String

@onready var attribute_component: AttributeComponent = %AttributeComponent

const MAX_HEALTH_ATTRIBUTE_NAME = "max_health"
const HEALTH_ATTRIBUTE_NAME = "health"
const ATTACK_ATTRIBUTE_NAME = "attack"
const STRENGTH_ATTRIBUTE_NAME = "strength"
const INTELL_ATTRIBUTE_NAME = "intell"


func _ready() -> void:
	pass


func get_attribute_set() -> AttributeSet:
	return attribute_component.attribute_set
