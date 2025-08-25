function update_game()
    cls(0)

    -- Update gets called 30 times a second
    local accel = 0.8
    local decel = 0.87
    local max_speed = 2
    local chargedtimer = 50
    local charge_delay = 6
    player.spr = 2 -- reset to default sprite
    frame = frame + 1

    -- Player Movement System
    -- x movement
    if btn(0) then
        player.dx = max(player.dx - accel, -max_speed)
        player.spr = 1
    elseif btn(1) then
        player.dx = min(player.dx + accel, max_speed)
        player.spr = 3
    else
        player.dx = player.dx * decel
        if abs(player.dx) < 0.05 then player.dx = 0 end
    end

    -- y movement
    if btn(2) then
        player.dy = max(player.dy - accel, -max_speed)
    elseif btn(3) then
        player.dy = min(player.dy + accel, max_speed)
    else
        player.dy = player.dy * decel
        if abs(player.dy) < 0.05 then player.dy = 0 end
    end

    player.x = player.x + player.dx
    player.y = player.y + player.dy

    -- clamp to screen bounds (assuming 8x8 sprite)
    player.x = mid(0, player.x, 120)
    player.y = mid(10, player.y, 120)


    -- Enemy Logic
    -- Move enemy
    for my_enemy in all(enemies) do
        my_enemy.y += my_enemy.speed
        my_enemy.spr += my_enemy.anim_speed
        if my_enemy.spr >= my_enemy.sprite_end then
            my_enemy.spr = my_enemy.sprite_start
        end
        if my_enemy.y > 128 then
            del(enemies, my_enemy)
            -- Spawn a random enemy when one goes off-screen
            add(enemies, create_enemy(get_random_enemy_type(), flr(rnd(120)), 0))
        end
        if my_enemy.blink_timer > 0 then
            my_enemy.blink_timer -= 1
        end
    end

    -- Collision system
    if player.invul <= 0 then
        for my_enemy in all(enemies) do
            if collide(my_enemy,player) then
                -- This is the fixed line
                player.hp = player.hp - my_enemy.damage
                sfx(5)
                player.invul=30
                del(enemies,my_enemy)
                -- Spawn a random enemy after player collision
                add(enemies, create_enemy(get_random_enemy_type(), flr(rnd(120)), 0))
            end
        end
    else
        player.invul -= 1
    end

    -- check if player still has hp
    if player.hp<=0 then
        game_mode="game over"
    end

    -- shooting logic with charge delay
    if btn(5) then
        -- button is held down
        charge_delay_debounce = charge_delay_debounce + 1
        
        if charge_delay_debounce >= charge_delay then
            charging = true
            local actual_charge = charge_delay_debounce - charge_delay
            if actual_charge < chargedtimer then
                charge = actual_charge
            else
                charge = chargedtimer
            end
            
            charge_maxed = (charge >= chargedtimer)
            if not charge_maxed and (frame % 6 == 0) then
                sfx(2,1)
            end
            if charge_maxed then
                if stat(54) != 3 and (frame % 8 == 0) then
                    sfx(3, 0,0,7)
                end
            end
        else
            -- during delay period
            charging = false
            charge = 0
            charge_maxed = false
        end

    elseif not btn(5) and last_btn5_state then
        -- This 'elseif' statement executes only on the frame the button is released.
        
        -- stop sfx(3) when button released
        if stat(54) == 3 then
            sfx(-1, 0)
        end

        -- check if we should fire
        if #shots < 3 then
            local fully_charged = (charge >= chargedtimer)
            local shot_speed = -3 - flr(charge / 10)
            local shot_sprite = fully_charged and 17 or 16
            
            add(shots, {
                x = player.x + 4,
                y = player.y,
                dy = shot_speed,
                spr = shot_sprite,
                damage = fully_charged and charged_shot_damage or normal_shot_damage
            })

            if fully_charged then
                sfx(1)
                sfx(4,2)
                player.dy = player.dy + 2
                muzzle_size = 8
                charged_muzzle_pos = {x=player.x+4, y=player.y-2}
            else
                sfx(0)
                muzzle_size = 4
                charged_muzzle_pos = nil
            end
        end
        
        -- reset charge state
        charge_delay_debounce = 0
        charging = false
        charge = 0
        charge_maxed = false

    end -- End of the main 'if btn(5)... elseif...' block

    -- update shots
    for i = #shots, 1, -1 do
        local s = shots[i]
        s.y = s.y + s.dy
        if s.y < -8 then
            deli(shots, i)
        end
    end

    -- Shot Collision system
    for i = #shots, 1, -1 do
        local shot = shots[i]
        for j = #enemies, 1, -1 do
            local enemy = enemies[j]
            if collide(shot, enemy) then
                enemy.hp = enemy.hp - shot.damage
                enemy.blink_timer = 10
                sfx(5)
                deli(shots, i)
                if enemy.hp <= 0 then
                    -- CREATE THE EXPLOSION HERE
                    add(explosions, create_explosion(enemy.x, enemy.y))
                    deli(enemies, j)
                    score = score + enemy.score_value
                    add(enemies, create_enemy(get_random_enemy_type(), flr(rnd(120)), 0))
                end
                break
            end
        end
    end

        -- Update and remove explosions
    for i=#explosions, 1, -1 do
        local exp = explosions[i]
        exp.life -= 1
        
        -- Update yellow circle size
        exp.circ_yellow.radius = exp.circ_yellow.max_radius * (exp.life / exp.circ_yellow.life)
        
        -- Update white shockwave size
        exp.circ_white.radius = exp.circ_white.max_radius * (1 - (exp.life / exp.circ_white.life))
        
        -- Update particle positions
        for p in all(exp.particles) do
            p.x += p.dx
            p.y += p.dy
        end
        
        -- Remove explosion if life is over
        if exp.life <= 0 then
            deli(explosions, i)
        end
    end


    -- animate muzzle flash
    if muzzle_size > 0 then
        muzzle_size = max(muzzle_size - 1, 0)
        if muzzle_size == 0 then
            charged_muzzle_pos = nil
        end
    end

    animate_starfield()
    
    last_btn5_state = btn(5)
end

function update_startscreen()
    if btnp(5) then
        startgame()
    end
end

function update_gameover()
    game_mode = "game over"
end

function update_splashscreen()
    if splashscren_timer > 120 then
        game_mode = "start"
    end
end