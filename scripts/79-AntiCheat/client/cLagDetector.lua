local func = coroutine.wrap( function()
    while true do
        Network:Send( "LagCheck" )
        Timer.Sleep( 3000 )
    end
end )()