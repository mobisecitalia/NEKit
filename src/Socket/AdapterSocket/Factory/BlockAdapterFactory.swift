import Foundation

open class BlockAdapterFactory: AdapterFactory {
    public let delay: Int
    weak public var blacklistDelegate: BlockAdapterSocketDelegate?

    public init(blacklistDelegate: BlockAdapterSocketDelegate?, delay: Int = Opt.RejectAdapterDefaultDelay) {
        self.delay = delay
        self.blacklistDelegate = blacklistDelegate
    }

    override open func getAdapterFor(session: ConnectSession) -> AdapterSocket {
        return BlockAdapter(blacklistDelegate: self.blacklistDelegate, delay: delay)
    }
}
