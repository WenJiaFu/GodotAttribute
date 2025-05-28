extends Node2D

@export var characters: Array[PlayerCharacter] = []

var windows_flag = ImGui.WindowFlags_Modal

enum OperateType {
	Add,
	Sub,
	Mult,
	Div,
	Set,
}

class CharacterImguiData:
	## 属性数据
	var attribute_combo_items: Array[String] = []
	var attribute_combo_index: Array[int] = [0]
	var attribute_input_value: Array[float] = [0.0]
	## Buff数据
	var buff_name: Array[String] = [""]
	var buff_input_value: Array[float] = [0.0]
	var buff_duration_value: Array[float] = [0.0]
	var buff_operate_radio_names: Array[String] = ["+ ", "- ", "* ", "/ ", "= "]
	var buff_operate_radio_actives: Array[bool] = [true, false, false, false, false]
	var buff_policy_radio_names: Array[String] = ["持久的 ", "有时效 "]
	var buff_policy_radio_actives: Array[bool] = [true, false]

	func get_select_attribute_name() -> String:
		var index = attribute_combo_index[0]
		return attribute_combo_items[index]

	func get_operate_type() -> AttributeModifier.OperationType:
		var operate_type := AttributeModifier.OperationType.ADD
		for i in buff_operate_radio_actives.size():
			if buff_operate_radio_actives[i]:
				operate_type = i as AttributeModifier.OperationType
				break
		return operate_type

	func get_policy_type() -> AttributeBuff.DurationPolicy:
		return AttributeBuff.DurationPolicy.Infinite if buff_policy_radio_actives[0] else AttributeBuff.DurationPolicy.HasDuration


	func active_operate_radio(index: int):
		for i in buff_operate_radio_actives.size():
			buff_operate_radio_actives[i] = index == i

	func active_policy_radio(index: int):
		for i in buff_policy_radio_actives.size():
			buff_policy_radio_actives[i] = index == i

	func is_actived_operate_radio(index: int) -> bool:
		return buff_operate_radio_actives[index]

	func is_actived_policy_radio(index: int) -> bool:
		return buff_policy_radio_actives[index]


var character_imgui_data_dict: Dictionary[PlayerCharacter, CharacterImguiData] = {}

class AttributesValue:
	var value_dict: Dictionary[String, float] = {}

## 缓存角色属性数值的最终显示结果
## 当角色属性有变化时，才更新属性值缓存作为imgui的显示数值，主要原因在于：
## 1.imgui是由_process驱动，如果在_process中频繁调用Attribute::get_value()，效率不高
## 2.Attribute的实际应用场景应该也不会在_process一直刷新数值，这样更有利于测试属性的信号通知，发现BUG
var character_attribute_value: Dictionary[PlayerCharacter, AttributesValue] = {}


func _ready() -> void:
	_init_character_attribute_cached(characters)
	_init_character_imgui_data(characters)

	var io = ImGui.GetIO()
	io.ConfigFlags |= ImGui.ConfigFlags_ViewportsEnable | ImGui.ConfigFlags_DockingEnable


func _process(_delta: float) -> void:
	_run_imgui_process()


func _run_imgui_process():
	## ImGui示例
	##ImGui.ShowDemoWindow()

	## 创建角色属性窗口
	for pawn in characters:
		ImGui.SetNextWindowSize(Vector2(1280, 720))
		ImGui.Begin("%s属性" % pawn.character_name, [], windows_flag)
		imgui_attribute_list(pawn)
		imgui_attribute_modifier(pawn)
		ImGui.End()


