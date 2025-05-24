class_name AttributeComponent extends Node

@export var attribute_set: AttributeSet

func _physics_process(delta: float) -> void:
	attribute_set.run_process(delta)

#region 外部函数
func get_attribute_value(attribute_name: String) -> float:
	var attribute = attribute_set.find_attribute(attribute_name)
	return attribute.get_value()


func find_attribute(attribute_name: String) -> Attribute:
	return attribute_set.find_attribute(attribute_name)
#endregion
