pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

Lyear, Lmonth, Lmonday = 2020, 7, 20
year, month, day = stat(90), stat(91), stat(92)
ymd = tostr(year).."-"..tostr(month).."-"..tostr(day)
gmode = 0
won = 0
bdow = 1 << (day - Lmonday)

objs = {}

function addobj(_x, _y, _sprite, _flags)
	add(objs, {
		x=_x,y=_y,sprite=_sprite,
		fx=_x,fy=_y,
		moving=false,
		flags=(_flags or 0)
	})
end

-- directions: 0: up , 1: right, 2: down, 3: left
hero = {
	x = 16, y = 16, -- VISIBLE x/y
	sprite = 55,
	moving = false, -- can be nil or {x,y} e.g. {1,-1}
	last_dir = {1,1},
	flags = 0,
}

function load_map()
	for x = 0,32 do
		for y = 0,32 do
			q = mget(x,y)
			if q > 15 and q < 48 then
				mset(x, y, 0)
				addobj(x*8, y*8, q, fget(q))
			end
		end
	end
end


function draw_block()
	cls()
	-- zablokowane
	if won == 1 then
		print("wygrana!")
	elseif lf == day then
		print("dzisiaj juz grales!")
	else
		print("po czasie!")
	end
end

function draw_start()
	cls()
	print("dzisiaj jest: " .. ymd, 8, 8)
	for i = 0,6 do
		h = progress >> i & 1
		srand(i+t()/(3+sin(i*4)*4)/1000000)
		dx = rnd(2) -1
		dy = rnd(2) -1
		spr(20 + h, 24+i*10+dx, 24+dy)
	end
	day = 25
	spr(22, 13 + (day-Lmonday+1)*10, 36+sin(t()/4)*3)
end

function sprobj(obj)
	spr(obj.sprite, obj.x, obj.y)
end

function draw_game()
	cls()
	map(0,0,0,0, 16, 16)

	hero_sprite_vert = (hero.last_dir[2] != 1)
	hero_sprite_horz = (hero.last_dir[1] != 1) ~= hero_sprite_vert
	spr(hero.sprite + (hero_sprite_vert and 1 or 0), hero.x, hero.y, 1, 1, hero_sprite_horz)
	foreach(objs, sprobj)
end

function next(obj, dir)
	return {x = obj.x + dir[1]*8, y = obj.y + dir[2]*8}
end

function eq_xy(a,b)
	return a.x == b.x and a.y == b.y
end

function dbgtab(t, name)
	if name then printh("> "..name) end
	for k, v in pairs(t) do
		printh(tostr(k).. ' '.. tostr(v))
	end
end

function will_collide(a, b, a_dir)
	a_next = next(a, a_dir)
	dbgtab(a_next)
	if eq_xy(a_next, b) then
		return true
	end
end

function forany(arr, func)
	for a in all(arr) do
		if func(a) then
			return true
		end
	end
	return false
end

function can_move(obj, dir)
	-- assuming standing still! (obj.moving == false)
	if dir == false then
		return false
	end
	
	dx = obj.x/8 + dir[1]
	dy = obj.y/8 + dir[2]
	
	if fget(mget(dx,dy), 0) then -- wall_hit?
		return false
	end

	-- obj hit?
	return not forany(objs, function(obj2) 
		return will_collide(obj, obj2, dir)
	end)
end

function move_hero()
	if hero.moving != false then
		hero.x += hero.moving[1]
		hero.y += hero.moving[2]
		if hero.x == fx and hero.y == fy then
			hero.moving = false
		end
	end

	if hero.moving == false then
		dir = false
		if btn(0) then
			dir = {-1, 0}
		elseif btn(1) then
			dir = {1, 0}
		elseif btn(2) then
			dir = {0, -1}
		elseif btn(3) then
			dir = {0, 1}
		elseif btn(4) then
			finish_today(1)
		end

		if can_move(hero, dir) then
			hero.moving = dir
			fx = hero.x + hero.moving[1] * 8
			fy = hero.y + hero.moving[2] * 8
			for i = 1,2 do
				if hero.moving[i] != 0 then
					hero.last_dir[i] = hero.moving[i]
				end
			end
		end
	end
end

function nop() end

function update_start()
	if btn(5) then
	gmode(2)
	end
end

function update_game()
	move_hero()
end


function gmode(n)
	cls()
	if n == 0 then
		_draw, _update60 = draw_block, nop
	elseif n == 1 then
		_draw, _update60 = draw_start, update_start
	elseif n == 2 then
		_draw, _update60 = draw_game, update_game
	end
