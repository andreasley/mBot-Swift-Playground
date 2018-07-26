//#-hidden-code
import PlaygroundSupport
import UIKit
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **目标**: 学会使用mBot
 
 若要连接，保持mBot靠近你的iPad。确保已经打开蓝牙，并且mBot已经开启。点击“连接机器人”，并在列表中找到你的mBot。
 
 打开词汇表获取更多可用的函数。点击右上方的...，然后选择词汇表。
*/
//#-hidden-code
playgroundPrologue()
detectUltrasonic(port: 3) { value in
    
}
detectLineSenor(port: 2) { value in
    
}
detectLightSensor() { value in
    
}
wait(duration: 1.5)

//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, light, line, ultrasonic, stop(), startEngine(leftSpeed:rightSpeed:), wait(duration:), stop(), moveForward(speed:), moveBackward(speed:), moveLeft(speed:), moveRight(speed:), playSound(tone:meter:), sendInfraredMessage(message:), turnLED(item:color:))
//#-code-completion(keyword, show, for, func, if, var, while)
//#-hidden-code
DispatchQueue.global().async {
//#-end-hidden-code
//#-editable-code Tap to enter code
    while true {
        testText("\(ultrasonic)")
    }
    
    
    
    
    
    

//#-end-editable-code
//#-hidden-code
}
//Loader.sharedTaskMgr.sendTasks()
//#-end-hidden-code
