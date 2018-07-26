import SceneKit
import PlaygroundSupport

struct ActionEncodingKey {
    static let typeKey = "type"
    static let rotate = "rotate"
    static let axis = "axis"
    
    static let sound = "sound"
    static let move = "move"
    static let execute = "execute"
    static let moveEngine = "moveEngine"
    static let turnLED = "turnLED"
    static let turnBody = "turnBody"
    static let angle = "angle"
    static let duration = "duration"
    static let speed = "speed"
    static let leftSpeed = "leftSpeed"
    static let rightSpeed = "rightSpeed"
    static let color = "color"
    static let send = "send"
    static let receive = "receive"
    static let wait = "wait"
}

struct TargetEncodingKey {
    static let typeKey = "type"
    static let idKey = "id"
    
    static let portKey = "portKey"
    static let wheel = "wheel"
    static let bodyState = "bodyState"
    static let earth = "earth"
    static let led = "led"
    static let buzzer = "buzzer"
    static let infraredSensor = "infraredSensor"
    static let lightSensor = "lightSensor"
    static let ultrasonicSensor = "ultrasonicSensor"
    static let lineSenor = "lineSenor"
    static let testText = "testText"
}


public struct CallbackEncodingKey {
    public static let typeKey = "typeKey"
    public static let valueKey = "valueKey"
    
    public static let light = "light"
    public static let lineSign = "lineSign"
    public static let ultrasonic = "ultrasonic"
    public static let isConnected = "isConnected"
}

public struct Tone: SPMessageConstructible {
    public var pitch: Int
    public var meter: Int
    public var value: PlaygroundValue {
        return .dictionary(["pitch": pitch.value, "meter": meter.value])
    }
    
    public init(pitch: Int, meter: Int) {
        self.pitch = pitch
        self.meter = meter
    }
    
    public init?(_ value: PlaygroundValue) {
        if let p = value.intValue("pitch"), let m = value.intValue("meter") {
            self.init(pitch: p, meter: m)
        } else {
            return nil
        }
    }
    
}


public enum SPCommandAction {
    case rotate(by: SCNVector3, angle: Float, duration: Float)
    case move(to: SCNVector3, duration: Float)
    case sound(Tone)
    case moveEngine(leftSpeed: Float, right: Float)
    case turnBody(speed: Float)
    case turnLED(color: Color)
    case execute
    case wait(duration: Float)
    case none
}

extension SPCommandAction: SPMessageConstructible {
    public init?(_ value: PlaygroundValue) {
        guard case let .dictionary(dict) = value, let typeV = dict[ActionEncodingKey.typeKey], case let .string(type) = typeV else {
            return nil
        }
        switch type  {
        case ActionEncodingKey.rotate:
            if let by = dict[ActionEncodingKey.axis], let vector = SCNVector3.init(by), let ang = dict[ActionEncodingKey.angle], let angle = Float.init(ang), let dur = dict[ActionEncodingKey.duration], let duration = Float.init(dur) {
                self = SPCommandAction.rotate(by: vector, angle: angle, duration: duration)
            } else {
                return nil
            }
        case ActionEncodingKey.sound:
            if let s = dict[ActionEncodingKey.sound], let tone = Tone.init(s) {
                self = SPCommandAction.sound(tone)
            } else {
                //                self = SPCommandAction.sound(Tone.init(pitch: 330, meter: 1000))
                return nil
            }
        case ActionEncodingKey.move:
            if let by = dict[ActionEncodingKey.axis], let vector = SCNVector3.init(by), let dur = dict[ActionEncodingKey.duration], let duration = Float.init(dur) {
                self = SPCommandAction.move(to: vector, duration: duration)
            } else {
                return nil
            }
        case ActionEncodingKey.moveEngine:
            if let leftSpeed = dict[ActionEncodingKey.leftSpeed], let lS = Float.init(leftSpeed), let rightSpeed = dict[ActionEncodingKey.rightSpeed], let rS = Float.init(rightSpeed) {
                self = SPCommandAction.moveEngine(leftSpeed: lS, right: rS)
            } else {
                return nil
            }
        case ActionEncodingKey.turnLED:
            guard let color = dict[ActionEncodingKey.color], let s = Color.init(color) else {
                return nil
            }
            self = SPCommandAction.turnLED(color: s)
        case ActionEncodingKey.wait:
            guard let duration = value.floatValue(ActionEncodingKey.duration) else {
                return nil
            }
            self = SPCommandAction.wait(duration: duration)
        default:
            self = SPCommandAction.none
        }
        
    }
    
