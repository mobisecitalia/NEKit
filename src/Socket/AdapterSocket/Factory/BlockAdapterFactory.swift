import Foundation

open class BlockAdapterFactory: AdapterFactory {
    public let delay: Int
    weak public var blacklistDelegate: BlockAdapterSocketDelegate?

    public init(blacklistDelegate: BlockAdapterSocketDelegate?, delay: Int = Opt.RejectAdapterDefaultDelay) {
        self.delay = delay
        self.blacklistDelegate = blacklistDelegate
        super.init()
    }

    override open func getAdapterFor(session: ConnectSession) -> AdapterSocket {
        let adapter = BlockAdapter(blacklistDelegate: self.blacklistDelegate, delay: delay)
        adapter.socket = RawSocketFactory.getRawSocket()
        return adapter
    }
}
