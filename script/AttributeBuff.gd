class_name AttributeBuff extends Resource

@export var buff_name: String
@export var operation := AttributeModifier.OperationType.ADD
@export var value := 0.0
@export var policy := DurationPolicy.Infinite
@export var duration: float = 0.0 ## duration_policy == HasDuration生效

enum DurationPolicy {
	Infinite,
	HasDuration,
}

var attribute_modifier: AttributeModifier
var remaining_time: float


func _init(_operation := AttributeModifier.OperationType.ADD, _value: float = 0.0, _policy := DurationPolicy.Infinite, _duration := 0.0):
	attribute_modifier = AttributeModifier.new(_operation, _value)
	operation = _operation
	value = _value
	policy = _policy
	duration = _duration


static func add(_value: float = 0.0, _policy := DurationPolicy.Infinite, _duration := 0.0) -> AttributeBuff:
	return AttributeBuff.new(AttributeModifier.OperationType.ADD, _value, _policy, _duration)


static func sub(_value: float = 0.0, _policy := DurationPolicy.Infinite, _duration := 0.0) -> AttributeBuff:
	return AttributeBuff.new(AttributeModifier.OperationType.SUB, _value, _policy, _duration)


static func mult(_value: float = 0.0, _policy := DurationPolicy.Infinite, _duration := 0.0) -> AttributeBuff:
	return AttributeBuff.new(AttributeModifier.OperationType.MULT, _value, _policy, _duration)


static func div(_value: float = 0.0, _policy := DurationPolicy.Infinite, _duration := 0.0) -> AttributeBuff:
	return AttributeBuff.new(AttributeModifier.OperationType.DIVIDE, _value, _policy, _duration)


func operate(base_value: float) -> float:
	return attribute_modifier.operate(base_value)


func has_duration() -> bool:
	return policy == DurationPolicy.HasDuration


func set_duration(_time: float):
	duration = _time
	remaining_time = duration
