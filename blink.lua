function blink()
    local blink_animation = {5,5,5,5,5,6,6,6,6,6,7,7,7,7,7,6,6,6,6,6}

    if blink_time > #blink_animation then
        blink_time = 1 -- reset blink time
    end
    return blink_animation[blink_time]
end

function draw_my_enemy(my_enemy)
    spr(my_enemy.spr, my_enemy.x, my_enemy.y)
end

function collide(a,b)
    -- the math
    local a_left = a.x
    local a_right = a.x + 7
    local a_top = a.y
    local a_bottom = a.y + 7

    local b_left = b.x
    local b_right = b.x + 7
    local b_top = b.y
    local b_bottom = b.y + 7

    if a_top > b_bottom then return false end
    if b_top > a_bottom then return false end
    if a_left > b_right then return false end
    if b_left > a_right then return false end

    return true
end

function draw_explosions()
    for exp in all(explosions) do
        -- Draw yellow circle that shrinks
        if exp.circ_yellow.radius > 0 then
            circfill(exp.x+4, exp.y+4, exp.circ_yellow.radius, 9) -- Color 10 is yellow
        end

        -- Draw white shockwave that expands
        if exp.circ_white.radius > 0 then
            circ(exp.x+4, exp.y+4, exp.circ_white.radius, 7) -- Color 7 is white
        end

        -- Draw individual particles
        for p in all(exp.particles) do
            pset(p.x, p.y, 7) -- Color 7 is white
        end
    end
end