-- para rodar coloque no console:
-- Set-Alias love "C:\Program Files\LOVE\love.exe"
-- depois: love .

-- tabela com dados do gato
gato = {
    x = 182,
    y = 612,
    w = 56,
    h = 60
}

function temColisao(X1, Y1, L1, A1, X2, Y2, L2, A2)
    return  X2 < X1 + L1 and
            X1 < X2 + L2 and
            Y1 < Y2 + A2 and
            Y2 < Y1 + A1
end    

-- tabela com dados do toddy
toddys = {}

-- Mantém a velocidade original do PC como referência de 240 FPS.
local FPS_REFERENCIA = 240
local TOLERANCIA_TEMPO = 0.000000001
local tempoDesdeUltimoToddy = 0
local intervaloSpawn = 100 / FPS_REFERENCIA
estado = "menu"
personagemSelecionado = 1
somMutado = false
volumeAudio = 0.45
pontuacao = 0
recorde = 0
novoRecorde = false
proximoMarcoPontuacao = 50
marcoPontuacaoAtual = 0
tempoEfeitoMarco = 0
tempoEfeitoRecorde = 0
efeitoRecordeTocado = false

function carregarRecorde()
    local conteudo = love.filesystem.read("recorde.txt")
    if conteudo then
        recorde = tonumber(conteudo) or 0
    end
end

function salvarRecorde()
    love.filesystem.write("recorde.txt", tostring(recorde))
end

function iniciarJogo()
    tocarSomBotao()
    if somGameOver then
        somGameOver:stop()
    end
    estado = "jogando"
    tempoDesdeUltimoToddy = 0
    intervaloSpawn = 100 / FPS_REFERENCIA
    pontuacao = 0
    novoRecorde = false
    proximoMarcoPontuacao = 50
    marcoPontuacaoAtual = 0
    tempoEfeitoMarco = 0
    tempoEfeitoRecorde = 0
    efeitoRecordeTocado = false
    toddys = {}
    gato.x = 182
    gato.y = 612
    gatoImg = personagens[personagemSelecionado].imagem

    if trilhaMenu and trilhaMenu:isPlaying() then
        trilhaMenu:stop()
    end

    trilhaJogo:stop()
    trilhaJogo:play()

    criaToddy()
end

function love.load()
    love.window.setMode(420, 780, {resizable = false})
    love.window.setTitle("Jogo Do Gato")
    math.randomseed(os.time())
    carregarRecorde()

    fundoImg = love.graphics.newImage("assets/imagens/image.png")
    gatoImg  = love.graphics.newImage("assets/imagens/image.jpg")
    toddyImg = love.graphics.newImage("assets/imagens/toddy.jpg")
    tituloFonte = love.graphics.newFont("assets/font/comic-bold.ttf", 49)
    botaoFonte = love.graphics.newFont("assets/font/comic-bold.ttf", 25)
    selecaoTituloFonte = love.graphics.newFont("assets/font/comic-bold.ttf", 30)
    selecaoBotaoFonte = love.graphics.newFont("assets/font/comic-bold.ttf", 18)
    instrucaoFonte = love.graphics.newFont("assets/font/comic-bold.ttf", 18)

    personagens = {
        {imagem = gatoImg},
        {imagem = love.graphics.newImage("assets/imagens/gato_preto.png")},
        {imagem = love.graphics.newImage("assets/imagens/gato_claro.png")},
        {imagem = love.graphics.newImage("assets/imagens/gato_dorminhoco.png")}
    }

    carregarAudio()

end

function configurarDificuldade()
    local pontuacaoAtual = math.floor(pontuacao * 3)

    if pontuacaoAtual >= 200 then
        intervaloSpawn = 65 / FPS_REFERENCIA
        return 4, 6
    elseif pontuacaoAtual >= 100 then
        intervaloSpawn = 78 / FPS_REFERENCIA
        return 3, 5
    elseif pontuacaoAtual >= 50 then
        intervaloSpawn = 90 / FPS_REFERENCIA
        return 2, 4
    else
        intervaloSpawn = 100 / FPS_REFERENCIA
        return 1, 3
    end
end

function criaToddy()
    local velocidadeMinima, velocidadeMaxima = configurarDificuldade()

    toddy = {
        x = math.random(0, 420 - 60), -- posição X aleatória na tela
        y = -60,                      -- começa fora da tela
        w = 60,
        h = 60,
        velocidade = math.random(velocidadeMinima, velocidadeMaxima) * FPS_REFERENCIA,
        deslocamento_horizontal = math.random(-1,1)
    }
    table.insert(toddys, toddy)
end

-- função para movimentar o gato
function movimentarGato(dt)
    local velocidade = 320

    if love.keyboard.isDown('w') then
        gato.y = gato.y - velocidade * dt
    end
    if love.keyboard.isDown('a') then
        gato.x = gato.x - velocidade * dt
    end
    if love.keyboard.isDown('s') then
        gato.y = gato.y + velocidade * dt
    end
    if love.keyboard.isDown('d') then
        gato.x = gato.x + velocidade * dt
    end

    local larguraTela, alturaTela = love.graphics.getDimensions()
    if gato.x < 0 then
        gato.x = 0
    elseif gato.x + gato.w > larguraTela then
        gato.x = larguraTela - gato.w
    end

    if gato.y < 0 then
        gato.y = 0
    elseif gato.y + gato.h > alturaTela then
        gato.y = alturaTela - gato.h
    end
