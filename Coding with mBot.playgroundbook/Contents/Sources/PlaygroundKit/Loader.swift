import SceneKit
import PlaygroundSupport

public struct Loader {
    static let scenePath = "MBot.scnassets/Scenes/"
    public static let sharedTaskMgr: SPTaskManager<MCommand> = SPTaskManager<MCommand>()
    
    public static let currentBot = MBot()

    public static func fetchScene(name sceneName: String) -> SCNScene? {
        let path = scenePath + sceneName
        
        let sURL = (Bundle.main.url(forResource: path, withExtension: "scn") != nil) ? Bundle.main.url(forResource: path, withExtension: "scn") : Bundle.main.url(forResource: path, withExtension: "dae")
        
        guard let sceneURL = sURL, let source = SCNSceneSource(url: sceneURL, options: nil) else {
            return nil
        }
        return source.scene(options: nil)!
    }
    
    public static func setCurrentScene(name: String = "mBot") {
        var vc: LiveViewController!
        if let s = fetchScene(name: name) {
            vc = LiveViewController.init(scene: s)
        } else {
            vc = LiveViewController.default()
        }
        PlaygroundPage.current.liveView = vc
    }
    
    public static func currentLiveViewController() -> LiveViewController  {
        if let vc = PlaygroundPage.current.liveView as? LiveViewController {
            return vc
        }
        return LiveViewController.default()
    }
    
    public static func currentScene() -> SCNScene? {
        if let vc = PlaygroundPage.current.liveView as? LiveViewController {
            return vc.scene
        }
        return nil
    }
    
}

