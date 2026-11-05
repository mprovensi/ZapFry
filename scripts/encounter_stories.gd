extends RefCounted
## Falas locais e revisadas; IDs são a posição estável na lista.

const CASES := [
	["Você roubou as paçocas da minha irmã!", "Eu estava protegendo ela do açúcar.", "Então vamos testar sua resistência."],
	["Comeu a última coxinha e deixou a caixa vazia!", "Deixei a caixa por educação.", "Ótimo. Vou guardar seu recibo nela."],
	["Você mudou a senha do Wi-Fi da fortaleza!", "A nova senha é ‘calma’.", "Não atende aos meus requisitos de segurança."],
	["Seu solo de flauta durou seis horas!", "Era só a introdução.", "Ótimo. Agora vem o encerramento."],
	["Cobrou taxa para devolver meu grampeador!", "Faltou reconhecer firma.", "Reconheço. A firma é minha."],
	["Devolveu o pote de sorvete cheio de feijão!", "Pelo menos deixei congelado.", "Vamos descongelar essa ideia."],
	["Escondeu o controle remoto no caldeirão!", "Era uma receita de controle de temperatura.", "Hoje a temperatura fica por minha conta."],
	["Vendeu ingresso para a fila da cantina!", "A atração principal era o pastel.", "Hoje temos um evento de alta tensão."],
	["Você colocou passas no banquete!", "Foi uma surpresa gastronômica.", "Eu também preparei uma surpresa."],
	["Contou o final da novela dos goblins!", "Mas eu avisei que tinha spoiler.", "Já sabe como termina esta conversa?"],
	["Levou meu carregador e deixou o cabo quebrado!", "Era uma troca de experiências.", "Vamos compartilhar um pouco de energia."],
	["Trocou o açúcar pelo sal!", "A receita pedia uma pitada de emoção.", "A minha pede uma dose de corrente."],
	["Colou ‘puxe’ nas portas de empurrar!", "Era um teste de raciocínio.", "Este painel também é."],
	["Embrulhou pastel com o mapa do tesouro!", "O tesouro estava no recheio.", "Você vai ganhar uma experiência eletrizante."],
	["Guardou meias no capacete cerimonial!", "Era proteção contra impacto.", "O cheiro já derrubou três guardas."],
	["Ensinou o papagaio a imitar o alarme!", "Ele pediu um trabalho com propósito.", "Vamos fazer uma pausa no treinamento."],
	["Assombrou o banheiro na hora da limpeza!", "Eu só queria testar o eco.", "Vamos testar outro efeito sonoro."],
	["Deixou a louça suja invisível!", "Tecnicamente, a pia ficou limpa.", "Tecnicamente, esta cadeira está desligada."],
	["Sua espada lendária era de papelão!", "A lenda não mencionava o material.", "Aqui usamos metal de verdade."],
	["Mandou um áudio de sete minutos dizendo ‘ok’!", "Fiz questão de explicar o contexto.", "A minha resposta vai ser bem curta."],
	["Alugou o fantasma da fortaleza para uma festa!", "Ele precisava sair de casa.", "Agora quem precisa de descanso sou eu."],
	["Comeu o recheio e devolveu os biscoitos!", "Foi uma reforma estrutural.", "Vamos revisar sua instalação elétrica."],
	["Carimbou ‘negado’ no meu pedido de férias!", "O formulário estava sem anexo.", "O anexo está nesta sala."],
	["Perfumou a fortaleza inteira com alho!", "O frasco dizia ‘essência marcante’.", "Parabéns. Marcou até as paredes."]
]
const RESTRICTIONS := {3: "bardo", 4: "vampiro", 17: "alquimista"}


static func eligible(character_id: String) -> Array[int]:
	var result: Array[int] = []
	for index in range(CASES.size()):
		if not RESTRICTIONS.has(index) or RESTRICTIONS[index] == character_id:
			result.append(index)
	return result
