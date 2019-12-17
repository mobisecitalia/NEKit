import Foundation


public protocol BlockAdapterSocketDelegate : class {
    func isBlocked(domain: String) -> Bool
}

public class BlockAdapter: AdapterSocket {

    public let delay: Int
    
    weak open var blacklistDelegate: BlockAdapterSocketDelegate?
    var blacklisted: Bool = false
    
    /// If this is set to `false`, then the IP address will be resolved by system.
    var resolveHost = false
    
    
    public init(blacklistDelegate: BlockAdapterSocketDelegate?, delay: Int) {
        self.blacklistDelegate = blacklistDelegate
        self.delay = delay
        super.init()
    }
    /**
     Connect to remote according to the `ConnectSession`.
     
     - parameter session: The connect session.
     */
    override public func openSocketWith(session: ConnectSession) {
        super.openSocketWith(session: session)
        
        guard !isCancelled else {
            return
        }
        
//        if blacklistDelegate?.isBlocked(domain: session.host) ?? false {
//            blacklisted = true
//            QueueFactory.getQueue().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(delay)) {
//                [weak self] in
//                self?.disconnect()
//            }
//            return
//        }
        
        do {
            try socket.connectTo(host: session.host, port: Int(session.port), enableTLS: false, tlsSettings: nil)
        } catch let error {
            observer?.signal(.errorOccured(error, on: self))
            disconnect()
        }
    }
    
    /**
     Disconnect the socket elegantly.
     */
    public override func disconnect(becauseOf error: Error? = nil) {
        
        if !blacklisted {
            super.disconnect(becauseOf: error)
            return
        }
        
        guard !isCancelled else {
            return
        }

        _cancelled = true
        session.disconnected(becauseOf: error, by: .adapter)
        observer?.signal(.disconnectCalled(self))
        _status = .closed
        delegate?.didDisconnectWith(socket: self)
    }

    /**
     Disconnect the socket immediately.
     */
    public override func forceDisconnect(becauseOf error: Error? = nil) {
        
        if !blacklisted {
            super.forceDisconnect(becauseOf: error)
            return
        }
        
        guard !isCancelled else {
            return
        }

        _cancelled = true
        session.disconnected(becauseOf: error, by: .adapter)
        observer?.signal(.forceDisconnectCalled(self))
        _status = .closed
        delegate?.didDisconnectWith(socket: self)
    }
    
    /**
     The socket did connect to remote.
     
     - parameter socket: The connected socket.
     */
    override public func didConnectWith(socket: RawTCPSocketProtocol) {
        super.didConnectWith(socket: socket)
        
        if blacklisted {
            return
        }
        
        observer?.signal(.readyForForward(self))
        delegate?.didBecomeReadyToForwardWith(socket: self)
    }
    
    override public func didRead(data: Data, from rawSocket: RawTCPSocketProtocol) {
        super.didRead(data: data, from: rawSocket)
        
        if blacklisted {
            return
        }
        
        delegate?.didRead(data: data, from: self)
    }
    
    override public func didWrite(data: Data?, by rawSocket: RawTCPSocketProtocol) {
        super.didWrite(data: data, by: rawSocket)
        
        if blacklisted {
            return
        }
        
        delegate?.didWrite(data: data, by: self)
    }
}