func imgui_attribute_list(pawn: PlayerCharacter):
	ImGui.Text("属性列表")
	## 属性表头
	ImGui.BeginTable("attribute_table", 4, ImGui.TableFlags_Borders | ImGui.TableFlags_RowBg | ImGui.TableFlags_Sortable)
	#ImGui.TableColumnFlags_PreferSortAscending
	ImGui.TableSetupColumn("attribute", ImGui.TableColumnFlags_WidthFixed)
	ImGui.TableSetupColumn("get_value()", ImGui.TableColumnFlags_WidthFixed)
	ImGui.TableSetupColumn("compute_value", ImGui.TableColumnFlags_WidthFixed)
	ImGui.TableSetupColumn("buffs", ImGui.TableColumnFlags_WidthFixed)
	ImGui.TableHeadersRow()

	### 根据属性集展示所有内容
	var attribute_set = pawn.get_attribute_set()
	if not is_instance_valid(attribute_set):
		ImGui.EndTable()
		return

	for _name in attribute_set.attributes_runtime_dict:
		var runtime_attribute = attribute_set.attributes_runtime_dict[_name] as Attribute
		## attribute
		ImGui.TableNextRow()
		ImGui.TableNextColumn()
		ImGui.Text("%s" % runtime_attribute.attribute_name)
		## get_value()
		ImGui.TableNextColumn()
		ImGui.Text("%.02f" % get_character_attribute_value(pawn, runtime_attribute.attribute_name))
		## compute_value
		ImGui.TableNextColumn()
		ImGui.Text("%.02f" % runtime_attribute.computed_value)
		## buffs
		ImGui.TableNextColumn()
		var buff_size = runtime_attribute.get_buff_size()
		if ImGui.CollapsingHeader("数量 %d##%s" % [buff_size, _name], ImGui.TreeNodeFlags_DefaultOpen):
			for _buff in runtime_attribute.buffs:
				## remove button
				if ImGui.Button("移除##%d" % _buff.get_instance_id()):
					runtime_attribute.call_deferred("remove_buff", _buff)
				ImGui.SameLine()
				## 状态描述
				var operate_name = AttributeModifier.OperationType.keys()[_buff.operation]
				var policy_name = AttributeBuff.DurationPolicy.keys()[_buff.policy]
				var show_buff_name = "unknow" if _buff.buff_name.is_empty() else _buff.buff_name
				var buff_stat = "name[%s] operate[%s] value[%.02f] policy[%s]" % \
					[show_buff_name, operate_name, _buff.value, policy_name]
				if _buff.has_duration():
					var remaining_stat = " %.02f" % _buff.remaining_time
					buff_stat = buff_stat + remaining_stat
				ImGui.Text(buff_stat)

	ImGui.EndTable()


func imgui_attribute_modifier(pawn: PlayerCharacter):
	if not ImGui.TreeNodeEx("属性修改##%d" % pawn.get_instance_id(), ImGui.TreeNodeFlags_DefaultOpen):
		return

	## 属性选择
	ImGui.PushItemWidth(160)
	var combo_items = character_imgui_data_dict[pawn].attribute_combo_items
	var combo_index = character_imgui_data_dict[pawn].attribute_combo_index
	ImGui.Combo("##Attribute", combo_index, combo_items)
	ImGui.PopItemWidth()

	## 属性操作
	ImGui.BeginTabBar("tab menu")
	if ImGui.BeginTabItem("数值运算"):
		imgui_attribute_operate(pawn)
		ImGui.EndTabItem()
	if ImGui.BeginTabItem("BUFF"):
		imgui_attribute_buff(pawn)
		ImGui.EndTabItem()
	ImGui.EndTabBar()

	ImGui.TreePop()


func imgui_attribute_operate(pawn: PlayerCharacter):
	## Button +
	ImGui.PushItemWidth(80)
	if ImGui.Button("+"):
		operate_attribute_value(OperateType.Add, pawn)
	ImGui.PopItemWidth()

	## Button -
	ImGui.SameLine()
	if ImGui.Button("-"):
		operate_attribute_value(OperateType.Sub, pawn)

	## Button *
	ImGui.SameLine()
	if ImGui.Button("*"):
		operate_attribute_value(OperateType.Mult, pawn)

	## Button /
	ImGui.SameLine()
	if ImGui.Button("/"):
		operate_attribute_value(OperateType.Div, pawn)

	## Button =
	ImGui.SameLine()
	if ImGui.Button("="):
		operate_attribute_value(OperateType.Set, pawn)

	## Value
	ImGui.SameLine()
	ImGui.PushItemWidth(160.0)
	ImGui.InputFloat("##值", character_imgui_data_dict[pawn].attribute_input_value)
	ImGui.PopItemWidth()


