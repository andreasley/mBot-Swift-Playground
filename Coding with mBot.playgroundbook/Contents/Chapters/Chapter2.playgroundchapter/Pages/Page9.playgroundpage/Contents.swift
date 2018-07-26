//#-hidden-code
import PlaygroundSupport
import UIKit
//#-end-hidden-code
/*:
 Create a function called `ambulance()`.  The function should turn your mBot into an ambulance with lights and sound.
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
    func ambulance(){
        
    }
//#-end-editable-code
    
//#-hidden-code
}
//Loader.sharedTaskMgr.sendTasks()
//#-end-hidden-code
