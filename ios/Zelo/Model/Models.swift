import Foundation

// MARK: - Premissas de preço (a validar)

enum Precos {
    static let transporte = 80
    static let adaptado = 40          // estimativa — a validar
    static let acompanhante = 300
    static let repasseMotorista = 0.75 // parte do transporte que vai ao motorista — a validar
}

func brl(_ valor: Int) -> String { "R$ \(valor.formatted(.number.locale(Locale(identifier: "pt_BR"))))" }

// MARK: - Pessoas da demo

enum Pessoas {
    static let paciente = "Maria"
    static let idade = 82
    static let endereco = "Rua Apinajés, 300 — Perdizes"
    static let motorista = "Carlos Mendes"
    static let motoristaIni = "CM"
    static let carro = "Spin prata"
    static let placa = "FZL-2B41"
    static let nota = "4,9"
    static let acompanhante = "Ana Souza"
    static let acompanhanteIni = "AS"
    static let acompanhanteCargo = "técnica de enfermagem"
}

// MARK: - Entidades

struct Medico: Hashable, Identifiable {
    var id: String { nome }
    let nome: String
    let bairro: String
    let distancia: String
    let acessibilidade: String
    let horarios: [String]

    static let especialidades = ["Oftalmologista", "Cardiologista", "Clínico geral", "Ortopedista"]

    static func disponiveis(para especialidade: String) -> [Medico] {
        let nomes = ["Dra. Helena Prado", "Dr. Ricardo Tanaka", "Dra. Beatriz Lemos", "Dr. Paulo Ramos", "Dra. Lúcia Fernandes", "Dr. André Matos"]
        let bairros = [("Pinheiros", "2,1 km", "Rampa e elevador"), ("Vila Mariana", "4,8 km", "Térreo, sem degraus"), ("Perdizes", "1,3 km", "Elevador")]
        let horarios = [["Qui 15/10 · 9h", "Qui 15/10 · 14h", "Sex 16/10 · 10h"], ["Seg 19/10 · 8h", "Ter 20/10 · 16h"], ["Qua 21/10 · 11h"]]
        let k = especialidades.firstIndex(of: especialidade) ?? 1
        let inicio = especialidades.contains(especialidade) ? k * 2 : 3
        return (0..<3).map { i in
            Medico(nome: nomes[(inicio + i) % nomes.count], bairro: bairros[i].0, distancia: bairros[i].1,
                   acessibilidade: bairros[i].2, horarios: horarios[i])
        }
    }

    var ehMedica: Bool { nome.hasPrefix("Dra.") }
}

struct Servicos: Equatable {
    var transporte = true
    var adaptado = false
    var acompanhante = true

    var total: Int {
        (transporte ? Precos.transporte : 0) + (adaptado ? Precos.adaptado : 0) + (acompanhante ? Precos.acompanhante : 0)
    }

    var repasseMotorista: Int {
        Int((Double((transporte ? Precos.transporte : 0) + (adaptado ? Precos.adaptado : 0)) * Precos.repasseMotorista).rounded())
    }

    var resumo: String {
        var partes: [String] = []
        if transporte { partes.append(adaptado ? "Transporte adaptado" : "Transporte") }
        if acompanhante { partes.append("Acompanhante") }
        return partes.isEmpty ? "Só o agendamento" : partes.joined(separator: " + ")
    }
}

struct Agendamento: Equatable {
    let especialidade: String
    let medico: Medico
    let horario: String
    let convenio: String
    let servicos: Servicos
    let pagamento: String

    var total: Int { servicos.total }
    var data: String { horario.split(separator: " ").dropFirst().first.map(String.init) ?? "15/10" }

    /// Minutos desde 0h do horário da consulta ("Qui 15/10 · 9h" -> 540).
    var minutos: Int {
        let parte = horario.components(separatedBy: "·").last?.trimmingCharacters(in: .whitespaces) ?? "9h"
        let pedacos = parte.split(separator: "h", omittingEmptySubsequences: false)
        let h = Int(pedacos.first ?? "9") ?? 9
        let m = pedacos.count > 1 ? (Int(pedacos[1]) ?? 0) : 0
        return h * 60 + m
    }

    func hora(etapa: Int) -> String { formatarHora(minutos + Etapa.todas[etapa].deslocamento) }
}

func formatarHora(_ minutos: Int) -> String {
    let h = minutos / 60, m = minutos % 60
    return m == 0 ? "\(h)h" : "\(h)h\(String(format: "%02d", m))"
}

struct Etapa {
    let parceiro: String
    let familia: String
    let deslocamento: Int

