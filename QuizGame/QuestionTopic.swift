
import Foundation

enum QuestionTopic: String, CaseIterable {
    case halozatiSzolgaltatasok = "Hálózati szolgáltatások"
    case protokollarchitecturak = "Protokollarchitectúrák"
    case fizikaiReteg1 = "Fizikai réteg 1"
    case fizikaiReteg2 = "Fizikai réteg 2"
    case adatkapcsolatiReteg = "Adatkapcsolati réteg"
    case routing = "Routing"
    case ip = "IP"
    case szallitasiProtokollok = "Szállítási protokollok"
    case alkalmazasok = "Alkalmazások"
    case beszedadatatvitel = "Beszédadatátvitel"
    case mobil1 = "Mobil 1"
    case mobil2 = "Mobil 2"
    case mobil3 = "Mobil 3"
    case viop = "VoIP"
    case iptv = "IPTV"
    case wifi = "WiFi"
    case tcpipLabor = "TCP/IP Labor"
    case halozatiAlkalmazasokLabor = "Hálózati alkalmazások Labor"
    case ipv6Labor = "IPv6 Labor"
    case LANmeres = "LAN mérés"
    case iptvmeres = "IPTV mérés"
    case voipmeres = "VoIP mérés"
    case roviditesek = "Rövidítések"
    
    case other = "OTHER"
}
