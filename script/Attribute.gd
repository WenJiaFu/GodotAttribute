class_name Attribute extends Resource

signal attribute_changed(attribute: Attribute)
signal buff_added(attribute: Attribute, buff: AttributeBuff)
signal buff_removed(attribute: Attribute, buff: AttributeBuff)

## 属性名称
@export var attribute_name: String

## 属性的原始数值（保持不变）
@export var base_value := 0.0: set = setter_base_value

## 仅执行计算公式后的数值
var computed_value := 0.0: set = setter_computed_value

## 防止base_value可写
var is_initialized_base_value = false

## 储存对属性值产生影响Buff的缓存
var buffs: Array[AttributeBuff] = []

## 该属性位于的属性集
var attribute_set: AttributeSet


#region setter
func setter_base_value(v):
	## 在export设置完成一次后，不再可写
	if not is_initialized_base_value:
		is_initialized_base_value = true
		base_value = v
		computed_value = v


func setter_computed_value(v):
	computed_value = v
	attribute_changed.emit(self)
#endregion


#region 外部函数
## 由外部驱动（AttributeSet）
func run_process(delta: float):
	var pending_remove_buffs: Array[AttributeBuff] = []
	## 准备删除
	for _buff in buffs:
		if _buff.has_duration():
			_buff.remaining_time = max(_buff.remaining_time - delta, 0.0)
			if is_zero_approx(_buff.remaining_time):
				pending_remove_buffs.append(_buff)
	## 确认删除
	for _buff in pending_remove_buffs:
		remove_buff(_buff)


func get_base_value() -> float:
	return computed_value


func get_value() -> float:
	var attribute_value = computed_value
	for _buff in buffs:
		attribute_value = _buff.operate(attribute_value)
	return attribute_value


func set_value(_value: float):
	var operated_value = AttributeModifier.forcefully_set_value(_value).operate(computed_value)
	computed_value = _compute_value(operated_value)


func add(_value: float):
	var operated_value = AttributeModifier.add(_value).operate(computed_value)
	computed_value = _compute_value(operated_value)


func sub(_value: float):
	var operated_value = AttributeModifier.subtract(_value).operate(computed_value)
	computed_value = _compute_value(operated_value)


func mult(_value: float):
	var operated_value = AttributeModifier.multiply(_value).operate(computed_value)
	computed_value = _compute_value(operated_value)


func div(_value: float):
	var operated_value = AttributeModifier.divide(_value).operate(computed_value)
	computed_value = _compute_value(operated_value)


func add_buff(_buff: AttributeBuff):
	## 是否需要duplicate一个新的buff再增加？
	buffs.append(_buff)
	buff_added.emit(self, _buff)


func remove_buff(_buff: AttributeBuff):
	buffs.erase(_buff)
	buff_removed.emit(self, _buff)
#endregion

#region 子类继承实现
## 自定义计算公式
## @ operated_value: 已经被修改过后的值
## @ _compute_params: 参数列表中的属性顺序和_derived_from返回的一致
func custom_compute(operated_value: float, _compute_params: Array[Attribute]) -> float:
	return operated_value


## 属性依赖列表
## @ return: 返回依赖属性的名称数组
func derived_from() -> Array[String]:
	return []
#endregion

#region 内部函数
## 重新计算computed_value（由计算公式返回的值）
func _compute_value(_operated_value: float) -> float:
	var derived_attributs: Array[Attribute] = []
	var derived_attribute_names = derived_from()
	for _name in derived_attribute_names:
		var attribute = attribute_set.find_attribute(_name)
		derived_attributs.append(attribute)
	computed_value = custom_compute(_operated_value, derived_attributs)
	return computed_value
#endregion
