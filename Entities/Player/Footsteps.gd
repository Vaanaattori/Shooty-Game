extends Node
var audiolibrary = []
var rng = RandomNumberGenerator.new()
var playedIndices = []

func _ready():
	for audioplayer in get_children():
		audiolibrary.append(audioplayer)
	rng.randomize()  # Seed the random number generator

func Footstep():
	if playedIndices.size() == audiolibrary.size():
		playedIndices.clear()  # Reset if all players have been played
	var nextIndex = getValidRandomIndex()
	if nextIndex != -1:
		playedIndices.append(nextIndex)
		audiolibrary[nextIndex].play()
		print(audiolibrary[nextIndex])

func getValidRandomIndex():
	var remainingIndices = []
	for i in range(audiolibrary.size()):
		if !playedIndices.has(i):
			remainingIndices.append(i)
	if remainingIndices.size() == 0:
		return -1  # All audio players have been played
	return remainingIndices[rng.randi_range(0, remainingIndices.size() - 1)]
