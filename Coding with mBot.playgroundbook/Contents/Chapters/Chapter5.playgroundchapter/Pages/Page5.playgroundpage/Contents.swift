//#-hidden-code
import PlaygroundSupport
import UIKit
//#-end-hidden-code
/*:
 
 You can use `if` command to let the robot
 behave in different conditions.
 
 Try tell the robot `moveForward()` when
 it is placed in the dark place.
 
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
