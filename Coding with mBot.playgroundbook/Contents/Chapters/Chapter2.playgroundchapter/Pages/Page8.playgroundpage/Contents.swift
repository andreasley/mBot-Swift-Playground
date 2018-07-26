//#-hidden-code
import PlaygroundSupport
import UIKit
//#-end-hidden-code
/*:
 Create a function called `blink()` which utilises parameters.  The function to turn the lights red for 1 second and then white.  This sequence should then be repeated multiple time.
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
    move(leftSpeed: 100, rightSpeed: 100)
    wait(duration: 2)
    move(leftSpeed: 0, rightSpeed: 0)

    func blink(){
        
    }
//#-end-editable-code
//#-hidden-code
}
//Loader.sharedTaskMgr.sendTasks()
//#-end-hidden-code
