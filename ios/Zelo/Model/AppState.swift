import SwiftUI
import Observation

enum Papel: String, CaseIterable, Identifiable {
    case familia, parceiro
    var id: String { rawValue }
}

enum ModoPalco: String, CaseIterable, Identifiable {
    case familia = "Família", parceiro = "Parceiro", ladoALado = "Lado a lado"
    var id: String { rawValue }
}

enum FamTab: Hashable { case inicio, zelia, consultas, perfil }
enum ParTab: Hashable { case agenda, ganhos, treino, perfil }

enum Flow { case inicio, quem, cidade, convenio, especialidade, medico, pacote, pagador, pagamento, avisar, livre, ocupado }

struct Toast: Identifiable, Equatable {
    let id = UUID()
    let texto: String
    let icone: String
}

/// Item de uma fala da Zélia: uma mensagem ou uma ação executada naquele ponto da sequência.
enum ZItem {
    case msg(ChatKind)
    case run(() -> Void)

    static func texto(_ s: String) -> ZItem { .msg(.texto(s)) }
}

@MainActor
@Observable
final class AppState {
    // Navegação
    var papel: Papel = .familia
    var modoPalco: ModoPalco = .ladoALado
    var famTab: FamTab = .inicio
    var parTab: ParTab = .agenda

    // Conversa com a Zélia
    var chat: [ChatMsg] = []
    var flow: Flow = .inicio
    var digitando = false

    // Rascunho do pedido
    var proprio = false
    var cidade = ""
    var convenio = ""
    var especialidade = ""
    var medico: Medico?
    var horario = ""
    var servicos = Servicos()
    var pagamento = "Pix"

    // Resultado
    var agendamento: Agendamento?
    var trip = Trip()
    var registros: [Registro] = [.seed]
    var suzana = false
    var online = true

    var toastFamilia: Toast?
    var toastParceiro: Toast?

    @ObservationIgnored private var gravacao: Task<Void, Never>?

    // MARK: Zélia

    func iniciarConversa() {
        guard chat.isEmpty else { return }
        zelia([.texto("Oi! Eu sou a **Zélia**, do Zelo. Eu marco a consulta e cuido de todo o caminho até lá."),
               .texto("Pra quem é a consulta?"), set(.quem)])
    }

    var respostasRapidas: [String] {
        guard !digitando else { return [] }
        switch flow {
        case .quem: return ["Pra minha mãe, Maria", "Pra mim (sou a Maria)"]
        case .cidade: return ["São Paulo", "Outra cidade"]
        case .convenio: return ["Enviar foto da carteirinha", "Vida Plena Saúde", "Não tenho convênio"]
        case .especialidade: return Medico.especialidades
        case .pagador: return ["Eu pago", "A Maria paga"]
        case .pagamento: return ["Pix", "Cartão final 1234"]
        case .avisar: return ["Avisar a Suzana", "Não precisa"]
        case .livre: return agendamento == nil ? ["Marcar uma consulta", "Como tomar o remédio?"]
                                                : ["Como está a Maria?", "Como tomar o remédio?", "Marcar outra consulta"]
        default: return []
        }
    }

    private func set(_ f: Flow) -> ZItem { .run { [weak self] in self?.flow = f } }

    private func zelia(_ itens: [ZItem]) {
        digitando = true
        Task { @MainActor in
            var primeira = true
            for item in itens {
                switch item {
                case .msg(let kind):
                    try? await Task.sleep(for: .milliseconds(primeira ? 650 : 850))
                    primeira = false
                    withAnimation(.easeOut(duration: 0.25)) { chat.append(ChatMsg(deMim: false, kind: kind)) }
                case .run(let acao):
                    acao()
                }
            }
            digitando = false
        }
    }

