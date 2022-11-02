extends MarginContainer

var dt := DTrack.new(self)
func _set(property, value):
    dt.set(property, value)
func _get(property):
    return dt.get(property)

# Signals
signal pressed

# Data classes

# Components

# Props
func props() -> Dictionary:
    return {
        "text": "",
    }

# Computed

# Watchers

# Handlers
func handle_pressed():
    self.emit_signal("pressed")

func _ready():
    dt.begin()

    dt.bind($MarginContainer/ButtonText, "text", "text")
    $Button.connect("pressed", self, "handle_pressed")
    
    dt.end()
