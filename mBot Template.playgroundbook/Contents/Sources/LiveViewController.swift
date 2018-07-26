import UIKit
import SceneKit
import PlaygroundSupport
import PlaygroundBluetooth

let MaxCameraScale = 1.2
let MinCameraScale = 0.6

public class LiveViewController: UIViewController {
    // MARK: Properties
    public var hello = "hello"
    var scene: SCNScene!
    var connectButton: UIButton!
    var buttonCount = 0
    let scnView = SCNView()
    public let bleMgr = SPBLECenter()
    fileprivate var currentXFov: Double = 0
    fileprivate var originXFov: Double = 0
    fileprivate var mainCamera: SCNCamera?
    
    let loadingQueue = OperationQueue()
    
    var spConnector: SPConnector?
    
    let connectionHintArrowView = ConnectionHintArrowView()
    var toyConnectionView: PlaygroundBluetoothConnectionView?
    public var spConnectorItems: [SPConnectorItem] {
        get {
            return [
                SPConnectorItem(prefix: "Makeblock",
                                    defaultName: "MakeblockName",
                                    icon: UIImage())
            ]
        }
    }
    public lazy var  proxy: SPDispatcher = {
        return SPDispatcher()
    }()
    
    public static func `default`() -> LiveViewController {
        if let s = Loader.fetchScene(name: "mBot") {
            let vc = LiveViewController.init(scene: s)
            return vc
        }
        return LiveViewController.init(nibName: nil, bundle: nil)
    }
    
    init(scene: SCNScene) {
        self.scene = scene
        super.init(nibName: nil, bundle: nil)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.scene = nil
        
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("This method has not been implemented.")
    }
    
    //MARK: LifeCycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        bleMgr.addListener(listener: self)
        
