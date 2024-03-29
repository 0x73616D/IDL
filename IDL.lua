script_version("1.0")
script_authors("Sam")
script_name("[IDL]")
require "lib.moonloader"
local imgui = require "imgui"
local inicfg = require "inicfg"
local memory = require 'memory'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8


local directIni = "moonloader\\config\\IDL.ini"

local mainIni = inicfg.load(nil, directIni)

if not doesDirectoryExist("moonloader\\config") 
then 
    createDirectory("moonloader\\config")
end
if not doesFileExist("moonloader\\config\\IDL.ini")
then    
    file = io.open("moonloader\\config\\IDL.ini", "a")
    file:write("[config]\n")
    file:write("argb=FFFFFF\n")
    file:write("[colorimgui]\n")
    file:write("DR=255\n")
    file:write("DG=255\n")
    file:write("DB=255\n")
    file:write("[letra]\n")
    file:write("fuente=Roboto\n")
    file:write("size=8\n")
    file:write("flags=0x5\n")
    file:close()
end


local window = imgui.ImBool(false)
local color = imgui.ImFloat3(255, 255, 255)
local font = renderCreateFont(mainIni.letra.fuente,mainIni.letra.size,mainIni.letra.flags)
local active = true
local distance = 20


function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end    


    sampRegisterChatCommand('idl', function() 
        active = not active    
    end)

    style()

   
while true do
    wait(0)
          imgui.Process = 0        
          imgui.Process = window.v

        if not window.v then
          imgui.ShowCursor = false
        end

        if active then
            for i = 1, 2000 do
                result, carHandle = sampGetCarHandleBySampVehicleId(i)
                if result ~= mycar and doesVehicleExist(carHandle) and isCarOnScreen(carHandle) then
                    
                    carX, carY, carZ = getCarCoordinates(carHandle) -- coordenadas carro
                    --myX, myY, myZ = getCharCoordinates(PLAYER_PED) -- coordenadas jugador          
                    myX, myY, myZ = getCharCoordinates(PLAYER_PED)

                    infoPosX,    infoPosY    = convert3DCoordsToScreen(carX, carY, carZ) -- convierte coordenadas como cleo 
                    infoCarPosX, infoCarPosy = convert3DCoordsToScreen(myX, myY, myZ) -- convierte coordenadas como cleo 
                  
                    cdistance = getDistanceBetweenCoords3d(carX, carY, carZ, myX, myY, myZ) -- obtiene distancia de las coordenadas como cleo )                
                    
                    local hpcar = getCarHealth(carHandle)                      
                    vehName = getGxtText(getNameOfVehicleModel(getCarModel(carHandle)))

                    CambiarColor = "{ffffff}"

                    local carmodel = getCarModel(carHandle)

                    if carmodel == 596 then
                     vehName = "Coche de policia"                    
                    end

                    if carmodel == 435 or carmodel == 450 then
                      vehName = "Trailer"
                    end    

                    if not isCarEngineOn (carHandle) and hpcar <=375.0 then
                        CambiarColor = "{FF0000}"                        
                    end

                    
                    if  cdistance <= distance then -- compara distancia de las coordenadas como cleo                                   
                        renderFontDrawText(font, string.format(u8'{%s}Carro: {ffffff}'..vehName..' |{%s} ID: {ffffff}'..i..' |{%s} Vida: {ffffff}'..CambiarColor..hpcar..'', mainIni.config.argb, mainIni.config.argb, mainIni.config.argb), infoPosX - 130, infoPosY, 0xFFFFFFFF)                
                    end
                end               
            end
        end
    end
end

function cmd_1(arg)
    window.v = not window.v
    imgui.Process = window.v
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

local color = imgui.ImFloat3(mainIni.colorimgui.DR/255, mainIni.colorimgui.DG/255, mainIni.colorimgui.DB/255)

function imgui.OnDrawFrame()
	if window.v then
    imgui.ShowCursor = true

    local sw, sh = getScreenResolution()

	imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(405, 452), imgui.Cond.FirstUseEver)
if  imgui.Begin("Cambiar color IDL", window, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoResize) then
    imgui.PushItemWidth(325)
    imgui.ColorPicker3("##1", color)
    imgui.PushItemWidth(325)		
end
   


	if imgui.Button("Aceptar") then            
	   addOneOffSound(0, 0, 0, 1083)
       local clr = join_argb(0, color.v[1] * 255, color.v[2] * 255, color.v[3] * 255)   
       local r,g,b = color.v[1] * 255, color.v[2] * 255, color.v[3] * 255
       mainIni.config.argb = ("%06X"):format(clr)
       mainIni.colorimgui.DR = r
       mainIni.colorimgui.DG = g
       mainIni.colorimgui.DB = b
       inicfg.save(mainIni, directIni)
       sampAddChatMessage(string.format("Color seleccionado {%s}correctamente.", mainIni.config.argb), -1)
       imgui.ShowCursor = false
       window.v = false
    end
   
	imgui.End()
	end
end

function style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local icol = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
  
    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 15.0
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 6.0
    style.ItemSpacing = ImVec2(7, 6)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 15.0
    style.GrabMinSize = 15.0
    style.GrabRounding = 7.0
    style.ChildWindowRounding = 8.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)
    style.ButtonTextAlign = ImVec2(0.5, 0.5)

    colors[icol.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
    colors[icol.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
    colors[icol.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
    colors[icol.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[icol.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[icol.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[icol.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[icol.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[icol.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
    colors[icol.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
    colors[icol.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
    colors[icol.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[icol.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
    colors[icol.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[icol.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
    colors[icol.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[icol.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
    colors[icol.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
    colors[icol.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[icol.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[icol.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[icol.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
    colors[icol.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[icol.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[icol.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[icol.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
    colors[icol.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[icol.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[icol.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[icol.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[icol.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[icol.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[icol.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[icol.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[icol.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[icol.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[icol.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[icol.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[icol.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[icol.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end