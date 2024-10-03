active = false
paused = false

center_screen = Vector2(Render.Width / 2, Render.Height / 2) - Vector2(4, 4)

pong_table_width = 600
pong_table_height = 300
pong_table_top_offset = 50
pong_table_vector = Vector2(pong_table_width, pong_table_height)
pong_table_center = Vector2((pong_table_width / 2), (pong_table_height / 2))
pong_draw_start = Vector2((Render.Width / 2) - (pong_table_width / 2), pong_table_top_offset)

ping_width = pong_table_width / 40
ping_height = pong_table_height / 5
ping_pos = (pong_table_height / 2) - (ping_height / 2)
ping_pos_opp = (pong_table_height / 2) - (ping_height / 2)
ping_increment = 3

ball_width = pong_table_width / 60
ball_height = pong_table_height / 30
ball_pos = Vector2(pong_table_center.x - (ball_width / 2), pong_table_center.y - (ball_height / 2))
ball_speed = Vector2(2, 2)
ball_speed_limit = {}
ball_speed_limit.upper = 6
ball_speed_limit.lower = -ball_speed_limit.upper

angle_modifier = 2.5

scores = {0, 0}
score_limit = 5

cpu_difficulty = 1.5

status_text = ""
status_colour = Color(0, 0, 0)

mouse_last = Vector2.Zero

difficulty_level = {
	["noob"] = {1, 4, 2.5},
	["easy"] = {1.3, 5.5, 2.5},
	["medium"] = {1.6, 7.6, 3},
	["hard"] = {1.9, 9, 3.3},
	["extreme"] = {2.3, 11, 4.6},
	["hell"] = {4, 16, 5.5}
}