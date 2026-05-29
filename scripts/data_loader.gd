class_name DataLoader
extends Node

static func load_json(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("DataLoader: 无法打开文件 " + path)
		return null
	var text = file.get_as_text()
	var result = JSON.parse_string(text)
	if result == null:
		push_error("DataLoader: JSON 解析失败 " + path)
		return null
	return result
