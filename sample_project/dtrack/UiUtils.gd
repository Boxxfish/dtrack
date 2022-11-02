class_name UiUtils

# Helper function for clearing children.
static func clear_children(component: Node):
    for child in component.get_children():
        child.queue_free()
        component.remove_child(child)
