extends Control

var dt := DTrack.new(self)
func _set(property, value):
    dt.set(property, value)
func _get(property):
    return dt.get(property)

# Signals

# Data classes
class Review:
    var title: String
    var content: String
    var rating: int
    
    func _init(title: String, content: String, rating: int):
        self.title = title
        self.content = content
        self.rating = rating

# Components
const Card := preload("res://components/card/Card.tscn")

# Props

# Computed

# Watchers
func update_reviews():
    # Remove old reviews
    var review_container = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/VBoxContainer2/Reviews
    for child in review_container.get_children():
        review_container.remove_child(child)
        
    # Add new ones
    for review in get("reviews"):
        var card := Card.instance()
        card.set("title", review.title)
        card.set("content", review.content)
        card.set("rating", review.rating)
        review_container.add_child(card)

# Handlers
func handle_submit():
    var reviews = get("reviews")
    reviews.append(Review.new(get("title"), get("content"), get("rating")))
    set("reviews", reviews)
    
    set("title", "")
    set("content", "")
    set("rating", 3)
    
func handle_clear():
    set("reviews", [])

func _ready():
    dt.begin()
    
    dt.data({
        "reviews": [
            Review.new("The Godfather", "whatever. Overrated as hell", 1),
            Review.new("Pixels", "HOOOLY SHIT", 5),
        ],
        "title": "",
        "content": "",
        "rating": 3,
    })
    dt.watch(["reviews"], "update_reviews")
    
    dt.bind($MarginContainer/HBoxContainer/VBoxContainer/MovieTitleTextbox, "text", "title", "text_changed")
    dt.bind($MarginContainer/HBoxContainer/VBoxContainer/ReviewTextbox, "text", "content", "text_changed")
    dt.bind($MarginContainer/HBoxContainer/VBoxContainer/Rating, "number", "rating", "number_changed")
    
    $MarginContainer/HBoxContainer/VBoxContainer/Rating.set("min", 0)
    $MarginContainer/HBoxContainer/VBoxContainer/Rating.set("max", 5)
    $MarginContainer/HBoxContainer/VBoxContainer/Submit.set("text", "Submit")
    
    $MarginContainer/HBoxContainer/VBoxContainer/Submit.connect("pressed", self, "handle_submit")
    $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/VBoxContainer2/Clear.connect("pressed", self, "handle_clear")
    
    dt.end()
