extends MarginContainer

var dt := DTrack.new(self)
func _set(property, value):
    dt.set(property, value)
func _get(property):
    return dt.get(property)

# Signals

# Data classes

# Components
const RatingBubble := preload("res://components/card/RatingBubble.tscn")

# Props
func props() -> Dictionary:
    return {
        "title": "",
        "content": "",
        "rating": 0,
    }

# Computed

# Watchers
func update_rating():
    # Clear existing stars
    var rating_container := $MarginContainer/VBoxContainer/Rating
    for child in rating_container.get_children():
        rating_container.remove_child(child)
        
    # Add a bubble for each star given
    for i in range(get("rating")):
        var bubble := RatingBubble.instance() as TextureRect
        bubble.modulate = Color.black
        rating_container.add_child(bubble)
        
    # Add the rest of the rating bubbles
    for i in range(5 - get("rating")):
        var bubble := RatingBubble.instance() as TextureRect
        bubble.modulate = Color.gray
        rating_container.add_child(bubble)

# Handlers

func _ready():
    dt.begin()
    
    dt.watch(["rating"], "update_rating")
    dt.bind($MarginContainer/VBoxContainer/Title, "text", "title")
    dt.bind($MarginContainer/VBoxContainer/Content, "text", "content")
    
    dt.end()
