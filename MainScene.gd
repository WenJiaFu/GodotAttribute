extends Node2D

@onready var warrior_character: PlayerCharacter = %WarriorCharacter
@onready var mage_character: PlayerCharacter = %MageCharacter

var windows_flag = ImGui.WindowFlags_Modal

func _ready() -> void:
	var io = ImGui.GetIO()
	io.ConfigFlags |= ImGui.ConfigFlags_ViewportsEnable | ImGui.ConfigFlags_DockingEnable


func _process(_delta: float) -> void:
	_run_imgui_process()


func _run_imgui_process():
	## ImGui示例
	#ImGui.ShowDemoWindow()

	ImGui.SetNextWindowSize(Vector2(640, 720))
	ImGui.Begin("%s属性状态" % warrior_character.character_name, [], windows_flag)
	imgui_process_attribute(warrior_character)
	ImGui.End()

	ImGui.SetNextWindowSize(Vector2(680, 720))
	ImGui.Begin("%s属性状态" % mage_character.character_name, [], windows_flag)
	imgui_process_attribute(mage_character)
	ImGui.End()


func imgui_process_attribute(character: PlayerCharacter):
	## 属性表头
	ImGui.BeginTable("attribute_table", 4, ImGui.TableFlags_Borders | ImGui.TableFlags_RowBg | ImGui.TableFlags_Sortable)
	#ImGui.TableColumnFlags_PreferSortAscending
	ImGui.TableSetupColumn("attribute", ImGui.TableColumnFlags_WidthFixed)
	ImGui.TableSetupColumn("get_value()", ImGui.TableColumnFlags_WidthFixed)
	ImGui.TableSetupColumn("compute_value", ImGui.TableColumnFlags_WidthFixed)
	ImGui.TableSetupColumn("buffs", ImGui.TableColumnFlags_WidthFixed)
	ImGui.TableHeadersRow()

	### 根据属性集展示所有内容
	var attribute_set = character.get_attribute_set()
	if not is_instance_valid(attribute_set):
		ImGui.EndTable()
		return

	for _name in attribute_set.attributes_runtime_dict:
		var runtime_attribute = attribute_set.attributes_runtime_dict[_name]
		## attribute
		ImGui.TableNextRow()
		ImGui.TableNextColumn()
		ImGui.Text("%s" % runtime_attribute.attribute_name)
		## 名称
		ImGui.TableNextColumn()
		ImGui.Text("最大生命值")
		## compute_value
		ImGui.TableNextColumn()
		ImGui.Text("%.02f" % runtime_attribute.computed_value)
		## buffs
		ImGui.TableNextColumn()
		if ImGui.CollapsingHeader("数量 0", ImGui.TreeNodeFlags_DefaultOpen):
			pass

	#ImGui.Text("%.02f" % max_health_attribute.computed_value)
	#var max_health_value_input = [max_health_value]
	#ImGui.SameLine()
	#ImGui.PushItemWidth(160.0)
	#ImGui.InputInt("最大生命值", max_health_value_input)
	#ImGui.PopItemWidth()

	ImGui.EndTable()
