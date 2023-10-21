class_name SimpleJSON
extends RefCounted


static func save_to_string(obj) -> String:
	var dict = add_fields_to_dict(obj)
	#var json = JSON.new().stringify(dict)
	var json = JSON.stringify(dict, "\t")
	return json

static func save_to_file(obj, file_name:String):
	string_to_file(save_to_string(obj), file_name)



static func load_from_string(obj, json:String):
	var test_json_conv = JSON.new()
	var error = test_json_conv.parse(json)
	if error:
		printerr("Invalid JSON format: ", error)
		return
	var dict = test_json_conv.get_data()
	if not dict is Dictionary:
		printerr("Invalid JSON format: dictionary expected")
		return
	apply_fields_from_dict(dict, obj)

static func load_from_file(obj, file_name:String):
	var file_str = string_from_file(file_name)
	if file_str != null:
		load_from_string(obj, file_str)



static func string_to_file(text:String, file_name:String):
	print("Saving file: " + file_name)
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	if not file:
		printerr("Could not create file:", file_name, "->", FileAccess.get_open_error())
		return
	file.store_string(text)
	file.close()

static func string_from_file(file_name:String):
	print("Loading file: " + file_name)
	if not FileAccess.file_exists(file_name):
		return null
	var file = FileAccess.open(file_name, FileAccess.READ)
	if not file:
		printerr("Could not open settings file:", file_name, "->", FileAccess.get_open_error())
		return null
	var text = file.get_as_text()
	file.close()
	return text



static func add_fields_to_dict(obj):
	var dict = Dictionary()
	var props = obj.get_property_list()
	for p in props:
		if (p.has('usage') and (p.usage == PROPERTY_USAGE_SCRIPT_VARIABLE)):
			var value = obj.get(p.name)
			#print(p.name + ", type: " + str(p.type) + ", value: " + str(value))
			if (p.type == TYPE_OBJECT):
				value = add_fields_to_dict(value)
			dict[p.name] = value
	return dict


static func apply_fields_from_dict(dict:Dictionary, obj):
	var props = obj.get_property_list()
	for p in props:
		if (p.has('usage') and (p.usage == PROPERTY_USAGE_SCRIPT_VARIABLE) and dict.has(p.name)):
			var value = dict[p.name]
			if (p.type == TYPE_OBJECT):
				#Inner class - recursively set from dictionary.
				if (value is Dictionary):
					print("Setting sub-dict %s..." % p.name)
					apply_fields_from_dict(value, obj.get(p.name))
				else:
					printerr("Not a dictionary %s to set object!" % p.name)
			else:
				#Normal object - set directly.
				print("Setting value %s = %s" % [p.name, value])
				obj.set(p.name, value)