        PlaygroundPage.current.needsIndefiniteExecution = true
        initScene()
        initGesture()
        initCamera()
        //addConnectButton()
        initConnectionView()
//        addConnectButton("viewDidLoad\(originXFov)")
    }
    
    // Layout
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resetCamera()
    }
    
    //MARK: InitComponents
    
    func initCamera() {
        if let cameraNode = scene.rootNode.childNode(withName: "mainCamera", recursively: true), let c = cameraNode.camera {
            mainCamera = c
            originXFov = c.xFov
        }
    }
    
    func initGesture() {
        let gr = UIPanGestureRecognizer.init(target: self, action: #selector(LiveViewController.panGrPand(gr:)))
        let pinchGr = UIPinchGestureRecognizer.init(target: self, action: #selector(LiveViewController.pinchGr(gr:)))
        scnView.addGestureRecognizer(pinchGr)
        scnView.addGestureRecognizer(gr)
    }
    
    func initScene() {
        //self.view = scnView
        scnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scnView.isUserInteractionEnabled = true
        view.addSubview(scnView)
        scnView.frame = view.bounds
        
        loadingQueue.addOperation { [weak self] in
            /// Load the `SCNScene`.
            DispatchQueue.main.async {
                self?.scnView.scene = self?.scene
            }
        }
        
        scnView.contentMode = .center
        scnView.isPlaying = true
        #if DEBUG
            scnView.showsStatistics = true
        #endif
        
    }
    
    
    func initConnectionView() {
        if toyConnectionView == nil {
            spConnector = SPConnector(items: spConnectorItems)
            
            toyConnectionView = PlaygroundBluetoothConnectionView(centralManager: bleMgr.centralManager, delegate: spConnector, dataSource: spConnector)
            view.addSubview(toyConnectionView!)
            
            NSLayoutConstraint.activate([
                toyConnectionView!.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
                toyConnectionView!.trailingAnchor.constraint(equalTo:  self.view.trailingAnchor, constant: -20)
                ])
        }
        if let toyConnectionView = toyConnectionView {
            view.insertSubview(connectionHintArrowView, belowSubview: toyConnectionView)
            connectionHintArrowView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                connectionHintArrowView.trailingAnchor.constraint(equalTo: toyConnectionView.leadingAnchor),
                connectionHintArrowView.topAnchor.constraint(equalTo: toyConnectionView.topAnchor)
                ])
        }
    }
    
    public func addConnectButton(_ title: String = "title") {
        var button: UIButton!
        if connectButton == nil {
            button = UIButton.init(type: .custom)
            button.addTarget(self, action: #selector(LiveViewController.connectButtonDidTap), for: .touchUpInside)
            view.addSubview(button)
            button.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
            button.layer.cornerRadius = 25
            button.frame = CGRect.init(x: 0, y: 450, width: 550, height: 50)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            connectButton = button
        } else {
            button = connectButton
        }
        connectButton.setTitle(title, for: .normal)
    }

    
    //MARK: Private
    func resetCamera() {
        guard let right = mainCamera, let cameraNode = scene.rootNode.childNode(withName: "world", recursively: true) else { return }
        right.xFov = originXFov
        cameraNode.eulerAngles = SCNVector3.init(0, 0, 0)
    }
    
    private func sceneDidLoad(_: SCNScene) {
        // Now that the scene has been loaded, trigger a
        // verification pass.
    }
    
    //MARK: Action
    
    
    func connectButtonDidTap() {
        let center = SPBLEManager.shared
        center.addListener(listener: self)
        center.scan()
    }
    
    func panGrPand(gr: UIPanGestureRecognizer) {

        let vx = gr.velocity(in: scnView).x
        guard abs(vx) > 0.001 else {
            return
        }

        if let cameraNode = scene.rootNode.childNode(withName: "world", recursively: true) {
            let y = cameraNode.eulerAngles.y
            let dx = Float(0.04 * (vx > 0 ? 1 : -1)) * Float(abs(vx) / 300)
            let origin = cameraNode.eulerAngles
            cameraNode.eulerAngles = SCNVector3.init(origin.x, y + dx, origin.z)
        }
        if let cameraNode = scene.rootNode.childNode(withName: "mainCamera", recursively: true) {
            scnView.pointOfView = cameraNode
        }
        
        
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let right = mainCamera, let cameraNode = scene.rootNode.childNode(withName: "world", recursively: true) else { return }
        right.xFov = originXFov
//        addConnectButton("viewWillTransition\(originXFov)")
        cameraNode.eulerAngles = SCNVector3.init(0, 0, 0)
        // MARK: TODO
        return
        let deviceOrientation = UIDevice.current.orientation
        switch(deviceOrientation) {
        case .portrait:
            scnView.frame = CGRect.init(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        default:
            scnView.frame = CGRect.init(x: 0, y: 0, width: view.bounds.size.width / 2, height: view.bounds.size.height)
        }
    }
    
    func pinchGr(gr: UIPinchGestureRecognizer) {
        guard let right = mainCamera else { return }
        switch gr.state {
        case .began:
            currentXFov = right.xFov
        case .changed:
            let gScale = Double(gr.scale)
            let fov = currentXFov * (1 / gScale)
            let finalFov = max(min(fov, originXFov * MaxCameraScale), originXFov * MinCameraScale)
//            addConnectButton("changed\(right.xFov)")
            right.xFov = finalFov
            
        case .ended:
            currentXFov = right.xFov
        default:
            break
        }
    }
    
}

extension LiveViewController: CenterListener {
    public func center<C>(center: C, didDiscover devices: Result<[Device]>) where C: Center {
        
    }
    
    public func center<C>(center: C, didConnect device: Result<Device>) where C : Center {

    }
    
    public func center<C>(center: C, didPrepared device: Result<Device>) where C : Center {

    }
}


extension LiveViewController: PlaygroundLiveViewMessageHandler {
    
    public func liveViewMessageConnectionOpened() {
        proxy.start()
    }
    
    public func liveViewMessageConnectionClosed() {
        proxy.stop()
    }
    
    public func receive(_ message: PlaygroundValue) {
        self.proxy.receive(message)
    }
}