    static let todas: [Etapa] = [
        Etapa(parceiro: "Estou a caminho", familia: "Carlos está a caminho", deslocamento: -65),
        Etapa(parceiro: "Busquei a Maria em casa", familia: "Maria entrou no carro", deslocamento: -50),
        Etapa(parceiro: "Chegamos à clínica", familia: "Chegou à clínica", deslocamento: -20),
        Etapa(parceiro: "Maria entrou na consulta", familia: "Em consulta", deslocamento: 5),
        Etapa(parceiro: "Consulta concluída, voltando", familia: "Voltando para casa", deslocamento: 70),
        Etapa(parceiro: "Maria em casa, em segurança", familia: "Maria está em casa", deslocamento: 100)
    ]
}

struct Trip: Equatable {
    var etapa = -1
    var consentimento = false
    var gravando = false
    var segundosGravados = 0
    var gravou = false
    var notas = ""
    var finalizado = false

    var emAndamento: Bool { etapa >= 0 && !finalizado }
}

struct Remedio: Hashable {
    let nome: String
    let dose: String
    let quando: String
    let duracao: String
}

struct Registro: Identifiable, Equatable {
    let id: String
    let especialidade: String
    let medico: String
    let data: String
    let audio: String?
    let registradoPor: String
    let resumo: String
    let remedios: [Remedio]
    let proximos: [String]
    var notas: String
    var novo: Bool

    static func == (a: Registro, b: Registro) -> Bool { a.id == b.id && a.novo == b.novo }

    static let seed = Registro(
        id: "r1", especialidade: "Cardiologista", medico: "Dr. Paulo Ramos", data: "02/10", audio: "14 min",
        registradoPor: "Ana (acompanhante)",
        resumo: "O coração da Maria está bem. A pressão ainda está um pouco alta, então o médico aumentou a dose do remédio.",
        remedios: [Remedio(nome: "Losartana 50 mg", dose: "1 comprimido", quando: "8h e 20h", duracao: "uso contínuo")],
        proximos: ["Medir a pressão 3 vezes por semana", "Retorno em 2 meses"], notas: "", novo: false)

    static func gerar(de a: Agendamento, trip: Trip) -> Registro {
        let audio = trip.gravou ? "\(max(1, trip.segundosGravados / 60)) min" : nil
        let por = a.servicos.acompanhante ? "Ana (acompanhante)" : "áudio enviado pela Maria"
        let notas = trip.notas.trimmingCharacters(in: .whitespacesAndNewlines)
        let id = "r\(Int(Date().timeIntervalSince1970))"
        switch a.especialidade {
        case "Oftalmologista":
            return Registro(id: id, especialidade: a.especialidade, medico: a.medico.nome, data: a.data, audio: audio, registradoPor: por,
                            resumo: "A médica viu que a pressão dentro do olho da Maria está um pouco alta. Não é grave, mas precisa de colírio todos os dias para proteger a visão.",
                            remedios: [Remedio(nome: "Colírio Latanoprosta", dose: "1 gota em cada olho", quando: "à noite, 21h", duracao: "uso contínuo")],
                            proximos: ["Retorno em 3 meses", "Fazer exame de campo visual antes do retorno", "Usar óculos escuros ao sair no sol"],
                            notas: notas, novo: true)
        case "Cardiologista":
            return Registro(id: id, especialidade: a.especialidade, medico: a.medico.nome, data: a.data, audio: audio, registradoPor: por,
                            resumo: "O coração está bem e a pressão melhorou com o remédio novo. O médico manteve a dose.",
                            remedios: [Remedio(nome: "Losartana 50 mg", dose: "1 comprimido", quando: "8h e 20h", duracao: "uso contínuo")],
                            proximos: ["Continuar medindo a pressão", "Retorno em 4 meses"], notas: notas, novo: true)
        default:
            return Registro(id: id, especialidade: a.especialidade, medico: a.medico.nome, data: a.data, audio: audio, registradoPor: por,
                            resumo: "A consulta correu bem. O médico examinou a Maria, não viu nada urgente e pediu exames de rotina.",
                            remedios: [], proximos: ["Fazer os exames pedidos", "Retorno em 2 meses com os resultados"], notas: notas, novo: true)
        }
    }
}

// MARK: - Chat

struct SlotPick: Equatable {
    let medico: Int
    let horario: Int
}

enum ChatKind {
    case texto(String)
    case nota(icone: String, texto: String)
    case medicos(especialidade: String, lista: [Medico])
    case pacote
    case confirmacao
}

struct ChatMsg: Identifiable {
    let id = UUID()
    let deMim: Bool
    let kind: ChatKind
    var anexo = false
    var escolha: SlotPick? = nil
    var travado = false
}

extension String {
    var normalizado: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_BR")).lowercased()
    }
}
