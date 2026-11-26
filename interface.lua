function desenharObjeto(obj, img)
    local escalaX = obj.w / img:getWidth()
    local escalaY = obj.h / img:getHeight()
    love.graphics.draw(img, obj.x, obj.y, 0, escalaX, escalaY)
end

function desenharControleSom()
    local x, y, largura, altura = 374, 12, 34, 34

    iniciarHoverBotao(x, y, largura, altura, 1.06)

    if somMutado then
        love.graphics.setColor(0.82, 0.32, 0.28)
    else
        love.graphics.setColor(1.0, 0.82, 0.48)
    end
    love.graphics.rectangle("fill", x, y, largura, altura, 8, 8)

    love.graphics.setColor(0.08, 0.06, 0.12, 0.92)
    love.graphics.rectangle("fill", x + 2, y + 2, largura - 4, altura - 4, 7, 7)

    love.graphics.setColor(1.0, 0.97, 0.86)
    love.graphics.polygon("fill",
        x + 6, y + 12,
        x + 12, y + 12,
        x + 20, y + 7,
        x + 20, y + 27,
        x + 12, y + 22,
        x + 6, y + 22
    )

    love.graphics.setLineWidth(2)
    if somMutado then
        love.graphics.line(x + 23, y + 12, x + 30, y + 22)
        love.graphics.line(x + 30, y + 12, x + 23, y + 22)
    else
        love.graphics.line(
            x + 22, y + 12,
            x + 25, y + 14,
            x + 26, y + 17,
            x + 25, y + 20,
            x + 22, y + 22
        )
        love.graphics.line(
            x + 25, y + 8,
            x + 29, y + 12,
            x + 30, y + 17,
            x + 29, y + 22,
            x + 25, y + 26
        )
    end
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.pop()
end

function iniciarHoverBotao(x, y, largura, altura, escalaHover)
    local mouseX, mouseY = love.mouse.getPosition()
    local emCima = mouseX >= x and mouseX <= x + largura
        and mouseY >= y and mouseY <= y + altura
    local escala = emCima and (escalaHover or 1.04) or 1

    love.graphics.push()
    love.graphics.translate(x + largura / 2, y + altura / 2)
    love.graphics.scale(escala, escala)
    love.graphics.translate(-(x + largura / 2), -(y + altura / 2))
end

