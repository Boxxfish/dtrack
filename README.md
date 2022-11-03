# DTrack
DTrack (short for Dependency Tracker) is a module for Godot that lets you create reactive UI components declaratively. It's based on [Vue.js](https://vuejs.org/), so if you've used it before, you should feel right at home!

The philosophy of this library is to augment Godot's UI capabilities, not replace it. Thanks to the engine's hierarchical node system, signals, and `$nodepath` syntax, all the pieces are already there. The only pain point is managing internal component state, which is where this comes in. If you haven't used a modern frontend library and are wondering how it's done these days, read [this](https://vuejs.org/guide/extras/reactivity-in-depth.html).

## Installation
All you need to do to use this library is either clone or download this repo, then copy `DTrack.gd` into your project. Doesn't matter which folder you put it in, it'll still work. Optionally, you can copy `ui.gd` into your project's [script_templates](https://docs.godotengine.org/en/stable/tutorials/scripting/creating_script_templates.html) folder to cut down on boilerplate.

## Tutorial
At its core, DTrack is just a reactive state manager. You declare some data, bind it to node properties, and those properties will update automatically whenever the data changes. Create a Button node, and add a new script to it, using the default Godot template. Add this boilerplate at the top of the script:

```GDScript
var dt := DTrack.new(self)
func _set(property, value):
    dt.set(property, value)
func _get(property):
    return dt.get(property)
```
On the first line, we create a new DTrack instance and pass the node we're on to it. This lets it call methods in this script. We also bind it to the node's getters and setters, which makes for better ergonomics and allows the node to expose state externally.

Next, let's enter the `_ready()` method. Set it up like this:

```GDScript
func label():
    return "Pressed " + str(get("number")) + " times"

func _ready():
    dt.begin()

    dt.data({
        "number": 0,
    })
    dt.computed("label")
    dt.bind(self, "text", "label")

    dt.end()
```

We can see a couple things happening here. We've used `data()` to declare some internal state: a variable called `number` with the value 0. `computed()` declares `label()`, which we provide outside the function, as a computed property, which means it's a property that should be modified whenever its reactive dependencies change. As seen in the definition, it returns a string that formats `number`. Finally, `bind()` binds the computed value `label` to the button's text field. If you run the scene now, the button should now display "Pressed 0 times".

Why are we putting our code between `dt.begin()` and `dt.end()`? Any calls to DTrack made between these two calls will invoke its reactivity recording system. Without them, DTrack wouldn't be able to see that `number` is a dependency of `label`, and that `label` should be updated whenever `number` changes.

Let's add some interactivity now. Add this to your script:

```GDScript
func handle_button_pressed():
    set("number", get("number") + 1)

func _ready():
    dt.begin()

    # Code from before omitted
    self.connect("pressed", self, "handle_button_pressed")

    dt.end()
```

If you've been using GDScript for a while, there should be no surprise here. All we're doing is connecting the button's `pressed` signal and incrementing the `number` value whenever it's emitted. What might surprise you, though, is when you run this scene now and click the button, the label automatically updates itself, even though we didn't explicity tell `label` to recalculate itself or the `text` property to update! That's the power of reactivity, and it can greatly simplify state management in more complex components.

Just to close things off, we'll use the final major tool DTrack gives us.

```GDScript
func print_msg():
    print("The number has been updated!")

func _ready():
    dt.begin()

    # Code from before omitted
    dt.watch(["number"], "print_msg")

    dt.end()
```

When we tell DTrack to watch a set of values, it'll call the provided function whenever those values update. This is useful for stuff like animation, since we want the node to do something whenever some piece of state changes. For example, you can use [Anima](https://anima.ceceppa.me/) to play a transition whenever you change a value.

## Other Stuff
### Two way binding
Sometimes, you want to both bind a value in DTrack to a node's property, but also have the value update whenever the property updates. For example, if you bind a value called `my_text` to a LineEdit's `text` property, updating `my_text` should change the content of the textbox, but editing the text in-game should also change `my_text`. For situations like this, DTrack supports two way binding. Most nodes will emit a signal when input properties are changed. If you add the name of this signal to the end of the `bind()` call, the value will now update whenever the signal is emitted. So, `dt.bind($LineEdit, "text", "my_text")` will perform one way binding, while `dt.bind($LineEdit, "text", "my_text", "text_changed")` will perform two way binding.

### Props
The problem with using `data()` in the `_ready()` function is, if you instance a reactive component and try to do `set("reactive_property", value)` on it, it'll give you an error since the property wasn't declared yet. For public facing properties, write the following:

```GDScript
func props():
    return {
        "reactive_property": value,
    }
```

When initializing DTrack, it'll call this function and register those properties automatically, so even external code can update them.