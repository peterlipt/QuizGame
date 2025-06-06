import Foundation

struct QuestionTopic: Hashable, Identifiable {
    let id: String
    let name: String
    
    static private(set) var allTopics: [QuestionTopic] = [
        QuestionTopic(id: "halozatiSzolgaltatasok", name: "Hálózati szolgáltatások"),
        QuestionTopic(id: "protokollarchitecturak", name: "Protokollarchitectúrák"),
        QuestionTopic(id: "fizikaiReteg1", name: "Fizikai réteg 1"),
        QuestionTopic(id: "fizikaiReteg2", name: "Fizikai réteg 2"),
        QuestionTopic(id: "adatkapcsolatiReteg", name: "Adatkapcsolati réteg"),
        QuestionTopic(id: "routing", name: "Routing"),
        QuestionTopic(id: "ip", name: "IP"),
        QuestionTopic(id: "szallitasiProtokollok", name: "Szállítási protokollok"),
        QuestionTopic(id: "alkalmazasok", name: "Alkalmazások"),
        QuestionTopic(id: "beszedadatatvitel", name: "Beszédadatátvitel"),
        QuestionTopic(id: "mobil1", name: "Mobil 1"),
        QuestionTopic(id: "mobil2", name: "Mobil 2"),
        QuestionTopic(id: "mobil3", name: "Mobil 3"),
        QuestionTopic(id: "viop", name: "VoIP"),
        QuestionTopic(id: "iptv", name: "IPTV"),
        QuestionTopic(id: "wifi", name: "WiFi"),
        QuestionTopic(id: "tcpipLabor", name: "TCP/IP Labor"),
        QuestionTopic(id: "halozatiAlkalmazasokLabor", name: "Hálózati alkalmazások Labor"),
        QuestionTopic(id: "ipv6Labor", name: "IPv6 Labor"),
        QuestionTopic(id: "LANmeres", name: "LAN mérés"),
        QuestionTopic(id: "iptvmeres", name: "IPTV mérés"),
        QuestionTopic(id: "voipmeres", name: "VoIP mérés"),
        QuestionTopic(id: "roviditesek", name: "Rövidítések"),
        QuestionTopic(id: "other", name: "OTHER")
    ]
    
    static func getOrCreate(named name: String) -> QuestionTopic {
        if let existing = allTopics.first(where: { $0.name == name }) {
            return existing
        }
        let newId = name.lowercased().replacingOccurrences(of: " ", with: "_")
        let newTopic = QuestionTopic(id: newId, name: name)
        allTopics.append(newTopic)
        return newTopic
    }
}
