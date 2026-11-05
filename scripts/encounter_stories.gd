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
	["Passou alho no perfume da fortaleza!", "O vendedor garantiu: afasta visitas."]
]
const RESTRICTIONS := {3: "bardo", 4: "vampiro", 17: "alquimista"}


static func eligible(character_id: String) -> Array[int]:
	var result: Array[int] = []
	for index in range(CASES.size()):
		if not RESTRICTIONS.has(index) or RESTRICTIONS[index] == character_id:
			result.append(index)
	return result
