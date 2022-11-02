class_name DTrack

# A tracked reference's dependency.
class Dep:
    var component: Node
    var property: String
    var is_computed := false
    
    func _init(c: Node, p: String):
        self.component = c
        self.property = p

# A value that is being tracked.
class TrackedRef:
    var deps := []
    var value
    var hit: bool
    var is_computed = false

# Where all reference date is stored.
var refs := {}
# Whether we're tracking depdencies.
var tracking := true
# Component to bind to.
var component: Node

# Registers a series of values onto this component.
func data(val_dict: Dictionary):
    for key in val_dict:
        var val = val_dict[key]
        self.refs[key] = TrackedRef.new()
        self.refs[key].value = val

# Updates dependencies.
# Any dependencies in the ignore list will not be updated.
func _update_deps(property: String, value, ignore: Array = []):
    if not self.tracking:
        if property in self.refs:
            self.refs[property].value = value
            for dep in self.refs[property].deps:
                if dep in ignore:
                    continue
                if dep.is_computed:
                    var result = self.component.call(dep.property)
                    self._update_deps(dep.property, result)
                else:
                    dep.component.set(dep.property, value)
            
# Sets a stored value.
func set(property: String, value):
    if property in self.refs:
        assert(not self.refs[property].is_computed, "Computed properties cannot be directly assigned values.")
        self._update_deps(property, value)
       
# Returns a stored value. 
func get(property: String):
    if property in self.refs:
        if self.tracking:
            self.refs[property].hit = true
        return self.refs[property].value

# Binds a child component's property to a tracked ref.
# If an update signal is passed, this becomes a two way binding. The tracked ref can be modified
# by both DTrack and the component, updating whenever the signal fires.
func bind(component: Node, property_name: String, value_name: String, update_signal: String = ""):
    var dep := Dep.new(component, property_name)
    self.refs[value_name].deps.append(dep)
    component.set(property_name, self.refs[value_name].value)
    
    if update_signal != "":
        component.connect(update_signal, self, "handle_component_property_updated", [component, property_name, value_name, dep])

# Handles component properties being updated via two way binding.
func handle_component_property_updated(component: Node, property_name: String, value_name: String, dep: Dep):
    _update_deps(value_name, component.get(property_name), [dep])

# Runs a function when the values given change.
func watch(value_names: Array, func_name: String):
    var dep = Dep.new(self.component, func_name)
    dep.is_computed = true
    for value_name in value_names:
        self.refs[value_name].deps.append(dep)
    component.call(func_name)
    
# Runs a function when any tracked dependencies change.
func computed(func_name: String):
    self.refs[func_name] = TrackedRef.new()
    self.refs[func_name].is_computed = true
    
    # Reset all hit refs
    for ref_name in self.refs:
        self.refs[ref_name].hit = false
    
    # Cache current value
    self.refs[func_name].value = self.component.call(func_name)
    
    # Add to all hit refs as dependency
    self.refs[func_name].hit = false
    var dep = Dep.new(self.component, func_name)
    dep.is_computed = true
    for ref_name in self.refs:
        var ref = self.refs[ref_name]
        if ref.hit and not dep in ref.deps:
            self.refs[ref_name].deps.append(dep)
    
# Begins tracking dependencies.
func begin():
    self.tracking = true
    
# Ends tracking dependencies.
func end():
    self.tracking = false

func _init(component: Node):
    self.component = component
    
    # Attach props if defined
    if self.component.has_method("props"):
        self.begin()
        self.data(self.component.props())
        self.end()