function love.draw()
    -- fundo ajustado ao tamanho da janela
    local wfundo, hfundo = love.graphics.getDimensions()
    love.graphics.draw(fundoImg, 0, 0, 0,
        wfundo / fundoImg:getWidth(),
        hfundo / fundoImg:getHeight()
    )

    if estado == "menu" then
        love.graphics.setColor(0, 0, 0, 0.72)
        love.graphics.rectangle("fill", 0, 0, wfundo, hfundo)

        love.graphics.setFont(tituloFonte)

        local tituloY = 150
        local tempo = love.timer.getTime()
        local pulso = 1 + math.sin(tempo * 2.2) * 0.018

        love.graphics.push()
        love.graphics.translate(wfundo / 2, tituloY + 112)
        love.graphics.scale(pulso, pulso)
        love.graphics.translate(-wfundo / 2, -(tituloY + 112))

        local linhas = {"GATO VS", "TODDYS"}
        local yLinhas = {tituloY, tituloY + 58}

        for linha = 1, 2 do
            for deslocX = -4, 4, 4 do
                for deslocY = -4, 4, 4 do
                    if deslocX ~= 0 or deslocY ~= 0 then
                        love.graphics.setColor(0.12, 0.18, 0.38)
                        love.graphics.printf(linhas[linha], deslocX, yLinhas[linha] + deslocY, wfundo, "center")
                    end
                end
            end

            love.graphics.setColor(0.28, 0.20, 0.38)
            love.graphics.printf(linhas[linha], 5, yLinhas[linha] + 9, wfundo, "center")

            love.graphics.setColor(1.0, 0.73, 0.27)
            love.graphics.printf(linhas[linha], 0, yLinhas[linha], wfundo, "center")
        end

        love.graphics.pop()

        local botaoX, botaoY, botaoW, botaoH = 105, 530, 210, 64

        iniciarHoverBotao(botaoX, botaoY, botaoW, botaoH)

        love.graphics.setColor(0.20, 0.13, 0.12)
        love.graphics.rectangle("fill", botaoX - 5, botaoY + 8, botaoW + 10, botaoH, 16, 16)

        love.graphics.setColor(0.35, 0.19, 0.24)
        love.graphics.rectangle("fill", botaoX - 4, botaoY - 4, botaoW + 8, botaoH + 8, 16, 16)

        love.graphics.setColor(1.0, 0.82, 0.48)
        love.graphics.rectangle("fill", botaoX, botaoY, botaoW, botaoH, 12, 12)

        love.graphics.setFont(botaoFonte)
        love.graphics.setColor(0.35, 0.19, 0.24)
        love.graphics.printf("INICIAR", botaoX - 2, botaoY + 19, botaoW + 4, "center")
        love.graphics.setColor(1.0, 0.97, 0.86)
        love.graphics.printf("INICIAR", botaoX, botaoY + 16, botaoW, "center")
        love.graphics.pop()

        local selecaoY = 612
        iniciarHoverBotao(botaoX, selecaoY, botaoW, botaoH)
        love.graphics.setColor(0.20, 0.13, 0.12)
        love.graphics.rectangle("fill", botaoX - 5, selecaoY + 8, botaoW + 10, botaoH, 16, 16)

        love.graphics.setColor(0.35, 0.19, 0.24)
        love.graphics.rectangle("fill", botaoX - 4, selecaoY - 4, botaoW + 8, botaoH + 8, 16, 16)

        love.graphics.setColor(1.0, 0.82, 0.48)
        love.graphics.rectangle("fill", botaoX, selecaoY, botaoW, botaoH, 12, 12)

        love.graphics.setFont(selecaoBotaoFonte)
        local textoY = selecaoY + (botaoH - selecaoBotaoFonte:getHeight()) / 2
        love.graphics.setColor(0.35, 0.19, 0.24)
        love.graphics.printf("ESCOLHER GATO", botaoX - 2, textoY + 2, botaoW + 4, "center")
        love.graphics.setColor(1.0, 0.97, 0.86)
        love.graphics.printf("ESCOLHER GATO", botaoX, textoY, botaoW, "center")
        love.graphics.pop()

        desenharControleSom()
        love.graphics.setColor(1, 1, 1)
        return
    end

    if estado == "selecao" then
        love.graphics.setColor(0, 0, 0, 0.78)
        love.graphics.rectangle("fill", 0, 0, wfundo, hfundo)

        love.graphics.setFont(selecaoTituloFonte)
        love.graphics.setColor(1.0, 0.82, 0.48)
        love.graphics.printf("ESCOLHA SEU GATO", 0, 94, wfundo, "center")

        love.graphics.setFont(instrucaoFonte)
        love.graphics.setColor(1.0, 0.97, 0.86)
        love.graphics.printf("Toque em um dos quatro personagens", 0, 143, wfundo, "center")

        for i, personagem in ipairs(personagens) do
            local coluna = (i - 1) % 2
            local linha = math.floor((i - 1) / 2)
            local cartaoX = 25 + coluna * 190
            local cartaoY = 190 + linha * 215
            local cartaoW, cartaoH = 180, 200
            local selecionado = i == personagemSelecionado

            iniciarHoverBotao(cartaoX, cartaoY, cartaoW, cartaoH, 1.025)
            love.graphics.setColor(0.08, 0.06, 0.12, 0.88)
            love.graphics.rectangle("fill", cartaoX, cartaoY, cartaoW, cartaoH, 14, 14)

            if selecionado then
                love.graphics.setColor(1.0, 0.82, 0.48)
                love.graphics.setLineWidth(4)
            else
                love.graphics.setColor(0.55, 0.43, 0.50)
                love.graphics.setLineWidth(2)
            end
            love.graphics.rectangle("line", cartaoX, cartaoY, cartaoW, cartaoH, 14, 14)

            local imagem = personagem.imagem
            local escala = math.min(112 / imagem:getWidth(), 120 / imagem:getHeight())
            local imagemW = imagem:getWidth() * escala
            local imagemH = imagem:getHeight() * escala
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(imagem,
                cartaoX + (cartaoW - imagemW) / 2,
                cartaoY + (cartaoH - imagemH) / 2,
                0, escala, escala
            )
            love.graphics.pop()
        end

        iniciarHoverBotao(105, 634, 210, 60)
        love.graphics.setColor(0.20, 0.13, 0.12)
        love.graphics.rectangle("fill", 100, 642, 220, 60, 16, 16)
        love.graphics.setColor(1.0, 0.82, 0.48)
        love.graphics.rectangle("fill", 105, 634, 210, 60, 12, 12)
        love.graphics.setFont(botaoFonte)
        love.graphics.setColor(0.35, 0.19, 0.24)
        love.graphics.printf("JOGAR", 105, 650, 210, "center")
        love.graphics.pop()

        iniciarHoverBotao(145, 710, 130, 40)
        love.graphics.setFont(instrucaoFonte)
        love.graphics.setColor(1.0, 0.97, 0.86)
        love.graphics.printf("VOLTAR", 145, 713, 130, "center")
        love.graphics.pop()
        desenharControleSom()
        love.graphics.setColor(1, 1, 1)
        return
    end

    -- desenhar gato
    desenharObjeto(gato, gatoImg)

    -- desenhar toddys
    for i, toddy in ipairs(toddys) do
        desenharObjeto(toddy, toddyImg)
    end

    if estado == "jogando" then
        love.graphics.setFont(love.graphics.newFont("assets/font/comic-bold.ttf", 20))

        local tempoDecorrido = 0
        local brilhoPontuacao = 0
        if tempoEfeitoMarco > 0 then
            tempoDecorrido = 1.5 - tempoEfeitoMarco
            brilhoPontuacao = math.min(1, tempoEfeitoMarco / 0.35)
        end
        if tempoEfeitoRecorde > 0 then
            brilhoPontuacao = math.max(brilhoPontuacao, math.min(1, tempoEfeitoRecorde / 0.45))
        end
        local escalaPontuacao = 1 + math.sin(tempoDecorrido * 12) * brilhoPontuacao * 0.14
        love.graphics.push()
        love.graphics.translate(85, 22)
        love.graphics.scale(escalaPontuacao, escalaPontuacao)
        love.graphics.translate(-85, -22)

        love.graphics.setColor(0.28, 0.20, 0.38)
        love.graphics.printf(string.format("%03d", math.floor(pontuacao * 3)), 12, 14, 150, "left")

        love.graphics.setColor(1.0, 0.82 + brilhoPontuacao * 0.16, 0.48 + brilhoPontuacao * 0.32)
        love.graphics.printf(string.format("%03d", math.floor(pontuacao * 3)), 10, 12, 150, "left")
        love.graphics.pop()
        love.graphics.setColor(1, 1, 1)

        if tempoEfeitoMarco > 0 then
            local alpha = math.min(1, tempoEfeitoMarco / 0.35)
            local escala = 1 + math.sin(tempoDecorrido * 12) * 0.06
            love.graphics.push()
            love.graphics.translate(wfundo / 2, 72)
            love.graphics.scale(escala, escala)
            love.graphics.translate(-wfundo / 2, -72)
            love.graphics.setFont(botaoFonte)
            love.graphics.setColor(0.28, 0.20, 0.38, alpha)
            love.graphics.printf(string.format("%d PONTOS!", marcoPontuacaoAtual), 2, 62, wfundo, "center")
            love.graphics.setColor(1.0, 0.82, 0.48, alpha)
            love.graphics.printf(string.format("%d PONTOS!", marcoPontuacaoAtual), 0, 60, wfundo, "center")
            love.graphics.pop()
            love.graphics.setColor(1, 1, 1)
        end

        if tempoEfeitoRecorde > 0 then
            local alpha = math.min(1, tempoEfeitoRecorde / 0.4)
            local escala = 1 + math.sin(love.timer.getTime() * 10) * 0.07
            love.graphics.push()
            love.graphics.translate(wfundo / 2, 112)
            love.graphics.scale(escala, escala)
            love.graphics.translate(-wfundo / 2, -112)
            love.graphics.setFont(botaoFonte)
            love.graphics.setColor(0.28, 0.20, 0.38, alpha)
            love.graphics.printf("NOVO RECORDE!", 2, 102, wfundo, "center")
            love.graphics.setColor(1.0, 0.73, 0.27, alpha)
            love.graphics.printf("NOVO RECORDE!", 0, 100, wfundo, "center")
            love.graphics.pop()
            love.graphics.setColor(1, 1, 1)
        end
    end

    if estado == "gameover" then
        love.graphics.setColor(0.08, 0.06, 0.12, 0.88)
        love.graphics.rectangle("fill", 0, 0, wfundo, hfundo)

        love.graphics.setFont(tituloFonte)

        for deslocX = -4, 4, 4 do
            for deslocY = -4, 4, 4 do
                if deslocX ~= 0 or deslocY ~= 0 then
                    love.graphics.setColor(0.20, 0.11, 0.18)
                    love.graphics.printf("GAME OVER", deslocX, 218 + deslocY, wfundo, "center")
                end
            end
        end

        love.graphics.setColor(0.28, 0.20, 0.38)
        love.graphics.printf("GAME OVER", 5, 227, wfundo, "center")
        love.graphics.setColor(1.0, 0.73, 0.27)
        love.graphics.printf("GAME OVER", 0, 218, wfundo, "center")

        local pontuacaoFinal = math.floor(pontuacao * 3)
        love.graphics.setFont(love.graphics.newFont("assets/font/comic-bold.ttf", 21))
        love.graphics.setColor(0.28, 0.20, 0.38)
        love.graphics.printf(string.format("Pontuação: %03d", pontuacaoFinal), 3, 292, wfundo, "center")
        love.graphics.setColor(1.0, 0.82, 0.48)
        love.graphics.printf(string.format("Pontuação: %03d", pontuacaoFinal), 0, 289, wfundo, "center")

        love.graphics.setFont(love.graphics.newFont("assets/font/comic-bold.ttf", 18))
        love.graphics.setColor(0.28, 0.20, 0.38)
        love.graphics.printf(string.format("Recorde: %03d", recorde), 3, 328, wfundo, "center")
        love.graphics.setColor(1.0, 0.97, 0.86)
        love.graphics.printf(string.format("Recorde: %03d", recorde), 0, 325, wfundo, "center")

        if novoRecorde then
            love.graphics.setFont(love.graphics.newFont("assets/font/comic-bold.ttf", 18))
            local escalaRecorde = 1
            if tempoEfeitoRecorde > 0 then
                escalaRecorde = 1 + math.sin(love.timer.getTime() * 10) * 0.08
            end
            love.graphics.push()
            love.graphics.translate(wfundo / 2, 369)
            love.graphics.scale(escalaRecorde, escalaRecorde)
            love.graphics.translate(-wfundo / 2, -369)
            love.graphics.setColor(0.28, 0.20, 0.38)
            love.graphics.printf("NOVO RECORDE!", 3, 362, wfundo, "center")
            love.graphics.setColor(1.0, 0.73, 0.27)
            love.graphics.printf("NOVO RECORDE!", 0, 359, wfundo, "center")
            love.graphics.pop()
        end

        local botaoX, botaoY, botaoW, botaoH = 75, 520, 270, 70

        iniciarHoverBotao(botaoX, botaoY, botaoW, botaoH)
        love.graphics.setColor(0.20, 0.13, 0.12)
        love.graphics.rectangle("fill", botaoX - 5, botaoY + 8, botaoW + 10, botaoH, 16, 16)

        love.graphics.setColor(0.35, 0.19, 0.24)
        love.graphics.rectangle("fill", botaoX - 4, botaoY - 4, botaoW + 8, botaoH + 8, 16, 16)

        love.graphics.setColor(1.0, 0.82, 0.48)
        love.graphics.rectangle("fill", botaoX, botaoY, botaoW, botaoH, 12, 12)

        love.graphics.setFont(love.graphics.newFont("assets/font/comic-bold.ttf", 18))
        love.graphics.setColor(0.35, 0.19, 0.24)
        love.graphics.printf("TENTAR NOVAMENTE", botaoX - 2, botaoY + 24, botaoW + 4, "center")
        love.graphics.setColor(1.0, 0.97, 0.86)
        love.graphics.printf("TENTAR NOVAMENTE", botaoX, botaoY + 21, botaoW, "center")
        love.graphics.pop()

        local voltarY = 610
        iniciarHoverBotao(botaoX, voltarY, botaoW, botaoH)
        love.graphics.setColor(0.20, 0.13, 0.12)
        love.graphics.rectangle("fill", botaoX - 5, voltarY + 8, botaoW + 10, botaoH, 16, 16)

        love.graphics.setColor(0.35, 0.19, 0.24)
        love.graphics.rectangle("fill", botaoX - 4, voltarY - 4, botaoW + 8, botaoH + 8, 16, 16)

        love.graphics.setColor(1.0, 0.82, 0.48)
        love.graphics.rectangle("fill", botaoX, voltarY, botaoW, botaoH, 12, 12)

        love.graphics.setFont(instrucaoFonte)
        local textoVoltarY = voltarY + (botaoH - instrucaoFonte:getHeight()) / 2
        love.graphics.setColor(0.35, 0.19, 0.24)
        love.graphics.printf("VOLTAR AO INÍCIO", botaoX - 2, textoVoltarY + 2, botaoW + 4, "center")
        love.graphics.setColor(1.0, 0.97, 0.86)
        love.graphics.printf("VOLTAR AO INÍCIO", botaoX, textoVoltarY, botaoW, "center")
        love.graphics.pop()

        love.graphics.setColor(1, 1, 1)
    end

    desenharControleSom()
end
