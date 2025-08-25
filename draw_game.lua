function draw_game()
    -- Draw gets called when a new frame starts
    cls(0) -- CLS clears the screen, 0 is the color

    draw_starfield() -- call the starfield function

    draw_explosions() -- draw explosions

    charge_vfx(charging, charge_maxed, player.x, player.y)

    if player.invul <= 0 then
        spr(player.spr,player.x,player.y) -- spr` is the sprite call
     -- animate the burner: cycle through 5, 6, 7, 8, 9
        local burner_frame = 5 + flr((time()*12)%5)
        spr(burner_frame, player.x, player.y+8) -- draw the animated burner
    else
        -- invulnerable state, flicker effect
        if sin(game_time/4) < 0 then
            spr(player.spr,player.x,player.y) -- spr` is the sprite call
        -- animate the burner: cycle through 5, 6, 7, 8, 9
            local burner_frame = 5 + flr((time()*12)%5)
            spr(burner_frame, player.x, player.y+8) -- draw the animated burner
        end
    end

    -- draw enemies with blinking effect
    for my_enemy in all(enemies) do
        -- Check if enemy is blinking and it's a blink frame
        if my_enemy.blink_timer > 0 and flr(my_enemy.blink_timer/2) % 2 == 0 then
            for i=1, 15 do
                pal(i, 7)
            end
        end
        
        -- Draw the enemy sprite
        spr(my_enemy.spr, my_enemy.x, my_enemy.y)
        
        -- Reset the palette to normal
        pal()

    end

    -- draw shots
        for s in all(shots) do
            spr(s.spr or 17, s.x-4, s.y)
        end

    -- draw muzzle flash if active
        if muzzle_size > 0 then
            if charged_muzzle_pos then
                circfill(charged_muzzle_pos.x, charged_muzzle_pos.y, muzzle_size, 7)
                circ(charged_muzzle_pos.x, charged_muzzle_pos.y, muzzle_size, 12)
            else
                circfill(player.x+4, player.y-2, muzzle_size, 7)
                circ(player.x+4, player.y-2, muzzle_size, 12)
            end
        end

    -- create a topbar 
        rectfill(0, 0, 127, 9,0) 

    -- Game UI
        print ("score " .. score, 1,2,7) -- print the score
        
        -- draw empty HP
        for i = 1, 3 do
            spr(12,127-(i*9),2) 
        end

        -- draw filled HP
        for i = 1, player.hp do
            spr(11,127-(i*9),2) -- draw filled HP
        end

    -- Debugging Print
    --    print("player.dx: " .. player.dx, 0, 0, 7) -- print the player speed in x direction
    --    print("player.dy: " .. player.dy, 0, 8, 7) -- print the player
    --    print("player pos x: " .. player.x, 0, 16, 7) -- print the player position in x
    --    print("player pos y: " .. player.y, 0, 24, 7) -- print the player position in y
    --    print("shots count: " .. #shots, 0, 32, 7) -- print the number of shots
    --    print("charge: " .. charge, 0, 40, 7) -- print the charge value
    --    print (game_mode, 60, 60, 7) -- print the game mode for debugging
    --    print (player.hp, 60, 70, 7) -- print the player hp for debugging
    --    print(player.invul, 60, 80, 7) -- print the player invul for debugging  
    -- print(game_time, 60, 90, 7) -- print the game_time for debugging
    -- print(sin(game_time/4), 60, 100, 7) -- print the sin value for debugging
end

function draw_startscreen()
    cls(1) -- clear the screen

    -- print the game logo
    local logo_ranges_main = {
        {73, 79},
        {89, 95}
    }

    function draw_logo2(x, y)

    local row = 0
        for r=1,#logo_ranges_main do
            local start_spr = logo_ranges_main[r][1]
            local end_spr = logo_ranges_main[r][2]
            for i=start_spr, end_spr do
                spr(i, x + (i - start_spr)*8, y + row*8)
            end
            row = row + 1
        end
    end

    draw_logo2(40, 50)

    print("シュ-チンク゛ケ゛-ム", 28, 68, 8) -- print the title


    
    print("press x button", 36, 100, blink()) -- print the start message
end

function draw_gameover()
    cls(13) -- clear the screen
    print("game over", 46, 60, blink()) -- print game over message
    print("press any button", 34, 100, 6) -- print the start message
    if btn(5) or btn(4) then
        game_mode = "start" -- go back to start screen on button press
    end

end

function draw_splashscreen()
    cls(0) -- clear the screen
    print("shmup 0.1", 46, 100, 7) -- print the title
    print("a very bad shmup", 32, 60, 7) -- print the title
    print("by MAMORU", 46, 70, 7) -- print your name
end