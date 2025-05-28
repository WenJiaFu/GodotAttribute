class_name AttackAttribute extends Attribute

const attack_attribute_name = "attack"
const strength_attribute_name = "strength"

@export var attack_point_per_strength = 3.0

## 自定义计算公式
func custom_compute(_operated_value: float, _compute_params: Array[Attribute]) -> float:
	var strength_attribute = _compute_params[0]
	return base_value + strength_attribute.get_value() * attack_point_per_strength


## 属性依赖列表
func derived_from() -> Array[String]:
	return [
		strength_attribute_name,
	]
