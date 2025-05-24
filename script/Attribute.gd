class_name Attribute extends Resource

signal attribute_changed(attribute: Attribute)

@export var attribute_name: String

## 属性的原始数值（保持不变）
@export var base_value := 0.0: set = setter_base_value

## 执行计算公式后的数值
var current_value := 0.0: set = setter_current_value

## 储存运算操作对象数组（AttributeModifier）
var modifiers: Array[AttributeModifier] = []

var attribute_set: AttributeSet

#region setter
func setter_base_value(v):
	base_value = v
	current_value = v


func setter_current_value(v):
	current_value = v
	attribute_changed.emit(self)
#endregion

## 由外部驱动（AttributeSet）
func run_process(delta: float):
	for mod in modifiers:
		if mod.has_duration:
			mod.remaining_time = max(mod.remaining_time - delta, 0.0)
			if is_zero_approx(mod.remaining_time):
				remove_modifier(mod)


func get_base_value() -> float:
	return base_value


func get_value() -> float:
	return current_value


func recompute_attribute():
	current_value = _compute_value()


func apply_modifier(mod: AttributeModifier):
	modifiers.append(mod)
	current_value = _compute_value()


func remove_modifier(mod: AttributeModifier):
	modifiers.erase(mod)
	current_value = _compute_value()


## 数值计算
func _compute_value() -> float:
	## 计算公式运算结果
	var dervied_attribute: Array[Attribute] = []
	var dervied_attribute_names = derived_from()
	for _name in dervied_attribute_names:
		var _attribute = attribute_set.find_attribute(_name)
		dervied_attribute.append(_attribute)
	var compute_result = custom_compute(dervied_attribute)
	## 修改器运算结果
	for mod in modifiers:
		compute_result = mod.operate(compute_result)
	return compute_result


## 自定义计算公式
func custom_compute(_compute_params: Array[Attribute]) -> float:
	return base_value


## 属性依赖列表
func derived_from() -> Array[String]:
	return []
