class_name AttributeModifier extends Resource

enum OperationType {
	ADD,
	SUB,
	MULT,
	DIVIDE,
	PERCENTAGE,
	SET,
}

var type: OperationType
var value: float
var remaining_time: float
var has_duration := false

func _init(_type: OperationType = OperationType.ADD, _value: float = 0.0) -> void:
	type = _type
	value = _value


static func create(_type: OperationType, _base_value: float) -> AttributeModifier:
	return AttributeModifier.new(_type, _base_value)


static func add(_base_value: float) -> AttributeModifier:
	return create(OperationType.ADD, _base_value)


static func subtract(_base_value: float) -> AttributeModifier:
	return create(OperationType.SUB, _base_value)


static func multiply(_base_value: float) -> AttributeModifier:
	return create(OperationType.MULT, _base_value)


static func divide(_base_value: float) -> AttributeModifier:
	return create(OperationType.DIVIDE, _base_value)


static func percentage(_base_value: float) -> AttributeModifier:
	return create(OperationType.PERCENTAGE, _base_value)


static func forcefully_set_value(_base_value: float) -> AttributeModifier:
	return create(OperationType.SET, _base_value)


func set_duration(_time: float) -> AttributeModifier:
	if _time > 0.0:
		remaining_time = _time
		has_duration = true
	return self


func operate(_base_value: float) -> float:
	match type:
		OperationType.ADD: return _base_value + value
		OperationType.SUB: return _base_value - value
		OperationType.MULT: return _base_value * value
		OperationType.DIVIDE: return 0.0 if is_zero_approx(value) else _base_value / value
		OperationType.SET: return value
	return value