    func responder(_ texto: String, anexo: Bool = false) {
        let texto = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !digitando, !texto.isEmpty else { return }
        chat.append(ChatMsg(deMim: true, kind: .texto(texto), anexo: anexo))
        let t = texto.normalizado
        let dela = proprio ? "seu" : "da Maria"

        switch flow {
        case .quem:
            proprio = (t.contains("mim") || t.contains("eu")) && !t.contains("mae")
            zelia([.texto(proprio ? "Que bom falar com você, Maria!" : "Combinado, vou cuidar da consulta da Maria."),
                   .texto("Em qual cidade?"), set(.cidade)])
        case .cidade:
            if t.contains("outra") {
                zelia([.texto("Por enquanto o Zelo atende só em São Paulo. Quer seguir com São Paulo?"), set(.cidade)])
                return
            }
            cidade = t.contains("sao paulo") || t == "sp" ? "São Paulo" : texto
            zelia([.texto("Qual é o plano de saúde \(dela)? Pode digitar o nome ou mandar uma foto da carteirinha."), set(.convenio)])
        case .convenio:
            if anexo || t.contains("foto") || t.contains("carteir") {
                convenio = "Vida Plena Saúde"
                zelia([.texto("Li a carteirinha: **Vida Plena Saúde**, plano Ouro, final 4821."), .texto("Qual especialidade?"), set(.especialidade)])
            } else {
                convenio = t.contains("nao") ? "Particular" : texto
                zelia([.texto(convenio == "Particular" ? "Sem problema, procuro consulta particular." : "Anotado: **\(convenio)**."),
                       .texto("Qual especialidade?"), set(.especialidade)])
            }
        case .especialidade:
            let achou = Medico.especialidades.first { t.contains($0.normalizado) || $0.normalizado.hasPrefix(String(t.prefix(5))) }
            especialidade = achou ?? texto.prefix(1).uppercased() + texto.dropFirst()
            let plano = convenio == "Particular" ? "particulares" : "do \(convenio.isEmpty ? "convênio" : convenio)"
            zelia([.texto("Procurando \(especialidade.lowercased()) \(plano) perto \(proprio ? "de você" : "da Maria")…"),
                   .msg(.medicos(especialidade: especialidade, lista: Medico.disponiveis(para: especialidade))),
                   set(.medico)])
        case .medico:
            zelia([.texto("É só tocar num dos horários acima."), set(.medico)])
        case .pacote:
            zelia([.texto("Marque os serviços acima e toque em **Confirmar pacote**."), set(.pacote)])
        case .pagador:
            zelia([.texto("Como prefere pagar os **\(brl(servicos.total))**?"), set(.pagamento)])
        case .pagamento:
            pagamento = t.contains("cart") ? "Cartão" : "Pix"
            zelia([.msg(.nota(icone: "checkmark", texto: pagamento == "Pix" ? "Pix recebido." : "Pagamento aprovado.")),
                   .run { [weak self] in self?.criarAgendamento() },
                   .msg(.confirmacao),
                   .texto("Tudo certo! Vou lembrar \(proprio ? "você" : "a Maria") na véspera e uma hora antes. Quer que eu avise a Suzana também?"),
                   set(.avisar)])
        case .avisar:
            if t.contains("avisar") || t.contains("sim") {
                suzana = true
                zelia([.texto("Pronto, avisei a Suzana. Vocês vão receber cada etapa do dia e o registro da consulta."), set(.livre)])
            } else {
                zelia([.texto("Combinado. Você recebe cada etapa do dia e o registro da consulta aqui no app."), set(.livre)])
            }
        default:
            conversaLivre(t)
        }
    }

    private func conversaLivre(_ t: String) {
        if ["marcar", "agendar", "outra", "nova", "retorno"].contains(where: { t.contains($0) }) {
            servicos = Servicos()
            zelia([.texto("Claro! Qual especialidade?"), set(.especialidade)])
        } else if ["remedio", "colirio", "tomar", "dose"].contains(where: { t.contains($0) }) {
            if let r = registros.first(where: { !$0.remedios.isEmpty }), let m = r.remedios.first {
                zelia([.texto("Pelo registro da consulta de \(r.especialidade.lowercased()) (\(r.data)): **\(m.nome)**, \(m.dose), \(m.quando), \(m.duracao)."),
                       .texto("Eu lembro a Maria todos os dias nesse horário, pelo WhatsApp."), set(.livre)])
            } else {
                zelia([.texto("Ainda não tenho nenhum remédio registrado."), set(.livre)])
            }
        } else if ["como esta", "agora", "onde"].contains(where: { t.contains($0) }) {
            zelia([.texto(statusAgora), set(.livre)])
        } else if ["preco", "quanto", "custa"].contains(where: { t.contains($0) }) {
            zelia([.texto("Você escolhe só o que precisa: transporte ida e volta \(brl(Precos.transporte)), veículo adaptado +\(brl(Precos.adaptado)), acompanhante \(brl(Precos.acompanhante)). O resumo da consulta já vem incluso."), set(.livre)])
        } else {
            zelia([.texto("Ainda estou aprendendo isso. Posso marcar consultas, organizar transporte e acompanhante e explicar os registros das consultas."), set(.livre)])
        }
    }

