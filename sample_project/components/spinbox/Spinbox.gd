extends MarginContainer

var dt := DTrack.new(self)
func _set(property, value):
    dt.set(property, value)
func _get(property):
    return dt.get(property)

# Signals
signal number_changed

# Data classes

# Components

# Props
func props() -> Dictionary:
    return {
        "number": 0,
        "min": null,
        "max": null,
    }

# Computed
func number_str():
    return str(get("number"))

func minus_disabled():
    return get("number") == get("min")

func plus_disabled():
    return get("number") == get("max")

# Watchers
func emit_number_changed():
    self.emit_signal("number_changed")

func animate_number():
    var anima := Anima.begin(self)
    anima.then({
        node = self,
        easing = Anima.EASING.EASE_OUT_BOUNCE,
        property = "scale:y",
        duration = 0.4,
        from = 1.2,
        to = 1,
    })
    anima.play()

# Handlers
func handle_minus_pressed():
    set("number", get("number") - 1)
    
func handle_plus_pressed():
    set("number", get("number") + 1)

func _ready():
    dt.begin()
    
    dt.computed("number_str")
    dt.computed("minus_disabled")
    dt.computed("plus_disabled")
    dt.watch(["number"], "emit_number_changed")
    dt.watch(["number"], "animate_number")
    dt.bind($HBoxContainer/Number, "text", "number_str")
    dt.bind($HBoxContainer/Minus, "disabled", "minus_disabled")
    dt.bind($HBoxContainer/Plus, "disabled", "plus_disabled")
    $HBoxContainer/Minus.connect("pressed", self, "handle_minus_pressed")
    $HBoxContainer/Plus.connect("pressed", self, "handle_plus_pressed")
    
    dt.end()
