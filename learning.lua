function _init()
    cls(0) -- clear the screen

    -- game mode switcher
    game_mode="splash screen"
    splashscren_timer = 0

    blink_time = 1
    frame=0
    charge_delay_debounce=0
    game_time=0


    last_btn5_state = false  -- track previous button state for edge detection

end

function _update()
    splashscren_timer = splashscren_timer + 1
    blink_time = blink_time + 1   -- update blink time every frame
    game_time += 1

    if game_mode == "game" then
        update_game()
    elseif game_mode == "start" then
        update_startscreen()
    elseif game_mode == "game over" then
        update_gameover()
    elseif game_mode == "splash screen" then
        update_splashscreen()
    end   
end

function _draw()
    if game_mode == "game" then
        draw_game()
    elseif game_mode == "start" then
        draw_startscreen()
    elseif game_mode == "game over" then
        draw_gameover()       
    elseif game_mode == "splash screen" then
        draw_splashscreen()
    end 
end

-- Game Balance Configuration (NO INDENTATION - global level)
normal_shot_damage = 1
charged_shot_damage = 5

-- Enemy Type Definitions (NO INDENTATION - global level)
enemy_types = {
    -- Basic enemy (weak, fast)
    basic = {
        hp = 2,
        speed = 0.4,
        score = 100,
        sprite_start = 48,
        sprite_end = 51,
        anim_speed = 0.3,
        damage=1
    },
    
    -- Heavy enemy (tough, slow)
    heavy = {
        hp = 5,
        speed = 0.2,
        score = 300,
        sprite_start = 53,  -- you can use different sprites later
        sprite_end = 56,
        anim_speed = 0.2,
        damage=2
    },
    
    -- Fast enemy (weak but quick)
    fast = {
        hp = 1,
        speed = 0.9,
        score = 150,
        sprite_start = 58,
        sprite_end = 61,
        anim_speed = 0.5,
        damage=1
    }
}

-- EXPLOSION SYSTEM
explosions = {}

function create_explosion(x, y)
    local new_exp = {
        x = x,
        y = y,
        life = 20, -- life in frames
        particles = {},
        circ_yellow = {radius = 12, max_radius = 10, life = 12},
        circ_white = {radius = 0, max_radius = 18, life = 24}
    }

    -- Create explosion particles
    for i=1, 30 do
        local angle = rnd(2 * 3.14159)
        local speed = 0.5 + rnd(1)
        add(new_exp.particles, {
            x = x,
            y = y,
            dx = cos(angle) * speed,
            dy = sin(angle) * speed
        })
    end

    return new_exp
end

function get_random_enemy_type()
    local types = {}
    -- Iterate through the enemy_types table to get the keys
    for key, value in pairs(enemy_types) do
        add(types, key)
    end
    -- Return a random key from the types table
    return types[flr(rnd(#types)) + 1]
end

function create_enemy(enemy_type, x, y)
    local config = enemy_types[enemy_type]
    if not config then
        config = enemy_types.basic -- fallback to basic if type doesn't exist
    end
    
    return {
        x = x,
        y = y,
        spr = config.sprite_start,
        hp = config.hp,
        max_hp = config.hp,  -- store max for visual effects
        speed = config.speed,
        score_value = config.score,
        sprite_start = config.sprite_start,
        sprite_end = config.sprite_end,
        anim_speed = config.anim_speed,
        damage = config.damage,
        blink_timer = 0,
        enemy_type = enemy_type  -- store type for reference
    }
end

function startgame()
    game_mode = "game" -- switch to game mode
    enemies = {}
    game_time=0
    
    -- Spawn a random enemy at the start
    add(enemies, create_enemy(get_random_enemy_type(), 60, 00))

    --charge shot logic
        charge = 0
        charging = false
        muzzle_size = 4 
        charged_muzzle_pos=nil

    -- player variables
        player={x=60,y=84,dx=0,dy=0,spr=2,hp=3,invul=0}
        shots = {}

    -- game general variables
        score = 00000

    -- starfield variables
        starfield={
            x={}, y={}, spd=1, 
            x_bg={}, y_bg={}, spd_bg=0.6, 
            x_2={}, y_2={}, spd_2=0.2
        }

        for i=1,30 do
            add(starfield.x, flr(rnd(128))) -- random x position
            add(starfield.y, flr(rnd(118)+10)) -- random y position
        end
        
        for i=1,50 do
            add(starfield.x_bg, flr(rnd(128))) -- random x position
            add(starfield.y_bg, flr(rnd(118)+10)) -- random y position
        end

        for i=1, 5 do
            add(starfield.x_2, flr(rnd(128))) -- random x position
            add(starfield.y_2, flr(rnd(118)+10)) -- random y position
        end
end