//#-hidden-code
import PlaygroundSupport
import UIKit
//#-end-hidden-code
/*:
 
 mBot uses its lightness sensor to feel light.
 
 Try put your hand on top of the mBot,
 or put the mBot to a dark or bright place,
 and see what shows up in the graph.
 
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
//#-code-completion(identifier, show, light, line, ultrasonic, stop(), move(leftSpeed:rightSpeed:), wait(duration:), stop(), playSound(tone:meter:), sendInfraredMessage(message:), show(text:), turnLED(item:color:))
//#-code-completion(keyword, show, for, func, if, var, while)
//#-hidden-code
DispatchQueue.global().async {
//#-end-hidden-code
    
//#-editable-code Tap to enter code
    while true{
        show(String(light))
    }
//#-end-editable-code
    
//#-hidden-code
}
//Loader.sharedTaskMgr.sendTasks()
//#-end-hidden-code
