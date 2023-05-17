extends Node

signal export_image_pressed(path)
signal show_file_dialog
signal save_project_pressed

signal zoom_in_pressed
signal zoom_out_pressed

signal rebuild_pattern_pressed
signal show_navpatches_pressed
signal remove_navpatches_pressed
signal goto_pattern_pressed

signal show_notification(notification_text, duration)

signal scroll_to_index(index, marker)
signal add_marker(position, type)

signal show_path_to_convert_gds_dialog(path)
