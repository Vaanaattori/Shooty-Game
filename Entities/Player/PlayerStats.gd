extends Node

@export_group("Stats")
@export var HPMax:int = 100
@onready var HP:int = HPMax
@export var MaxStamina:float = 100
@onready var stamina:float = MaxStamina
@export var StaminaRecovery:float
@export var StaminaRecoveryCooldown:float
@export var BaseSpeed:float = 4
@export var SprintMultiplier:float = 2
@export var StartingMoney:float = 150
var money: float = StartingMoney
@export_group("Weapon Stats")
@export var SlideLength:float = 1.25

@export_group("Settings")
@export_range(5,20) var sensitivity:float = 10