end	

function _init()
	cartdata("ixff_t1")
	gmode(0)
	load_map()
	dset(1, 10)
	progress = dget(0)
	lf = dget(1)

	if lf == day then
		gmode(0)
	elseif Lyear == year and Lmonth == month
		and Lmonday <= day and day < Lmonday + 7 then
		gmode(1)
	end
end

function finish_today(win)
	if win == 1 then
		won = 1
		progress = progress | bdow
	end
	dset(1, day)
	dset(0, progress)
	gmode(0)
end


__gfx__
00000000555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555555555555510000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555055555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005555555500011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005555555511100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555505555555555500000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000110000009900000077000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000500000000000000011110000a7a90000777700000bb0000000000000000000000000000000000000000000000000000000000000000000
00000000000000000050000000000500011111100977aa9007777770000bb0000111111021111110011111100111111000000000000000000000000000000000
0088880000000000005000000000500001111110097aaa9077777777000dd00078888880288888807bbbbbb07bbbbbb000000000000000000000000000000000
008888000000000000500000000500000111111009aaaa90000770000011110078888880288888807bbbbbb07bbbbbb000000000000000000000000000000000
0088880000bbbb000050080000500b000111111009aaaa9000077000001111000111111021111110011111100111111000000000000000000000000000000000
0222222002222220011111100111111000111100009aa9000007700000111100088888800bbbbbb0088888800bbbbbb000000000000000000000000000000000
00000000000000000111111001111110000110000009900000077000001111000111111001111110011111100111111000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000011111111111111110000000000000000000000000000000000000000
000000000000000004444000000744000000000000000000000000000000000000000000144444411cccccc10000000000000000000000000000000000000000
000000000044400000744000000a4400000044400000000000000000000000000000000011111111111111110000000000000000000000000000000000000000
0044400004444400000a44000000440000004440000000000000000000000000000000001144441111cccc110000000000000000000000000000000000000000
04444500007a450000000500000005000000444000000000000000000000000000000000141441411c1cc1c10000000000000000000000000000000000000000
017a11100100111001001110010011100000444000000000000000000000000000000000144114411cc11cc10000000000000000000000000000000000000000
04aa455004aa455004aa455004aa4550000000000000000000000000000000000cccccc0141441411c1cc1c10000000000000000000000000000000000000000
0444455004444550044445500444455000000000000000000000000000000000111111111144441111cccc110000000000000000000000000000000000000000
00000000000000000003300000033000111111111111111111111111008888000088880011111111000000000054545000000040000000000000000000000000
011011000880880000033000003333001c111c11111881111b1111b1008888800888880011111111000000000454545400000054000000000000000000000000
111111108888878000033000033003301cc1cc11118888111b1111b100f7f70000ffff0011111111000000000454545400000054000000000000000000000000
1111111088888880000330000000033011ccc11d1181181d1bb11bbd00f5550000ffff00111111110000000004545454000000a4000000000000000000000000
0111110008888800000330000003330011ccc11d1881188d11b11b1d08c88c8008c88c8011111111000000000aa4545400000aa4000000000000000000000000
001110000088800000033000000330001cc1cc111811118111bbbb1170cccc0770cccc0711111111000000000a54545400000054000000000000000000000000
000100000008000000000000000000001c111c1118111181111bb11100cccc0000cccc0011111111000000000454545400000054000000000000000000000000
00000000000000000003300000033000111111111111111111111111005005000050050011111111000000000454545400000054000000000000000000000000
00000000000770000000000000077000000000000007700000000000000770000000000000077000000000000007700000000000000770000000000000077000
00000000000770000000000000077000000000000007700000000000000770000000000000077000000000000007700000000000000770000000000000077000
00000000000770000000000000077000000000000007700000000000000770000000000000077000000000000007700000000000000770000000000000077000
00077000000770000007777700077777000770000007700000077777000777777777700077777000777777777777777777777000777770007777777777777777
00077000000770000007777700077777000770000007700000077777000777777777700077777000777777777777777777777000777770007777777777777777
00000000000000000000000000000000000770000007700000077000000770000000000000000000000000000000000000077000000770000007700000077000
00000000000000000000000000000000000770000007700000077000000770000000000000000000000000000000000000077000000770000007700000077000
00000000000000000000000000000000000770000007700000077000000770000000000000000000000000000000000000077000000770000007700000077000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000007777770077000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000007777770087788770077000000077770000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000007700770087708770077000000977907700000000000000000000000
00000000000000000000000000000000000000000000000000000000000000077000770087788770087777800a77000000977a97700000000000000000000000
00000000000000000000000000000000000000000000000000000000000000077000770087708770087789770a77000000977b97700000000000000000000000
00000000000000000000000000000000000000000000000000000000000000077070770087798770a877a8770a7777770c977097700000000000000000000000
0000000000000088c088c00000000000000000000000000000000000000000077777770087777770a88998800a8888880c977777700000000000000000000000
0000000000000077ce77ce0000000000000000000000000000000000000000977787770088aa8800a99ba990ca9999990c999999000000000000000000000000
0000000000000077ce77ceaaaaaae000000000000000007777770000000000977888770088888800a99ab990caaaaaa00caaaaaa000000000000000000000000
00000000000000778877ce7777770077000000770000007700770000000000988808880b99bb9900aaccaa00cbb00000ecbbbbbb000000000000000000000000
00000000000000777777ce77e0000077000000770000007788770000000000988999880b99999900aabbaa00cbbbbbb0ecccccc0000000000000000000000000
0000000000000077ce77ce77aae00077000000770000007799770000000000999099900baa0baa0dbbddbb00cc000000edd0edd0000000000000000000000000
0000000000000077ee77ee77770000770000007700000077aa77000000000b990ab9900baaaaaa0dbbccbb00cccccc00edddddd0000000000000000000000000
000000000000000000000077aaaae07700000077000000777777000000000baaaaaaa00bb00bb00dcc0dcc00dd000000ee00ee00000000000000000000000000
000000000000000000000077777700777777007777770088cc88000000000baaa0aaa0dbbbbbb00dccdecc00dddddd00eeeeee00000000000000000000000000
0000000000000000000000000000008888880088888800888888000000000baabbbaa0dcc0dcc00dd00dd000ee00000000000000000000000000000000000000
0000000000000000000000000000009999990099999900999999000000000bbbcbbb00dccedcc00dd00dd000eeeeee0000000000000000000000000000000000
00000000000000000000000000000000000000aaaaaa00aaaaaa000000000bbcccbb00dcccccc00eeee000000000000000000000000000000000000000000000
00000000000000000000000000000000000000bbbbbb00bbbbbb000000000cccdccc00dd00dd000ee00ee0000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000cccccc000000000ccdedcc00dddddd000ee00ee0000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000dddddd000000000dde0edd00ee00ee0000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000ee000ee00eeeeee0000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000eee0e0e0eee00ee00000eee00ee00000eee0eee00ee00ee00000eee000000000000000000000000000000000000
00000000000000000000000000000000000000e00e0e00e00e00000000e00e0000000e0e00e00e000e0e00000e0e000000000000000000000000000000000000
00000000000000000000000000000000000000e00eee00e00eee000000e00eee00000eee00e00e000e0e0eee0eee000000000000000000000000000000000000
00000000000000000000000000000000000000e00e0e00e0000e000000e0000e00000e0000e00e000e0e00000e0e000000000000000000000000000000000000
00000000000000000000000000000000000000e00e0e0eee0ee000000eee0ee000000e000eee00ee0ee000000eee000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000cc00ccc00cc0ccc00000ccc00cc00000ccc0ccc0ccc0ccc00000c0c00cc0c0c0000000000000000000000000000000
0000000000000000000000000000000000c0c00c00c000c00000000c00c0c00000ccc0c000c0000c000000c0c0c0c0c0c0000000000000000000000000000000
0000000000000000000000000000000000c0c00c00c000cc0000000c00c0c00000c0c0cc00cc000c000000ccc0c0c0c0c0000000000000000000000000000000
0000000000000000000000000000000000c0c00c00c000c00000000c00c0c00000c0c0c000c0000c00000000c0c0c0c0c0000000000000000000000000000000
0000000000000000000000000000000000c0c0ccc00cc0ccc000000c00cc000000c0c0ccc0ccc00c000000ccc0cc000cc0000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000008808800000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000088888780000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000088888880000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000008888800000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000888000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0001010001010000000000000000000000000000000000000000000000000000000000000000000004030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0201010102010101010101010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000002000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000001000000000000030000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000030300000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0229010101000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0229020000030300000000030000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0228020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000300030300000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000003030300000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200030300000000000303030000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000600000000000000200004000180000c000100000c0001a0000c000110000c0001c0000c000100000c000190000c000100000c0001b0000c0001a0000c00019000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00444248
00 40444148
00 40414344
00 40414344
01 40414243
00 40414243
00 40414345
00 40414346
00 40414345
00 40414340
00 40414245
02 40414243

