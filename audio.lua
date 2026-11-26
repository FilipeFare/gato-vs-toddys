function aplicarVolumeAudio()
    local volumeAtual = somMutado and 0 or volumeAudio
    if trilhaMenu then
        trilhaMenu:setVolume(volumeAtual)
    end
    if trilhaJogo then
        trilhaJogo:setVolume(volumeAtual)
    end
    if somClique then
        somClique:setVolume(volumeAtual)
    end
    if somGameOver then
        somGameOver:setVolume(math.min(volumeAtual * 1.8, 1))
    end
    if somMarco then
        somMarco:setVolume(math.min(volumeAtual * 1.4, 1))
    end
end

function tocarSomBotao()
    if somMutado or not somClique then
        return
    end

    somClique:stop()
    somClique:play()
end

function tocarSomGameOver()
    if somMutado or not somGameOver then
        return
    end

    somGameOver:stop()
    somGameOver:play()
end

function tocarSomMarco()
    if somMutado or not somMarco then
        return
    end

    somMarco:stop()
    somMarco:play()
end

function carregarAudio()
    trilhaMenu = love.audio.newSource("assets/audio/Nine_Lives_per_Minute.mp3", "stream")
    trilhaMenu:setLooping(true)
    trilhaMenu:play()

    trilhaJogo = love.audio.newSource("assets/audio/Level_One_Calm_50s.mp3", "stream")
    trilhaJogo:setLooping(true)

    local taxaAmostragem = 22050
    local duracao = 0.22
    local numeroAmostras = math.floor(taxaAmostragem * duracao)
    local dadosClique = love.sound.newSoundData(numeroAmostras, taxaAmostragem, 16, 1)
    local frequencias = {392, 587.33}
    local inicioNotas = {0, 0.07}
    local duracaoNota = 0.15

    for i = 0, numeroAmostras - 1 do
        local tempo = i / taxaAmostragem
        local amostra = 0

        for nota = 1, #frequencias do
            local tempoNota = tempo - inicioNotas[nota]
            if tempoNota >= 0 and tempoNota <= duracaoNota then
                local progresso = tempoNota / duracaoNota
                local ataque = math.min(tempoNota / 0.01, 1)
                local envelope = ataque * (1 - progresso) ^ 2.7
                local fase = 2 * math.pi * frequencias[nota] * tempoNota
                local harmonia = math.sin(fase) + 0.2 * math.sin(fase * 2) + 0.05 * math.sin(fase * 3)
                amostra = amostra + harmonia * envelope * 0.28
            end
        end

        dadosClique:setSample(i, amostra)
    end

    somClique = love.audio.newSource(dadosClique, "static")

    local notasGameOver = {
        {frequencia = 587.33, inicio = 0.02, duracao = 0.18, volume = 0.26},
        {frequencia = 493.88, inicio = 0.25, duracao = 0.18, volume = 0.27},
        {frequencia = 392, inicio = 0.49, duracao = 0.20, volume = 0.28},
        {frequencia = 293.66, inicio = 0.74, duracao = 0.50, volume = 0.30}
    }
    local duracaoGameOver = 1.28
    local amostrasGameOver = math.floor(taxaAmostragem * duracaoGameOver)
    local dadosGameOver = love.sound.newSoundData(amostrasGameOver, taxaAmostragem, 16, 1)

    for i = 0, amostrasGameOver - 1 do
        local tempo = i / taxaAmostragem
        local amostra = 0

        for _, nota in ipairs(notasGameOver) do
            local tempoNota = tempo - nota.inicio
            if tempoNota >= 0 and tempoNota <= nota.duracao then
                local progresso = tempoNota / nota.duracao
                local envelope = math.min(tempoNota / 0.006, 1) * (1 - progresso) ^ 0.8
                local fase = (nota.frequencia * tempoNota) % 1
                local pulso = fase < 0.25 and 0.75 or -0.25
                local tom = pulso * 0.72 + math.sin(2 * math.pi * fase) * 0.28
                amostra = amostra + tom * envelope * nota.volume
            end
        end

        dadosGameOver:setSample(i, amostra)
    end

    somGameOver = love.audio.newSource(dadosGameOver, "static")

    local notasMarco = {392, 493.88, 587.33, 783.99}
    local inicioNotasMarco = {0, 0.075, 0.15, 0.225}
    local duracaoNotaMarco = 0.16
    local duracaoMarco = 0.42
    local amostrasMarco = math.floor(taxaAmostragem * duracaoMarco)
    local dadosMarco = love.sound.newSoundData(amostrasMarco, taxaAmostragem, 16, 1)

    for i = 0, amostrasMarco - 1 do
        local tempo = i / taxaAmostragem
        local amostra = 0

        for nota = 1, #notasMarco do
            local tempoNota = tempo - inicioNotasMarco[nota]
            if tempoNota >= 0 and tempoNota <= duracaoNotaMarco then
                local progresso = tempoNota / duracaoNotaMarco
                local envelope = math.min(tempoNota / 0.006, 1) * (1 - progresso) ^ 1.8
                local fase = (notasMarco[nota] * tempoNota) % 1
                local pulso = fase < 0.5 and 0.65 or -0.65
                local tom = pulso * 0.7 + math.sin(2 * math.pi * fase) * 0.3
                amostra = amostra + tom * envelope * 0.18
            end
        end

        dadosMarco:setSample(i, amostra)
    end

    somMarco = love.audio.newSource(dadosMarco, "static")
    aplicarVolumeAudio()
end