    public var value: PlaygroundValue {
        var dict: [String: PlaygroundValue] = [:]
        switch self {
        case .execute:
            dict[ActionEncodingKey.typeKey] = ActionEncodingKey.execute.value
        case .rotate(let by, let angle,  let duration):
            dict[ActionEncodingKey.typeKey] = ActionEncodingKey.rotate.value
            dict[ActionEncodingKey.axis] = by.value
            dict[ActionEncodingKey.angle] = angle.value
            dict[ActionEncodingKey.duration] = duration.value
        case .move(let position, let duration):
            dict[ActionEncodingKey.typeKey] = ActionEncodingKey.move.value
            dict[ActionEncodingKey.axis] = position.value
            dict[ActionEncodingKey.duration] = duration.value
        case .sound(let tone):
            dict[ActionEncodingKey.typeKey] = ActionEncodingKey.sound.value
            dict[ActionEncodingKey.sound] = tone.value
        case .moveEngine(let l, let r):
            dict[ActionEncodingKey.typeKey] = ActionEncodingKey.moveEngine.value
            dict[ActionEncodingKey.leftSpeed] = l.value
            dict[ActionEncodingKey.rightSpeed] = r.value
        case .turnBody(let speed):
            dict[ActionEncodingKey.typeKey] = ActionEncodingKey.turnBody.value
            dict[ActionEncodingKey.speed] = speed.value
        case .turnLED(let color):
            dict[ActionEncodingKey.typeKey] = ActionEncodingKey.turnLED.value
            dict[ActionEncodingKey.color] = color.value
        case .wait(let duration):
            dict[ActionEncodingKey.typeKey] = ActionEncodingKey.wait.value
            dict[ActionEncodingKey.duration] = duration.value
        case .none:
            break
        }
        return .dictionary(dict)
    }
}

