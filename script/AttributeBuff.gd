class_name AttributeBuff extends Resource

@export var buff_name: String
@export var operation := AttributeModifier.OperationType.ADD
@export var value := 0.0
@export var policy := DurationPolicy.Infinite

## duration_policy == HasDuration生效
## 单位：秒
@export var duration: float = 0.0
@export var merging := DurationMerging.Restart

enum DurationPolicy {
	Infinite,		## 持久地
	HasDuration,	## 有时效性地
}

enum DurationMerging {
	Restart,	## 重新开始计算时长
	Addtion,	## 新的时长叠加到现有时效上
	NoEffect,	## 对现有时效无任何影响
}

var attribute_modifier: AttributeModifier
var remaining_time: float

func _init(_operation := AttributeModifier.OperationType.ADD, _value: float = 0.0, _name := ""):
	attribute_modifier = AttributeModifier.new(_operation, _value)
	operation = _operation
	value = _value
	buff_name = _name


func duplicate_buff() -> AttributeBuff:
	if is_instance_valid(attribute_modifier):
		var duplicated_buff = duplicate(true)
		duplicated_buff.attribute_modifier = attribute_modifier.duplicate(true)
		duplicated_buff.attribute_modifier.type = attribute_modifier.type
		duplicated_buff.attribute_modifier.value = attribute_modifier.value
		duplicated_buff.set_duration(duration)
		return duplicated_buff
	return null


static func add(_value: float = 0.0, _name := "") -> AttributeBuff:
	return AttributeBuff.new(AttributeModifier.OperationType.ADD, _value, _name)


static func sub(_value: float = 0.0, _name := "") -> AttributeBuff:
	return AttributeBuff.new(AttributeModifier.OperationType.SUB, _value, _name)


static func mult(_value: float = 0.0, _name := "") -> AttributeBuff:
	return AttributeBuff.new(AttributeModifier.OperationType.MULT, _value, _name)


static func div(_value: float = 0.0, _name := "") -> AttributeBuff:
	return AttributeBuff.new(AttributeModifier.OperationType.DIVIDE, _value, _name)


func operate(base_value: float) -> float:
	return attribute_modifier.operate(base_value)


func has_duration() -> bool:
	return policy == DurationPolicy.HasDuration


func set_duration(_time: float) -> AttributeBuff:
	duration = _time
	remaining_time = duration
	policy = DurationPolicy.HasDuration if duration > 0.0 else DurationPolicy.Infinite
	return self


func restart_duration():
	remaining_time = duration


func extend_duration(_time: float):
	remaining_time += _time