    var statusAgora: String {
        guard let a = agendamento else { return "A Maria não tem consulta marcada agora. Quer marcar?" }
        if trip.finalizado { return "A consulta já terminou, a Maria está em casa e o registro está no app." }
        if trip.etapa < 0 { return "Consulta marcada: \(a.especialidade.lowercased()), \(a.horario), com \(a.medico.nome). O Carlos busca a Maria às \(a.hora(etapa: 1))." }
        return "Agora: **\(textoEtapaFamilia(trip.etapa))** (\(a.hora(etapa: trip.etapa))). Está tudo bem."
    }

    func textoEtapaFamilia(_ i: Int) -> String {
        if i == 3 { return (agendamento?.servicos.acompanhante ?? false) ? "Em consulta, com a Ana" : "Em consulta (Carlos aguarda)" }
        return Etapa.todas[i].familia
    }

    func escolherHorario(msgID: UUID, medico d: Int, horario s: Int) {
        guard flow == .medico, !digitando, let idx = chat.firstIndex(where: { $0.id == msgID }),
              case let .medicos(esp, lista) = chat[idx].kind else { return }
        chat[idx].escolha = SlotPick(medico: d, horario: s)
        medico = lista[d]; horario = lista[d].horarios[s]; especialidade = esp
        flow = .ocupado
        chat.append(ChatMsg(deMim: true, kind: .texto("\(lista[d].nome) · \(horario)")))
        let temConvenio = !convenio.isEmpty && convenio != "Particular"
        zelia([.msg(.nota(icone: temConvenio ? "checkmark.shield" : "checkmark",
                          texto: temConvenio ? "Pedi a autorização ao \(convenio): autorizado." : "Horário reservado.")),
               .texto("Agora vamos montar o dia da consulta. Marque o que \(proprio ? "você precisa" : "a Maria precisa"):"),
               .msg(.pacote), set(.pacote)])
    }

    func alternarServico(_ keyPath: WritableKeyPath<Servicos, Bool>) {
        guard flow == .pacote else { return }
        servicos[keyPath: keyPath].toggle()
        if keyPath == \Servicos.adaptado && servicos.adaptado { servicos.transporte = true }
        if keyPath == \Servicos.transporte && !servicos.transporte { servicos.adaptado = false }
    }

    func confirmarPacote(msgID: UUID) {
        guard flow == .pacote, !digitando, let idx = chat.firstIndex(where: { $0.id == msgID }) else { return }
        chat[idx].travado = true
        chat.append(ChatMsg(deMim: true, kind: .texto("\(servicos.resumo) · \(brl(servicos.total))")))
        flow = .ocupado
        if servicos.total == 0 {
            zelia([.run { [weak self] in self?.criarAgendamento() }, .msg(.confirmacao),
                   .texto("Tudo certo! Quer que eu avise a Suzana também?"), set(.avisar)])
        } else {
            zelia([.texto("Quem vai pagar?"), set(.pagador)])
        }
    }

    private func criarAgendamento() {
        guard let medico else { return }
        agendamento = Agendamento(especialidade: especialidade, medico: medico, horario: horario,
                                  convenio: convenio.isEmpty ? "Vida Plena Saúde" : convenio,
                                  servicos: servicos, pagamento: pagamento)
        trip = Trip()
        mostrarToast(.parceiro, "Novo atendimento: Maria, 82 · \(horario)", "car.fill")
    }

    func pedirRetorno(de especialidade: String) {
        famTab = .zelia
        if chat.isEmpty { iniciarConversa(); return }
        guard !digitando else { return }
        servicos = Servicos()
        flow = .especialidade
        responder("Quero marcar o retorno: \(especialidade.lowercased())")
    }

    // MARK: Parceiro

