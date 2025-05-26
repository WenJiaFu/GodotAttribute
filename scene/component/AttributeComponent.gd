class_name AttributeComponent extends Node

@export var attribute_set: AttributeSet

func _physics_process(delta: float) -> void:
	if is_instance_valid(attribute_set):
		attribute_set.run_process(delta)


#region 外部函数
func get_attribute_value(attribute_name: String) -> float:
	if not is_instance_valid(attribute_set):
		return 0.0
	var attribute = attribute_set.find_attribute(attribute_name)
	return attribute.get_value()


func find_attribute(attribute_name: String) -> Attribute:
	return attribute_set.find_attribute(attribute_name) if is_instance_valid(attribute_set) else null
#endregion
