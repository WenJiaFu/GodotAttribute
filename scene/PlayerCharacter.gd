extends CharacterBody2D

@onready var attribute_component: AttributeComponent = %AttributeComponent

const max_health_attribute_name = "max_health"
const health_attribute_name = "health"
const attack_attribute_name = "attack"
const strength_attribute_name = "strength"

var max_health_attribute: Attribute
var health_attribute: Attribute
var attack_attribute: Attribute
var strength_attribute: Attribute

func _ready() -> void:
	max_health_attribute = attribute_component.find_attribute(max_health_attribute_name)
	health_attribute = attribute_component.find_attribute(health_attribute_name)
	attack_attribute = attribute_component.find_attribute(attack_attribute_name)
	strength_attribute = attribute_component.find_attribute(strength_attribute_name)

#region 生命值测试
	print_health_stat()

	health_attribute.apply_modifier(AttributeModifier.add(20.0))
	print_health_stat()

	health_attribute.apply_modifier(AttributeModifier.subtract(60.0))
	print_health_stat()
#endregion

#region 攻击力测试
	print_attack_stat()

	## 增加1点力量值
	strength_attribute.apply_modifier(AttributeModifier.add(1))
	print_attack_stat()

	## 攻击力翻倍（1秒Buff）
	attack_attribute.apply_modifier(AttributeModifier.multiply(2).set_duration(1.0))
	print_attack_stat()
	await get_tree().create_timer(2.0).timeout
	print_attack_stat()
#endregion


func print_health_stat():
	print("health stat: %.01f/%.01f" % [health_attribute.get_value(), max_health_attribute.get_value()])


func print_attack_stat():
	print("attack : %.01f | strength : %.01f" % [attack_attribute.get_value(), strength_attribute.get_value()])