    func avancarEtapa() {
        guard let a = agendamento, trip.etapa < Etapa.todas.count - 1 else { return }
        if trip.gravando { pararGravacao() }
        withAnimation(.easeInOut(duration: 0.4)) { trip.etapa += 1 }
        mostrarToast(.familia, "\(textoEtapaFamilia(trip.etapa)) · \(a.hora(etapa: trip.etapa))", "car.fill")
    }

    func alternarGravacao() {
        if trip.gravando { pararGravacao(); return }
        trip.gravando = true
        trip.gravou = true
        gravacao = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, self.trip.gravando else { return }
                self.trip.segundosGravados += 7
            }
        }
    }

    private func pararGravacao() {
        trip.gravando = false
        gravacao?.cancel()
        gravacao = nil
    }

    func finalizar() {
        guard let a = agendamento, trip.etapa == Etapa.todas.count - 1, !trip.finalizado else { return }
        if trip.gravando { pararGravacao() }
        trip.finalizado = true
        registros.insert(Registro.gerar(de: a, trip: trip), at: 0)
        mostrarToast(.familia, "Chegou o registro da consulta da Maria", "doc.text.fill")
    }

    func emergencia() {
        mostrarToast(.parceiro, "Ligando para o 192… família avisada (simulação)", "phone.fill")
        mostrarToast(.familia, "Alerta: Carlos acionou a emergência e ligou para o 192 (simulação)", "exclamationmark.triangle.fill")
    }

    func marcarLido(_ id: String) {
        if let i = registros.firstIndex(where: { $0.id == id }), registros[i].novo { registros[i].novo = false }
    }

    // MARK: Avisos

    func mostrarToast(_ papel: Papel, _ texto: String, _ icone: String) {
        let t = Toast(texto: texto, icone: icone)
        withAnimation(.spring(duration: 0.35)) {
            if papel == .familia { toastFamilia = t } else { toastParceiro = t }
        }
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(4))
            guard let self else { return }
            withAnimation {
                if papel == .familia, self.toastFamilia?.id == t.id { self.toastFamilia = nil }
                if papel == .parceiro, self.toastParceiro?.id == t.id { self.toastParceiro = nil }
            }
        }
    }

    // MARK: Atalhos da apresentação

    func reiniciar() {
        pararGravacao()
        chat = []; flow = .inicio; digitando = false
        proprio = false; cidade = ""; convenio = ""; especialidade = ""; medico = nil; horario = ""
        servicos = Servicos(); pagamento = "Pix"
        agendamento = nil; trip = Trip(); registros = [.seed]; suzana = false
        famTab = .inicio; parTab = .agenda
        toastFamilia = nil; toastParceiro = nil
    }

    func pularParaAgendada() {
        reiniciar()
        let lista = Medico.disponiveis(para: "Oftalmologista")
        cidade = "São Paulo"; convenio = "Vida Plena Saúde"; especialidade = "Oftalmologista"
        medico = lista[0]; horario = lista[0].horarios[0]
        var medicos = ChatMsg(deMim: false, kind: .medicos(especialidade: "Oftalmologista", lista: lista))
        medicos.escolha = SlotPick(medico: 0, horario: 0)
        var pacote = ChatMsg(deMim: false, kind: .pacote)
        pacote.travado = true
        chat = [
            ChatMsg(deMim: false, kind: .texto("Oi! Eu sou a **Zélia**, do Zelo. Eu marco a consulta e cuido de todo o caminho até lá.")),
            ChatMsg(deMim: true, kind: .texto("Preciso de oftalmologista pra minha mãe, Maria, em São Paulo. Convênio Vida Plena.")),
            medicos,
            ChatMsg(deMim: true, kind: .texto("\(lista[0].nome) · \(horario)")),
            ChatMsg(deMim: false, kind: .nota(icone: "checkmark.shield", texto: "Pedi a autorização ao Vida Plena Saúde: autorizado.")),
            pacote,
            ChatMsg(deMim: true, kind: .texto("Transporte + Acompanhante · R$ 380")),
            ChatMsg(deMim: false, kind: .nota(icone: "checkmark", texto: "Pix recebido."))
        ]
        criarAgendamento()
        chat.append(ChatMsg(deMim: false, kind: .confirmacao))
        flow = .livre
        suzana = true
    }
}