func imgui_attribute_buff(_pawn: PlayerCharacter):
	## operate radio button
	var imgui_data = character_imgui_data_dict[_pawn]
	for i in imgui_data.buff_operate_radio_names.size():
		var _name = imgui_data.buff_operate_radio_names[i]
		var _active = imgui_data.is_actived_operate_radio(i)
		if ImGui.RadioButton("%s##operate" % _name, _active):
			imgui_data.active_operate_radio(i)
		ImGui.SameLine()

	## buff value
	var buff_input_value = character_imgui_data_dict[_pawn].buff_input_value
	ImGui.PushItemWidth(80.0)
	ImGui.InputFloat("数值##buff_value %d" % _pawn.get_instance_id(), buff_input_value)
	ImGui.PopItemWidth()

	## policy radio button
	for i in imgui_data.buff_policy_radio_names.size():
		var _name = imgui_data.buff_policy_radio_names[i]
		var _active = imgui_data.is_actived_policy_radio(i)
		if ImGui.RadioButton("%s##policy" % _name, _active):
			imgui_data.active_policy_radio(i)
		ImGui.SameLine()

	## duration
	ImGui.PushItemWidth(80.0)
	ImGui.DragFloat("秒##duration", character_imgui_data_dict[_pawn].buff_duration_value)
	ImGui.PopItemWidth()

	## add buff button
	ImGui.PushStyleColor(ImGui.Col_Button, Color.DARK_SLATE_GRAY)
	if ImGui.ButtonEx("增加Buff", Vector2(100, 0.0)):
		handle_buff_addtion(_pawn)
	ImGui.PopStyleColor()

	## buff name
	ImGui.SameLine()
	ImGui.PushItemWidth(160)
	ImGui.InputText("名称", character_imgui_data_dict[_pawn].buff_name, 512)
	ImGui.PopItemWidth()


func _init_character_attribute_cached(_characters: Array[PlayerCharacter]):
	character_attribute_value.clear()
	for _pawn in _characters:
		if not character_attribute_value.has(_pawn):
			character_attribute_value[_pawn] = AttributesValue.new()
		var attribute_set = _pawn.get_attribute_set() as AttributeSet
		var attributes_value = character_attribute_value[_pawn]
		for _name in attribute_set.attributes_runtime_dict:
			var attribute = attribute_set.attributes_runtime_dict[_name] as Attribute
			attributes_value.value_dict[_name] = attribute.get_value()
			attribute.attribute_changed.connect(_on_attribute_changed.bind(_pawn))


func _init_character_imgui_data(_characters: Array[PlayerCharacter]):
	character_imgui_data_dict.clear()
	for pawn in _characters:
		## attribute value input
		var imgui_data = CharacterImguiData.new()
		## attribute name for combo
		var attribute_set = pawn.get_attribute_set() as AttributeSet
		for _name in attribute_set.attributes_runtime_dict:
			imgui_data.attribute_combo_items.append(_name)
		## add to character data
		character_imgui_data_dict[pawn] = imgui_data


func get_character_attribute_value(_character: PlayerCharacter, _attribute_name: String) -> float:
	if not character_attribute_value.has(_character):
		return 0.0
	var attributes_value = character_attribute_value[_character]
	if not attributes_value.value_dict.has(_attribute_name):
		return 0.0
	return attributes_value.value_dict[_attribute_name]


## 属性数值直接操作
func operate_attribute_value(type: OperateType, _pawn: PlayerCharacter):
	var combo_index = character_imgui_data_dict[_pawn].attribute_combo_index[0]
	var current_attribute_name = character_imgui_data_dict[_pawn].attribute_combo_items[combo_index]
	var attribute = _pawn.get_attribute(current_attribute_name) as Attribute
	var input_value = character_imgui_data_dict[_pawn].attribute_input_value[0]

	match type:
		OperateType.Add: attribute.add(input_value)
		OperateType.Sub: attribute.sub(input_value)
		OperateType.Mult: attribute.mult(input_value)
		OperateType.Div: attribute.div(input_value)
		OperateType.Set: attribute.set_value(input_value)


func handle_buff_addtion(_pawn: PlayerCharacter):
	var imgui_data = character_imgui_data_dict[_pawn]
	var attribute_name = imgui_data.get_select_attribute_name()
	var attribute = _pawn.get_attribute(attribute_name)

	## 获取Buff数值
	var buff_name = imgui_data.buff_name[0]
	var buff_value = imgui_data.buff_input_value[0]
	var buff_duration = imgui_data.buff_duration_value[0]
	var buff_operate = imgui_data.get_operate_type()
	var buff_policy = imgui_data.get_policy_type()
	var butt_instance = AttributeBuff.new(buff_operate, buff_value, buff_name)
	if buff_policy == AttributeBuff.DurationPolicy.HasDuration:
		butt_instance.set_duration(buff_duration)
	## 增加Buff（_process内，延迟调用）
	attribute.call_deferred("add_buff", butt_instance)


func _on_attribute_changed(_attribute: Attribute, _pawn: PlayerCharacter):
	if not character_attribute_value.has(_pawn):
		return

	var pawn_attribute_value = character_attribute_value[_pawn]
	if not pawn_attribute_value.value_dict.has(_attribute.attribute_name):
		return

	## 刷新属性值
	pawn_attribute_value.value_dict[_attribute.attribute_name] = _attribute.get_value()
	#print("attribute value %.02f" % _attribute.get_value())
