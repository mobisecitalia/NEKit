import Foundation

public protocol DNSResolverProtocol: class {
    var delegate: DNSResolverDelegate? { get set }
    func resolve(session: DNSSession)
    func stop()
}

public protocol DNSResolverDelegate: class {
    func didReceive(rawResponse: Data)
}

open class UDPDNSResolver: DNSResolverProtocol, NWUDPSocketDelegate {
    public let socket: NWUDPSocket
    open weak var delegate: DNSResolverDelegate?

    public init(address: IPAddress, port: Port) {
        socket = NWUDPSocket(host: address.presentation, port: Int(port.value))!
        socket.delegate = self
    }

    open func resolve(session: DNSSession) {
        socket.write(data: session.requestMessage.payload)
    }

    open func stop() {
        socket.disconnect()
    }

    open func didReceive(data: Data, from: NWUDPSocket) {
        delegate?.didReceive(rawResponse: data)
    }
    
    open func didCancel(socket: NWUDPSocket) {
        
    }
}
