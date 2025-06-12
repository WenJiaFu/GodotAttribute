class_name AttributeBuffDOT extends AttributeBuff

'''
示例
func poison_buff() -> AttributeBuffDOT:
	return AttributeBuffDOT.create_dot(
		1.0,
		0.5,
		0,
		AttributeModifier.OperationType.SUB,
		"Poison"
	).set_duration(5.0)

创建一个中毒buff持续5秒，每0.5秒造成1点伤害，执行无数次直到buff结束
'''

signal dot_triggered(buff: AttributeBuffDOT)

## DOT周期
@export var period: float = 1.0
## DOT总次数 0为无限次
@export var max_charges: int = 0

var cycle_time: float = 0.0
var charges: int = 0

func _init(_operation := AttributeModifier.OperationType.ADD, _value: float = 0.0, _period: float = 1.0, _max_charges: int = 0, _name := ""):
	attribute_modifier = AttributeModifier.new(_operation, _value)
	operation = _operation
	value = _value
	buff_name = _name
	policy = DurationPolicy.Period
	period = _period
	max_charges = _max_charges


func duplicate_buff() -> AttributeBuff:
	var duplicated = super.duplicate_buff() as AttributeBuffDOT
	duplicated.period = period
	duplicated.cycle_time = cycle_time
	duplicated.charges = charges
	return duplicated


func run_process(delta: float):
	if is_pending_remove:
		return

	if max_charges > 0 and charges >= max_charges:
		is_pending_remove = true
		return

	_try_to_trigger_dot(delta)


func _try_to_trigger_dot(delta: float):
	cycle_time += delta
	if cycle_time >= period:
		cycle_time = fmod(cycle_time, period)
		charges += 1
		apply_to_attribute()


func apply_to_attribute():
	if is_instance_valid(applied_attribute):
		applied_attribute.apply_buff_operation(self)
		dot_triggered.emit(self)
