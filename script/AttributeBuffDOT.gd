extends AttributeBuff
class_name AttributeBuffDOT

## DOT间隔
@export var dot_interval: float = 1.0
## DOT数值
@export var dot_value: float = 0.0
## DOT操作符
@export var dot_operation: AttributeModifier.OperationType = AttributeModifier.OperationType.SUB
## DOT总次数 0为无限次
@export var total_dot_count: int = 0

var dot_timer: float = 0.0
var dot_count: int = 0

signal dot_triggered(buff: AttributeBuffDOT, dot_value: float)

static func create_dot(
	dot_value: float, 
	dot_interval: float = 1.0, 
	total_dot_count: int = 0,
	dot_operation: AttributeModifier.OperationType = AttributeModifier.OperationType.SUB,
	buff_name: String = ""
) -> AttributeBuffDOT:
	var dot_buff = AttributeBuffDOT.new()
	dot_buff.dot_value = dot_value
	dot_buff.dot_interval = dot_interval
	dot_buff.total_dot_count = total_dot_count
	dot_buff.dot_operation = dot_operation
	dot_buff.buff_name = buff_name
	## 这里一定要是0，我不希望DOT Buff临时修改数值
	dot_buff.value = 0
	return dot_buff

func run_process(delta: float):
	if total_dot_count > 0 and dot_count >= total_dot_count:
		return
	dot_timer += delta
	
	if dot_timer >= dot_interval:
		dot_timer = fmod(dot_timer, dot_interval)
		_trigger_dot()

func _trigger_dot():
	dot_triggered.emit(self, dot_value)
	dot_count += 1
	if total_dot_count > 0 and dot_count >= total_dot_count:
		remaining_time = 0.0

func duplicate_buff() -> AttributeBuff:
	var duplicated = super.duplicate_buff() as AttributeBuffDOT
	duplicated.dot_interval = dot_interval
	duplicated.dot_value = dot_value
	duplicated.dot_operation = dot_operation
	duplicated.total_dot_count = total_dot_count
	duplicated.dot_timer = 0.0
	duplicated.dot_count = 0
	return duplicated


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