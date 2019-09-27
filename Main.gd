extends Control

var hz = 120
var host = '192.168.1.103'
var port = 14854
var sock = PacketPeerUDP.new()

export(DynamicFont) var font

onready var screen = get_viewport().get_visible_rect().size

var knobs = []
var radius
var margin = 90

func add_knob(x, color):
	knobs.append({
		'value': 0,
		'position': Vector2(x, screen.y / 2),
		'color': color,
		'press_angle': 0,
		'last_value': 0
	})

# Holds index of knobs pressed
var pressed_knob = {}

func get_knob(pos):
	for knob in knobs:
		if pos.x > (knob.position.x - radius) and pos.x < (knob.position.x + radius) and pos.y > (knob.position.y - radius) and pos.y < (knob.position.y + radius):
			return knob

func _ready():
	radius = (screen.y - margin * 2) / 2
	
	add_knob(margin + radius, Color('#3f63ae'))
	add_knob(screen.x - margin - radius, Color('#a12a76'))
	
	$AxisTimer.wait_time = 1.0 / hz
	$AxisTimer.start()
	
	sock.set_dest_address(host, port)

func send_axis():
	var json = '[' + str(knobs[0].value) + ', ' + str(knobs[1].value) + ']'
	sock.put_packet(json.to_ascii())
	
func get_angle(knob, pos):
	return atan2(pos.y - knob.position.y, pos.x - knob.position.x)
	
func to_value(rad):
	return int((rad + PI) * 0x8000 / (2 * PI)) % 0x8000

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			var knob = get_knob(event.position)
			knob.press_angle = get_angle(knob, event.position)
			pressed_knob[event.index] = knob
		else:
			pressed_knob[event.index].last_value = pressed_knob[event.index].value
			pressed_knob.erase(event.index)
	
	elif event is InputEventScreenDrag:
		var knob = pressed_knob[event.index]
		var angle = get_angle(knob, event.position)
		knob.value = fposmod(knob.last_value + to_value(angle - knob.press_angle - PI), 0x8000)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	
func _draw():
	for knob in knobs:
		draw_circle(knob.position, radius, knob.color)
		draw_string(font, knob.position, str(knob.value))








