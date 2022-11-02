extends %BASE%

var dt := DTrack.new(self)
func _set(property, value):
    dt.set(property, value)
func _get(property):
    return dt.get(property)

# Signals

# Data classes

# Components

# Props
func props() -> Dictionary:
    return {
        
    }

# Computed

# Watchers

# Handlers

func _ready():
    dt.begin()
    dt.end()
