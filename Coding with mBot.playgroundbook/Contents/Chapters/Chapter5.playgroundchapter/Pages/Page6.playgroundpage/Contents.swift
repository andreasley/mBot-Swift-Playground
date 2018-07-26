//#-hidden-code
import PlaygroundSupport
import UIKit
//#-end-hidden-code
/*:
 It's time to put them together!
 * You can use **if** to let the robot react to the environment;
 * Write code in onLightnessSensor(light) to read the light sensor;
 * You can use **functions** to group actions together;
 * You can use **For loops** to let the robot repeat itself.
 
 Try anything by yourself!
 
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
