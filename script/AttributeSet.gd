class_name AttributeSet extends Resource

@export var attributes: Array[Attribute]: set = setter_attributes

## 运行时数据
var attributes_runtime_dict: Dictionary[String, Attribute] = {}

## 记录依赖属性关联下的其它属性
## 当该依赖属性发生变化时，通知关联属性更新数值
## Key: String 依赖属性名
## Value: Array[Attribute] 关联属性
var derived_attributes_dict = {}

func setter_attributes(v):
	attributes = v

	_create_runtime_attributes()
	_create_derived_attributes()
	_init_attributes()


## 由外部驱动（AttributeComponent）
func run_process(delta: float):
	for _name in attributes_runtime_dict:
		var runtime_attribute = attributes_runtime_dict[_name]
		runtime_attribute.run_process(delta)


func find_attribute(attribute_name: String) -> Attribute:
	if attributes_runtime_dict.has(attribute_name):
		return attributes_runtime_dict[attribute_name]
	push_error("AttributeSet 未能找到指定的属性对象 %s" % attribute_name)
	return null


#region 内部函数
func _create_runtime_attributes():
	attributes_runtime_dict.clear()
	for attr in attributes:
		if attributes_runtime_dict.has(attr.attribute_name):
			push_warning("AttributeSet 有重复的属性名称 %s" % attr.attribute_name)
			continue

		var duplicated_attribute = attr.duplicate(true) as Attribute
		duplicated_attribute.attribute_set = self
		attributes_runtime_dict[attr.attribute_name] = duplicated_attribute
		duplicated_attribute.attribute_changed.connect(_on_attribute_changed)


func _create_derived_attributes():
	derived_attributes_dict.clear()
	for _name in attributes_runtime_dict:
		var runtime_attribute = attributes_runtime_dict[_name]
		var derived_attribute_names = runtime_attribute.derived_from()

		for derived_name in derived_attribute_names:
			var derived_attribute = find_attribute(derived_name)
			if not is_instance_valid(derived_attribute):
				push_warning("_create_derived_attributes failed | 未找到该名称的依赖属性 %s" % derived_name)
				continue

			if not derived_attributes_dict.has(derived_attribute.attribute_name):
				derived_attributes_dict[derived_attribute.attribute_name] = []
			var relative_attributes = derived_attributes_dict[derived_attribute.attribute_name]
			relative_attributes.append(runtime_attribute)


func _init_attributes():
	for _name in attributes_runtime_dict:
		var runtime_attribute = attributes_runtime_dict[_name]
		runtime_attribute.recompute_attribute()
#endregion

#region 信号通知
func _on_attribute_changed(attribute: Attribute):
	_update_derived_attributes(attribute)


func _update_derived_attributes(derived_attribute: Attribute):
	if derived_attributes_dict.has(derived_attribute.attribute_name):
		var relative_attributes = derived_attributes_dict[derived_attribute.attribute_name]
		for attribute in relative_attributes:
			attribute.recompute_attribute()
#endregion