extension SPCommandTarget.Direction: SPMessageConstructible {
    public init?(_ value: PlaygroundValue) {
        if case let .string(s) = value {
            switch s {
            case "1":
                self = .left
            case "2":
                self = .right
            case "3":
                self = .both
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    public var value: PlaygroundValue {
        return rawValue.value
    }
    
}

public enum SPCommandTarget {
    public enum Direction: String {
        case left = "1"
        case right = "2"
        case both = "3"
    }
    case engine(Direction)
    case earth
    case led(String)
    case buzzer
    case lightSensor(Int)
    case ultrasonicSensor(Int)
    case lineSenor(Int)
    case infraredSensor(String)
    case testText(String)
    case none
}

extension SPCommandTarget: SPMessageConstructible {
    public init?(_ value: PlaygroundValue) {
        guard case let .dictionary(dict) = value, let typeV = dict[TargetEncodingKey.typeKey], case let .string(type) = typeV else {
            return nil
        }
        switch type {
        case TargetEncodingKey.wheel:
            if let direction = dict[TargetEncodingKey.idKey], let dir =  SPCommandTarget.Direction.init(direction) {
                self =  SPCommandTarget.engine(dir)
            } else {
                return nil
            }
        case TargetEncodingKey.buzzer:
            self =  SPCommandTarget.buzzer
        case TargetEncodingKey.earth:
            self =  SPCommandTarget.earth
        case TargetEncodingKey.led:
            if let id = dict[TargetEncodingKey.idKey], case let .string(idS) = id {
                self =  SPCommandTarget.led(idS)
            } else {
                return nil
            }
        case TargetEncodingKey.lightSensor:
            if let port = value.intValue(TargetEncodingKey.portKey) {
                self =  SPCommandTarget.lightSensor(port)
            } else {
                return nil
            }
        case TargetEncodingKey.ultrasonicSensor:
            if let port = value.intValue(TargetEncodingKey.portKey) {
                self =  SPCommandTarget.ultrasonicSensor(port)
            } else {
                return nil
            }
        case TargetEncodingKey.lineSenor:
            if let port = value.intValue(TargetEncodingKey.portKey) {
                self =  SPCommandTarget.lineSenor(port)
            } else {
                return nil
            }
        case TargetEncodingKey.infraredSensor:
            if let text = value.stringValue(TargetEncodingKey.idKey) {
                self =  SPCommandTarget.infraredSensor(text)
            } else {
                return nil
            }
        case TargetEncodingKey.testText:
            if let t = value.stringValue(TargetEncodingKey.idKey) {
                self = SPCommandTarget.testText(t)
            } else {
                return nil
            }
        default:
            return nil
        }
        
    }
    
    public var value: PlaygroundValue {
        var dict: [String: PlaygroundValue] = [:]
        switch self {
        case .buzzer:
            dict[TargetEncodingKey.typeKey] = TargetEncodingKey.buzzer.value
        case .earth:
            dict[TargetEncodingKey.typeKey] = TargetEncodingKey.earth.value
        case .led(let id):
            dict[TargetEncodingKey.typeKey] = TargetEncodingKey.led.value
            dict[TargetEncodingKey.idKey] = id.value
        case .lightSensor(let port):
            dict[TargetEncodingKey.typeKey] = TargetEncodingKey.lightSensor.value
            dict[TargetEncodingKey.portKey] = port.value
        case .lineSenor(let port):
            dict[TargetEncodingKey.typeKey] = TargetEncodingKey.lineSenor.value
            dict[TargetEncodingKey.portKey] = port.value
        case .ultrasonicSensor(let port):
            dict[TargetEncodingKey.typeKey] = TargetEncodingKey.ultrasonicSensor.value
            dict[TargetEncodingKey.portKey] = port.value
        case .infraredSensor(let text):
            dict[TargetEncodingKey.typeKey] = TargetEncodingKey.infraredSensor.value
            dict[TargetEncodingKey.idKey] = text.value
        case .engine(let direction):
            dict[TargetEncodingKey.typeKey] = TargetEncodingKey.wheel.value
            dict[TargetEncodingKey.idKey] = direction.rawValue.value
        case .testText(let t):
            dict[TargetEncodingKey.typeKey] = TargetEncodingKey.testText.value
            dict[TargetEncodingKey.idKey] = t.value
        case .none:
            break
        }
        return .dictionary(dict)
    }
}

public enum PlatformType: String, SPMessageConstructible {
    public init?(_ value: PlaygroundValue) {
        guard case let .string(a) = value, let t = PlatformType.init(rawValue: a) else {
            return nil
        }
        self = t
    }
    
    public var value: PlaygroundValue {
        return .string(rawValue)
    }
    
    case bluetooth = "bluetooth"
    case sceneKit = "sceneKit"
    case all = "all"
}

public protocol SPCommand: SPMessageConstructible {
    associatedtype ActionType: SPMessageConstructible
    associatedtype TargetType: SPMessageConstructible
    
    var platform: PlatformType {get}
    var action: ActionType {get}
    var target: TargetType {get}
    var duration: Float {get}
}

public struct MCommand: SPCommand {
    public var platform: PlatformType
    
    public var duration: Float
    
    public typealias TargetType = SPCommandTarget
    public typealias ActionType = SPCommandAction
    
    public var target: TargetType
    public var action: ActionType
    public init(target: TargetType, action: ActionType, duration: Float = 2, platform: PlatformType = .all) {
        self.target = target
        self.action = action
        self.duration = duration
        self.platform = platform
    }
    public init() {
        self.target = .none
        self.action = .none
        self.duration = 0
        self.platform = .all
    }
    
    
}

extension MCommand: SPMessageConstructible {
    public init?(_ value: PlaygroundValue) {
        guard case let
            .dictionary(dict) = value, let action = dict["action"], let target = dict["target"], let d = dict["duration"], case let .floatingPoint(duration) = d, let platform = dict["platform"], let pType = PlatformType.init(platform)  else {
                return nil
        }
        self.action = SPCommandAction.init(action) ?? SPCommandAction.execute
        self.target = SPCommandTarget.init(target) ?? SPCommandTarget.engine(.both)
        self.duration = Float(duration)
        self.platform = pType
    }
    
    public var value: PlaygroundValue {
        return .dictionary(["target": target.value, "action": action.value, "duration": duration.value, "platform": platform.value])
    }
    
}


public enum SPCallbackCommand {
    case light(Float)
    case lineSign(Int)
    case ultrasonic(Float)
    case isConnected(Bool)
}

extension SPCallbackCommand: SPMessageConstructible {
    public init?(_ value: PlaygroundValue) {
        guard case let .dictionary(dict) = value, let typeV = dict[CallbackEncodingKey.typeKey], case let .string(type) = typeV else {
            return nil
        }
        switch type {
        case CallbackEncodingKey.light:
            if let a = value.floatValue(CallbackEncodingKey.valueKey) {
                self = .light(a)
            }
            return nil
        case CallbackEncodingKey.lineSign:
            if let a = value.intValue(CallbackEncodingKey.valueKey) {
                self = .lineSign(a)
            }
            return nil
        case CallbackEncodingKey.ultrasonic:
            if let a = value.floatValue(CallbackEncodingKey.valueKey) {
                self = .ultrasonic(a)
            }
            return nil
        case CallbackEncodingKey.isConnected:
            if let a = value.boolValue(CallbackEncodingKey.valueKey) {
                self = .isConnected(a)
            }
            return nil
        default:
            return nil
        }
        
    }
    
    public var value: PlaygroundValue {
        var dict: [String: PlaygroundValue] = [:]
        switch self {
        case .light(let a):
            dict[CallbackEncodingKey.typeKey] = CallbackEncodingKey.light.value
            dict[CallbackEncodingKey.valueKey] = .floatingPoint(Double(a))
        case .lineSign(let a):
            dict[CallbackEncodingKey.typeKey] = CallbackEncodingKey.lineSign.value
            dict[CallbackEncodingKey.valueKey] = .integer(a)
        case .ultrasonic(let a):
            dict[CallbackEncodingKey.typeKey] = CallbackEncodingKey.ultrasonic.value
            dict[CallbackEncodingKey.valueKey] = .floatingPoint(Double(a))
        case .isConnected(let a):
            dict[CallbackEncodingKey.typeKey] = CallbackEncodingKey.isConnected.value
            dict[CallbackEncodingKey.valueKey] = .boolean(a)
        }
        return .dictionary(dict)
    }
}
