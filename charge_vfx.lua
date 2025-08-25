charged_particles = {}

function charge_vfx(charging, charge_maxed, player_x, player_y)
    -- spawn new particles if charging and not maxed
        if charging and not charge_maxed then
            if (time() * 10) % 1 < 0.34 then
                local angle = rnd(1) * 2 * 3.1415
                local dist = 20 + rnd(4)
                local colors = {12, 7, 15}
                local c = colors[flr(rnd(#colors))+1]
                add(charged_particles, {
                    angle = angle,
                    dist = dist,
                    r = 2 + rnd(1),
                    c = c
                })
            end
        end

    -- update and draw particles
        for i = #charged_particles, 1, -1 do
            local p = charged_particles[i]
            p.dist *= 0.6
            local px = player.x + 4 + cos(p.angle) * p.dist
            local py = player.y + 4 + sin(p.angle) * p.dist
            circfill(px, py, p.r, p.c)
            if p.dist < 1 or charge_maxed then
                deli(charged_particles, i)
            end
        end

    -- draw full charge feedback
        if charge_maxed then
            local charge_maxed_color = {7,7,10,10}
            local c = charge_maxed_color[flr(rnd(#charge_maxed_color))+1]

            local charge_maxed_size = {6,6,7,7,8,8,7,7}
            local s = charge_maxed_size[flr(rnd(#charge_maxed_size))+1]
            circfill(player.x + 4, player.y + 4, s, c)
        end
end