end

function mataGato()
    if estado ~= "jogando" then
        return
    end

    gatoImg = love.graphics.newImage("assets/imagens/gatoMorto.png")

    trilhaJogo:stop()
    tocarSomGameOver()

    local pontuacaoFinal = math.floor(pontuacao * 3)
    if pontuacaoFinal > recorde then
        recorde = pontuacaoFinal
        novoRecorde = true
        tempoEfeitoRecorde = 2.2
        salvarRecorde()
    else
        novoRecorde = false
    end

    estado = "gameover"
end    

function checaColisao()
    for k, toddy in pairs(toddys) do
        if temColisao(toddy.x, toddy.y, toddy.w, toddy.h, gato.x, gato.y, gato.w, gato.h) then
            mataGato()
        end
    end
end

-- função para mover toddys
function moverToddys(dt)
    for i = #toddys, 1, -1 do
        local toddy = toddys[i]
        toddy.y = toddy.y + toddy.velocidade * dt
        -- toddy.x = toddy.x + toddy.deslocamento_horizontal

        if toddy.y > love.graphics.getHeight() then
            table.remove(toddys, i)
        end
    end
end

-- cria toddys em intervalos de tempo, independentemente da taxa de quadros
function atualizarSpawn(dt)
    tempoDesdeUltimoToddy = tempoDesdeUltimoToddy + dt
    while tempoDesdeUltimoToddy + TOLERANCIA_TEMPO >= intervaloSpawn do
        tempoDesdeUltimoToddy = math.max(0, tempoDesdeUltimoToddy - intervaloSpawn)
        criaToddy()
    end
end

function love.update(dt)
    if tempoEfeitoRecorde > 0 then
        tempoEfeitoRecorde = math.max(0, tempoEfeitoRecorde - dt)
    end

    if estado == "jogando" then
        pontuacao = pontuacao + dt
        local pontosAtuais = math.floor(pontuacao * 3)
        local marcoAlcancado = nil

        while pontosAtuais >= proximoMarcoPontuacao do
            marcoAlcancado = proximoMarcoPontuacao
            if proximoMarcoPontuacao == 50 then
                proximoMarcoPontuacao = 100
            elseif proximoMarcoPontuacao == 100 then
                proximoMarcoPontuacao = 200
            else
                proximoMarcoPontuacao = proximoMarcoPontuacao + 100
            end
        end

        if marcoAlcancado then
            marcoPontuacaoAtual = marcoAlcancado
            tempoEfeitoMarco = 1.5
            tocarSomMarco()
        elseif tempoEfeitoMarco > 0 then
            tempoEfeitoMarco = math.max(0, tempoEfeitoMarco - dt)
        end

        local bateuRecorde = (recorde > 0 and pontosAtuais > recorde)
            or (recorde == 0 and pontosAtuais >= 50)
        if bateuRecorde and not efeitoRecordeTocado then
            efeitoRecordeTocado = true
            tempoEfeitoRecorde = 2.2
            if not marcoAlcancado then
                tocarSomMarco()
            end
        end

        movimentarGato(dt)
        moverToddys(dt)
        atualizarSpawn(dt)
        checaColisao()
    end
end

function love.mousepressed(x, y, botao)
    if botao ~= 1 then
        return
    end

    if x >= 374 and x <= 408 and y >= 12 and y <= 46 then
        somMutado = not somMutado
        aplicarVolumeAudio()
        tocarSomBotao()
        return
    end

    if estado == "menu" then
        if x >= 105 and x <= 315 and y >= 530 and y <= 594 then
            iniciarJogo()
        elseif x >= 105 and x <= 315 and y >= 612 and y <= 676 then
            tocarSomBotao()
            estado = "selecao"
        end
    elseif estado == "selecao" then
        for i = 1, #personagens do
            local coluna = (i - 1) % 2
            local linha = math.floor((i - 1) / 2)
            local cartaoX = 25 + coluna * 190
            local cartaoY = 190 + linha * 215

            if x >= cartaoX and x <= cartaoX + 180
                and y >= cartaoY and y <= cartaoY + 200 then
                tocarSomBotao()
                personagemSelecionado = i
                return
            end
        end

        if x >= 105 and x <= 315 and y >= 634 and y <= 694 then
            iniciarJogo()
        elseif x >= 145 and x <= 275 and y >= 710 and y <= 750 then
            tocarSomBotao()
            estado = "menu"
        end
    elseif estado == "gameover" then
        if x >= 75 and x <= 345 and y >= 520 and y <= 590 then
            iniciarJogo()
        elseif x >= 75 and x <= 345 and y >= 610 and y <= 680 then
            tocarSomBotao()
            estado = "menu"
            trilhaMenu:stop()
            trilhaMenu:play()
        end
    end
end

-- função genérica para desenhar objetos
