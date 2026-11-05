extends RefCounted
## Falas locais e revisadas; IDs são a posição estável na lista.

const CASES := [
	["Você roubou as paçocas da minha irmã!", "Foi só uma... por viagem."],
	["Comeu a coxinha que tinha meu nome!", "Achei que você fosse a marca."],
	["Mudou o Wi-Fi e não contou a senha!", "Era ‘pede por favor’. Você só gritava."],
	["Tocou flauta a noite inteira!", "Ninguém pediu bis. Eu ainda esperava."],
	["Cobrou taxa pra devolver meu grampeador!", "Sem taxa, como eu pagaria o carimbo?"],
	["Guardou feijão no meu pote de sorvete!", "Mas você pediu sobremesa sem açúcar."],
	["Você escondeu meu controle remoto!", "Era o único jeito de mudar de canal."],
	["Vendeu lugar na fila da cantina!", "O pastel era ruim. Vendi a esperança."],
	["Botou passas até na farofa!", "Na sobremesa já não cabia mais."],
	["Contou o final antes de eu ver a novela!", "Você perguntou se ia acabar bem."],
	["Pegou meu carregador e sumiu!", "Ia devolver quando chegasse a 100%."],
	["Pôs sal no meu café!", "Você pediu pra cortar o açúcar."],
	["Colou ‘puxe’ nas portas de empurrar!", "Agora todo mundo pensa antes de entrar."],
	["Embrulhou pastel no mapa do tesouro!", "Ninguém saiu de mãos vazias."],
	["Guardou meias sujas no meu capacete!", "Era isso ou na sua coroa."],
	["Ensinou o papagaio a imitar o alarme!", "Você pediu mais segurança."],
	["Ocupou o banheiro por duas horas!", "O aviso dizia: faça tudo com calma."],
	["Deixou a louça invisível em vez de lavar!", "Você disse que não queria mais ver a pia."],
	["Vendeu uma espada de papelão!", "A etiqueta dizia: só para cortar gastos."],
	["Sete minutos de áudio pra dizer ‘ok’?!", "Eu não queria parecer seco."],
	["Alugou nosso fantasma para uma festa!", "Ele precisava de uma renda extra."],
	["Comeu o recheio e devolveu os biscoitos!", "Você sempre reclama que são doces demais."],
	["Negou minhas férias pela quarta vez!", "Seu pedido chegou durante as minhas."],
	["Passou alho no perfume da fortaleza!", "O vendedor garantiu: afasta visitas."],
	["Adiantou o sino do almoço!", "A barriga não acerta o relógio."],
	["Serviu meu café gelado!", "Era pra você beber mais devagar."],
	["Varreu a sujeira pra baixo do tapete!", "Você pediu o salão livre de poeira."],
	["Comeu o bolo antes do aniversário!", "Eu estava testando se era surpresa."],
	["Usou meu balde pra guardar moedas!", "Você vive dizendo que dinheiro é sujo."],
	["Trocou as etiquetas das chaves!", "Agora ninguém entra sem paciência."],
	["Pegou as moedas do café!", "Achei que a caixinha fosse gorjeta."],
	["Deixou a geladeira aberta!", "Achei que era o ar-condicionado."],
	["Trouxe pão duro pra cantina!", "O mole ficou duro esperando na fila."],
	["Pôs meu nome na conta da taverna!", "Você disse que podia contar com você."],
	["Arrancou a última página do meu livro!", "Era pra você querer a continuação."],
	["Usou meu barco pra entregar marmita!", "Finalmente ele trouxe algum lucro."],
	["Encheu o corredor de raízes!", "Você pediu um caminho mais natural."],
	["Mordeu a maçã de decoração!", "Até ela parecia fresca perto de mim."],
	["Seu ensaio ocupou a hora do almoço!", "Barriga roncando não conta como crítica."],
	["Cobrou aluguel do meu próprio caixão!", "Localização privilegiada custa caro."],
	["Sua poção de coragem era só café!", "Funcionou. Você veio reclamar."],
	["Usou meu escudo pra assar pizza!", "Finalmente ele defendeu o jantar."],
	["Botou cadeado no pote de biscoitos!", "Você chamou de cofre de emergência."],
	["Vendeu meu almoço na feira!", "Elogiaram tanto que guardei a receita."],
	["Carimbou ‘urgente’ no cardápio!", "A fome não aceita prazo de cinco dias."],
	["Trocou minhas botas de lado!", "Você pediu um passo diferente."],
	["Escreveu fofoca no quadro de avisos!", "A letra estava melhor que os avisos."],
	["Marcou reunião na hora do almoço!", "Era o horário com mais gente acordada."]
]
const RESTRICTIONS := {3: "bardo", 4: "vampiro", 17: "alquimista", 35: "pirata", 36: "elfa", 37: "zumbi", 38: "bardo", 39: "vampiro", 40: "alquimista", 41: "cavaleira"}


static func eligible(character_id: String) -> Array[int]:
	var result: Array[int] = []
	for index in range(CASES.size()):
		if not RESTRICTIONS.has(index) or RESTRICTIONS[index] == character_id:
			result.append(index)
	return result
