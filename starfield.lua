function draw_starfield()
    -- bright stars
    for i=1,#starfield.x do
        pset(starfield.x[i],starfield.y[i],7)
    end
    
    -- dim stars
    for i=1,#starfield.x_bg do
        pset(starfield.x_bg[i],starfield.y_bg[i],1) 
    end

    -- big stars
    for i=1,#starfield.x_2 do
        circ(starfield.x_2[i],starfield.y_2[i],1,1) 
    end
end

function animate_starfield()
    for i=1,#starfield.y do
        starfield.y[i]=starfield.y[i]+starfield.spd
        if starfield.y[i] > 127 then
            starfield.y[i] = 0
            starfield.x[i] = rnd(128)
        end
    end

    for i=1,#starfield.y_bg do
        starfield.y_bg[i]=starfield.y_bg[i]+starfield.spd_bg
        if starfield.y_bg[i] > 127 then
            starfield.y_bg[i] = 0
            starfield.x_bg[i] = rnd(128)
        end
    end

    for i=1,#starfield.y_2 do
        starfield.y_2[i]=starfield.y_2[i]+starfield.spd_2
        if starfield.y_2[i] > 127 then
            starfield.y_2[i] = 0
            starfield.x_2[i] = rnd(128)
        end
    end

end